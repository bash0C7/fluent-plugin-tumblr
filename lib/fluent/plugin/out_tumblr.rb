require 'tumblr_client'
require 'erb'
require 'tempfile'
require 'base64'
require 'ostruct'

module Fluent
  class Fluent::TumblrOutput < Fluent::Output
    Fluent::Plugin.register_output('tumblr', self)

    def initialize
      super
    end

    config_param :consumer_key, :string
    config_param :consumer_secret, :string
    config_param :oauth_token, :string
    config_param :oauth_token_secret, :string

    config_param :tumblr_url, :string
    config_param :tags_template, :string
    config_param :caption_template, :string

    config_param :link_key,   :string
    config_param :image_key,   :string
    config_param :post_type, :string
    config_param :base64encoded, :bool

    config_param :post_interval, :integer, :default => 10

    attr_accessor :tumblr_client
    
    def configure(conf)
      super

      @tags = ERB.new(@tags_template)
      @caption = ERB.new(@caption_template)
      raise "Unsupport post_type: #{@post_type}" unless @post_type == 'picture'

      Tumblr.configure do |config|
        config.consumer_key = @consumer_key
        config.consumer_secret = @consumer_secret
        config.oauth_token = @oauth_token
        config.oauth_token_secret = @oauth_token_secret
      end
      @tumblr_client = Tumblr::Client.new

      @q = Queue.new
    end

    def start
      super

      @thread = Thread.new(&method(:post))
    rescue
      $log.warn "raises exception: #{$!.class}, '#{$!.message}"
    end

    def shutdown
      super

      Thread.kill(@thread)
    end

    def emit(tag, es, chain)
      es.each {|time, record|
        param = OpenStruct.new
        param.tag = tag
        param.time = time
        param.record = record

        @q.push param
      }

      chain.next
    end

    private
    def post()
      loop do
        param = @q.pop
        tag = param.tag
        time = param.time
        record = param.record
        
        post_to_tumblr tag, time, record
        
        sleep(@post_interval)
      end
    end

    def post_to_tumblr(tag, time, record)
      tempfile = Tempfile.new(File.basename(__FILE__), Dir.tmpdir)
      begin
        tempfile.binmode

        tempfile.write(@base64encoded ? Base64.decode64(record[@image_key]) : record[@image_key])
        tempfile.close

        @tumblr_client.photo(@tumblr_url,
          tags: @tags.result(binding),
          caption: @caption.result(binding),
          link: record[@link_key],
          data: tempfile.path
        )
      rescue
        $log.warn "raises exception: #{$!.class}, '#{$!.message}'"
      ensure
        tempfile.unlink
      end
    end
  end
end