require 'tumblr_client'
require 'erb'
require 'tempfile'
require 'Base64'

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
    config_param :data_raw_key,   :string
    config_param :post_type, :string
    config_param :base64encoded, :bool

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
    end

    def start
      super

    end

    def shutdown
      super

    end

    def emit(tag, es, chain)
      es.each {|time,record|
        
        tempfile = Tempfile.new(File.basename(__FILE__), Dir.tmpdir)
        begin
          tempfile.binmode

          tempfile.write(@base64encoded ? Base64.decode64(media) : record[@image_key])
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
      }

      chain.next
    end
  end
end
