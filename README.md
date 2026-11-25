# HTML/CSS to Image - Ruby

![Test](https://github.com/htmlcsstoimage/ruby-client/workflows/Test/badge.svg?branch=main) [![Gem Version](https://badge.fury.io/rb/htmlcsstoimage-api.svg)](https://badge.fury.io/rb/htmlcsstoimage-api)

Ruby client for the [HTML/CSS to Image API](https://htmlcsstoimage.com).

Generate PNG, JPG, WebP, or PDF files with Ruby. Renders exactly like Google Chrome.

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
                            google_fonts: "Roboto",
                            format: "webp")

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

Delete several images in one request:

```ruby
client.delete_image_batch([
  "254b444c-dd82-4cc1-94ef-aa4b3a6870a6",
  "60ab90f0-c019-4d0d-a234-cc39e1f2226e"
])
```

### URL to image

Generate a screenshot of any public URL.

```ruby
image = client.url_to_image("https://github.com", viewport_width: 800, viewport_height: 1200)
```

### Create a PDF

Select PDF output with `format: "pdf"`; use `pdf_options` to configure its layout:

```ruby
pdf = client.create_image(
  "<h1>Quarterly report</h1>",
  format: "pdf",
  pdf_options: {
    print_background: true,
    margins: ["20px", "20px", "20px", "20px"]
  }
)
```

### Create a batch of images

Create several HTML/CSS or URL images in one API request. Each variation inherits
values from `default_options` and can override them.

```ruby
images = client.create_image_batch(
  [
    { html: "<h1>First</h1>", format: "jpg" },
    { html: "<h1>Second</h1>", transparent_background: true }
  ],
  { viewport_width: 1200, format: "webp" }
)
```

## Recordings

Record HTML/CSS or a public webpage as MP4, WebM, or GIF. Use
`create_html_css_recording` for HTML/CSS and `create_url_recording` for a webpage:

```ruby
recording = client.create_url_recording(
  "https://example.com",
  duration_ms: 10000,
  viewport_width: 1280,
  viewport_height: 720,
  actions: [{ type: "simple_scroll" }],
  output: { format: "mp4" }
)

recording.id
recording.status_url
recording.recording_url

animation = client.create_html_css_recording(
  "<h1>Hello</h1>",
  css: "@keyframes fade { from { opacity: 0; } to { opacity: 1; } } h1 { animation: fade 2s; font-family: Roboto; }",
  google_fonts: "Roboto",
  duration_ms: 3000,
  duration_mode: "fixed",
  output: { format: "gif", scale: 0.5 }
)
```

Both methods accept browser, timeline, and output options as hashes, following
the image methods. Omitted settings use API defaults.

To add a soundtrack to MP4 or WebM, pass `audio: { asset_id: "YOUR_ASSET_ID", delay_ms: 500 }` or `audio: { url: "https://cdn.example.com/audio/intro.mp3" }` to either recording method. [Audio sources and playback options](https://docs.htmlcsstoimage.com/parameters/audio/).

Triggers and actions use a `type` discriminator. For example, wait until an
element is visible, click a button, and hold the result:

```ruby
demo = client.create_url_recording(
  "https://example.com/demo",
  duration_ms: 5000,
  duration_mode: "fixed",
  trigger: { type: "element_visible", selector: "#demo", timeout_ms: 2000 },
  actions: [
    { type: "click", selector: "#start", if_not_found: [{ type: "error" }] },
    { type: "stall", duration_ms: 1000 }
  ]
)
```

Nested branches run on the API. For JavaScript actions, omitting `if_error` or
setting it to `nil` fails on a script error; `if_error: []` ignores errors.
Empty arrays, explicit `nil`, `false`, and zero values are preserved in JSON.

A `scroll` action moves through ordered `steps`. Each step's `duration_ms` is
required and must be at least 1:

```ruby
client.create_url_recording(
  "https://example.com",
  duration_ms: 6000,
  actions: [
    { type: "scroll", steps: [
      { to: { type: "selector", selector: "#pricing" }, duration_ms: 1200, easing: "ease_in_out_cubic" },
      { to: { type: "position", position: "bottom" }, duration_ms: 1500 }
    ] }
  ]
)
```

Embed or request `recording_url` directly; the request waits until the
recording is ready, so checking status is optional. To inspect progress, fetch
the current status once with:

```ruby
status = client.fetch_recording_status(recording.id)
puts status.status
puts status.attempt_count
```

HTTP 200 and 202 both return status information. The states `ready`, `failed`,
and `cancelled` are terminal. A successful status fetch can report a failed
recording, and `status.error` can describe an earlier, retryable attempt.
`status.status` is the raw API string. Treat values not listed here, which
newer API versions may add, as unknown; the client passes them through as-is.
API errors and transport failures follow the existing image-method behavior.

Delete recordings individually or in a batch:

```ruby
client.delete_recording("recording-id")
client.delete_recording_batch(["first-id", "second-id"])
```

Deletion returns `true` when accepted, or the API response on failure. Empty
batch lists succeed without an API request, matching `delete_image_batch`.

See the [recording guide](https://docs.htmlcsstoimage.com/getting-started/recordings/),
[actions reference](https://docs.htmlcsstoimage.com/parameters/actions/), and
[trigger reference](https://docs.htmlcsstoimage.com/parameters/trigger/) for
options and examples.

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
  headers: { "X-Preview-Mode" => "enabled" },
  additional_header_origins: ["https://api.example.com"],
  include_headers_on_subrequests: true,
  identify_as_hcti: true,
  format: "webp",
  viewport_width: 1200,
  viewport_height: 630,
  transparent_background: false
)

signed_image.url
# => "https://hcti.io/v1/image/create-and-render/user-id/..."
```

`pdf_options` is not supported by the create-and-render endpoint and
`dedupe_duration_s` only applies to standard POST requests, so both are omitted
when generating this URL. Other boolean options set to `false` are omitted,
except `transparent_background`, where both `true` and `false` are meaningful.
Custom headers are encoded in the URL and must not contain long-lived secrets.

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
  template_version: 1596829374001,
  format: "webp"
)

signed_image.url
# => "https://hcti.io/v1/image/t-56c64be5-.../signed-token?template_version=...&customer=...&title=..."
```

Hashes and arrays in `template_values` are serialized as JSON. Values set to
`nil` are omitted from the signed query string.

#### Changed in 0.2.0: template URL signatures

Ruby client 0.1.x URL-decoded the query string before generating its HMAC.
Version 0.2.0 instead signs the encoded query string exactly as it appears in
the generated URL, as required by the current API.

This means regenerating a template URL with the same inputs produces a
different token after upgrading from 0.1.x. Previously generated URLs are not
modified and continue to work.

`create_image_from_template` remains available as a compatibility proxy:

```ruby
signed_image = client.create_image_from_template(
  "t-56c64be5-5861-4148-acec-aaaca452027f",
  { title: "Hello, world!" }
)
```

Its legacy third argument was previously ignored. It remains unsupported except
for `template_version`; other keys in that argument are ignored.

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
  template_version: version.template_version,
  format: "webp"
)
```

For signed, on-demand template images, see “Sign a templated image” in the
Signed URLs section above. `templates` remains available as a compatibility
alias for `list_templates`.

### Additional methods

See the [ruby-client docs for all of the available methods](https://htmlcsstoimage.github.io/ruby-client/HTMLCSSToImage.html).

## Available parameters

For detailed information on all the available parameters, visit the docs: https://docs.htmlcsstoimage.com/getting-started/using-the-api/

The client passes supported API parameters through as JSON. Recent additions
include `dedupe_duration_s`, `storage_destination_id`,
`transparent_background`, `format`, `proxy_id`, `jumbo_max_width`, `jumbo_max_height`,
and, for URL screenshots, `headers`, `additional_header_origins`,
`include_headers_on_subrequests`, `identify_as_hcti`, and
`block_consent_banners`.

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

## Templated image batches

Create images from one or more templates with shared defaults and ordered variations:

```ruby
result = client.create_templated_image_batch(
  [
    { template_values: { title: "First" } },
    { template_id: "t-other", template_values: { title: "Second" } }
  ],
  { template_id: "t-card", template_version: 3, format: "webp" }
)
```

Omitted fields inherit defaults. Supplying a template ID resets the inherited version; omit its version to use latest. Template value objects merge recursively on the API; arrays, scalars, and explicit null values replace defaults. Results preserve input order and identical images reuse existing assets. Each merged values object must be nonempty and satisfy its template's required variables.

See the [API reference](https://docs.htmlcsstoimage.com/getting-started/using-the-api/#batch-templated-image-creation) for plan limits and examples.
