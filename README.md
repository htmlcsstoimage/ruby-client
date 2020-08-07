# HTML/CSS to Image - Ruby

Ruby client for the [HTML/CSS to Image API](https://htmlcsstoimage.com).

Generate a png, jpg or webp images with Ruby. Renders exactly like Google Chrome.

![](https://hcti.imgix.net/assets/images/dog-rates-example.png?auto=format,compress&fit=max&w=798&format=auto&ixlib=imgixjs-3.4.2)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'htmlcsstoimage'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install htmlcsstoimage

## Usage

Create a new instance of the API client.

```ruby
# Retrieve your user id and api key from https://htmlcsstoimage.com/dashboard
client = HTMLCSSToImage.new(user_id: "user-id", api_key: "api-key")
```

Alternatively, you can set `ENV["HCTI_USER_ID"]` and `ENV["HCTI_API_KEY"]`. These will be loaded automatically.

```ruby
client = HTMLCSSToImage.new
```

### Create an image

```ruby
image = client.create_image("<div>Hello, world</div>",
                            css: "div { background-color: red; font-family: Roboto; }",
                            google_fonts: "Roboto")

image
=> #<HTMLCSSToImage::ApiResponse url="https://hcti.io/v1/image/254b444c-dd82-4cc1-94ef-aa4b3a6870a6", id="254b444c-dd82-4cc1-94ef-aa4b3a6870a6">
image.url
=> "https://hcti.io/v1/image/254b444c-dd82-4cc1-94ef-aa4b3a6870a6"
```

### Delete an image
```Ruby
client.delete_image("254b444c-dd82-4cc1-94ef-aa4b3a6870a6")
```

### URL to image
```ruby
image = client.url_to_image("https://github.com", viewport_width: 800, viewport_height: 1200)
```

## Available parameters
For detailed information on all the available parameters, visit the docs: https://docs.htmlcsstoimage.com/getting-started/using-the-api/

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Support
For help with the API, you can also contact `support@htmlcsstoimage.com`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/htmlcsstoimage/ruby-client/contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/htmlcsstoimage/ruby-client/blob/master/CODE_OF_CONDUCT.md).
