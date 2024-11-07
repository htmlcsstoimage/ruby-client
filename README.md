# HTML/CSS to Image - Ruby

![Test](https://github.com/htmlcsstoimage/ruby-client/workflows/Test/badge.svg?branch=main) [![Gem Version](https://badge.fury.io/rb/htmlcsstoimage-api.svg)](https://badge.fury.io/rb/htmlcsstoimage-api)

Ruby client for the [HTML/CSS to Image API](https://htmlcsstoimage.com).

Generate png, jpg or webp images with Ruby. Renders exactly like Google Chrome.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'htmlcsstoimage-api', require: 'htmlcsstoimage'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install htmlcsstoimage-api

## Usage

Create a new instance of the API client.

```ruby
require "htmlcsstoimage"
# Retrieve your user id and api key from https://htmlcsstoimage.com/dashboard
client = HTMLCSSToImage.new(user_id: "user-id", api_key: "api-key")
```

**Using Environment variables**

Alternatively, you can set `ENV["HCTI_USER_ID"]` and `ENV["HCTI_API_KEY"]`. These will be loaded automatically.

```ruby
require "htmlcsstoimage"
client = HTMLCSSToImage.new
```

### Create an image
Generate an image from HTML/CSS. Returns a URL to the image.

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
Delete an existing image. Removes the image from HCTI servers and clears the CDN.

```ruby
client.delete_image("254b444c-dd82-4cc1-94ef-aa4b3a6870a6")
```

### URL to image
Generate a screenshot of any public URL.

```ruby
image = client.url_to_image("https://github.com", viewport_width: 800, viewport_height: 1200)
```

## Templates
A template allows you to define HTML that includes variables to be substituted at the time of image creation. [Learn more about templates](https://docs.htmlcsstoimage.com/getting-started/templates/).

```ruby
template = client.create_template("<div>{{title}}</div>")
# => #<HTMLCSSToImage::ApiResponse template_id="t-56c64be5-5861-4148-acec-aaaca452027f", template_version=1596829374001>

# Get templates
all_templates = client.templates

# Create a signed URL for a templated image
image = client.create_image_from_template(template.template_id, { title: "Hello, world!" })
# => #<HTMLCSSToImage::ApiResponse url="https://hcti.io/v1/image/t-56c64be5-5861-4148-acec-aaaca452027f/3aaa814dd998b302cc62b3550ddb35e8b9117c5ecea286da904eced0a3f44d9e?title=Hello%2C%20world%21">

image.url
# => "https://hcti.io/v1/image/t-56c64be5-5861-4148-acec-aaaca452027f/3aaa814dd998b302cc62b3550ddb35e8b9117c5ecea286da904eced0a3f44d9e?title=Hello%2C%20world%21"
```

### Additional methods
See the [ruby-client docs for all of the available methods](https://htmlcsstoimage.github.io/ruby-client/HTMLCSSToImage.html).

## Available parameters
For detailed information on all the available parameters, visit the docs: https://docs.htmlcsstoimage.com/getting-started/using-the-api/

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To generate the Yard docs, run `yard doc -o docs` and commit the changes.

## Support
For help with the API, you can also contact `support@htmlcsstoimage.com`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/htmlcsstoimage/ruby-client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/htmlcsstoimage/ruby-client/blob/main/CODE_OF_CONDUCT.md).
