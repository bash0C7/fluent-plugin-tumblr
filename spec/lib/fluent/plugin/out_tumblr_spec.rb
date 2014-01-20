require 'spec_helper'

describe do
  let(:driver) {Fluent::Test::OutputTestDriver.new(Fluent::TumblrOutput, 'test.metrics').configure(config)}
  let(:instance) {driver.instance}

  describe 'emit' do
    let(:record1) {{ 'tweet_url' => 'some_url1', 'raw_media' => 'picture1'}}
    let(:record2) {{ 'tweet_url' => 'some_url2', 'raw_media' => 'picture2'}}
    let(:time) {0}
    let(:posted) {
      d = driver

      tumblr_client = Tumblr::Client.new
      
      mock(tumblr_client).photo("tumblr_url", {:tags=>"TAG", :caption=>"CAPTION", :link=>"some_url1", :data=>"filepath"})
      mock(tumblr_client).photo("tumblr_url", {:tags=>"TAG", :caption=>"CAPTION", :link=>"some_url2", :data=>"filepath"})

      any_instance_of(Tempfile) do |klass|
        stub(klass).path { 'filepath' }
      end
      
      d.instance.tumblr_client = tumblr_client
      
      d.emit(record1, Time.at(time))
      d.emit(record2, Time.at(time))
      d.run
    }

    context do
      let(:config) {
        %[
      consumer_key consumer_key
      consumer_secret consumer_secret
      oauth_token oauth_token
      oauth_token_secret oauth_token_secret
      tumblr_url tumblr_url
      tags_template TAG
      caption_template CAPTION
      link_key tweet_url
      image_key raw_media
      base64encoded false
      post_type picture
      post_interval 0
        ]
      }

      subject {posted}
      it{should_not be_nil}
    end

  end

end