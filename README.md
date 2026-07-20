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

### Create a batch of images

Create several HTML/CSS or URL images in one API request. Each variation inherits
values from `default_options` and can override them.

```ruby
images = client.create_image_batch(
  [
    { html: "<h1>First</h1>" },
    { html: "<h1>Second</h1>", transparent_background: true }
  ],
  { viewport_width: 1200 }
)
```

## Signed URLs

Signed URLs let another application, browser, or service render an image on
demand without exposing your API key. Generating a signed URL does not make an
API request; the image is created when the resulting URL is requested.

Both signed URL methods return an `HTMLCSSToImage::ApiResponse`. Use `.url` to
retrieve the URL:

```ruby
signed_image = client.generate_create_and_render_url("https://example.com")
signed_image.url
# => "https://hcti.io/v1/image/create-and-render/user-id/..."
```

Generate signed URLs in trusted server-side code. The API key is used to create
the HMAC signature and should never be exposed to a browser or end user. Query
parameters are covered by that signature, so modifying them after generation
invalidates the URL. Remember that the URL and its query values remain visible
to anyone who receives it.

[Learn more about create-and-render and signed URLs](https://docs.htmlcsstoimage.com/getting-started/create-and-render/).

### Sign a URL screenshot

Use `generate_create_and_render_url` when you want HCTI to capture a public
webpage each time the signed URL is requested. Pass the target URL first,
followed by the same screenshot options accepted by `url_to_image`.

```ruby
signed_image = client.generate_create_and_render_url(
  "https://example.com/dashboard",
  css: ".navigation { display: none; }",
  viewport_width: 1200,
  viewport_height: 630,
  transparent_background: false
)

signed_image.url
# => "https://hcti.io/v1/image/create-and-render/user-id/..."
```

`pdf_options` is not supported by the create-and-render endpoint and is omitted
when generating this URL. Other boolean options set to `false` are omitted,
except `transparent_background`, where both `true` and `false` are meaningful.

### Sign a templated image

Use `generate_templated_image_url` to substitute values into a saved template
when the signed URL is requested. Pass `template_version` to pin the URL to a
specific version; omit it to use the latest template version.

```ruby
signed_image = client.generate_templated_image_url(
  "t-56c64be5-5861-4148-acec-aaaca452027f",
  {
    title: "Hello, world!",
    customer: {
      name: "Ada",
      plan: "Pro"
    }
  },
  template_version: 1596829374001
)

signed_image.url
# => "https://hcti.io/v1/image/t-56c64be5-.../signed-token?template_version=...&customer=...&title=..."
```

Hashes and arrays in `template_values` are serialized as JSON. Values set to
`nil` are omitted from the signed query string.

`create_image_from_template` remains available as a compatibility proxy:

```ruby
signed_image = client.create_image_from_template(
  "t-56c64be5-5861-4148-acec-aaaca452027f",
  { title: "Hello, world!" }
)
```

## Templates

A template allows you to define HTML that includes variables to be substituted at the time of image creation. [Learn more about templates](https://docs.htmlcsstoimage.com/getting-started/templates/).

```ruby
template = client.create_template("<div>{{title}}</div>")
# => #<HTMLCSSToImage::ApiResponse template_id="t-56c64be5-5861-4148-acec-aaaca452027f", template_version=1596829374001>

# Get templates
all_templates = client.list_templates(count: 25)

# Get versions of one template
versions = client.list_template_versions(template.template_id, count: 25)

# Create a new version
version = client.create_template_version(
  template.template_id,
  "<div class='updated'>{{title}}</div>"
)

# Create a templated image with an API request
created_image = client.create_templated_image(
  template.template_id,
  { title: "Hello, world!" },
  template_version: version.template_version
)
```

For signed, on-demand template images, see “Sign a templated image” in the
Signed URLs section above. `templates` remains available as a compatibility
alias for `list_templates`.

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
