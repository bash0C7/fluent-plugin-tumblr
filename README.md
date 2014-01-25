# fluent-plugin-tumblr

## Output

Plugin to post entry to your tumblr

### What's 'tumblr'

see: https://www.tumblr.com/

### Configure Example

````
      type tumblr
      consumer_key YOUR_TUMBLR_CONSUMER_KEY
      consumer_secret YOUR_TUMBLR_CONSUMER_SECRET_KEY
      oauth_token YOUR_TUMBLR_OATH_TOKEN_KEY
      oauth_token_secret YOUR_TUMBLR_OATH_TOKEN_SECRET_KEY
      tumblr_url YOUR_TUMBLR_URL
      tags_template TAG_<%= record['tag'] %>
      caption_template <%= record['message'] %> 
      link_key url
      image_key raw_image
      post_type picture
````

- **Support post_type picture only**
- You can use ERB in tags_template, caption_template
 - http://rubydoc.info/gems/tumblr_client/0.8.2/Tumblr/Post#photo-instance_method
- if base64 encored image in `image_key`, set `base64encoded true`
- if raw image in `image_key`, set `base64encoded false`

#### Optional
- post_interval
 - Internal of post to tumblr

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## releases

- 2014/01/25 0.0.2 Release gem
