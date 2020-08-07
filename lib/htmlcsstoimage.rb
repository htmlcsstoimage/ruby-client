require "htmlcsstoimage/version"
require "httparty"
require "addressable"

class HTMLCSSToImage
  include HTTParty
  base_uri 'https://hcti.io'
  headers 'Content-Type' => 'application/json'
  format :json

  SIGNED_URL_TEMPLATE = Addressable::Template.new("https://hcti.io/v1/image/{template_id}/{signed_token}{/format*}{?query*}")

  class ApiResponse < OpenStruct
  end

  parser(
    proc do |body, format|
      case format
      when :json
        JSON.parse(body, object_class: ApiResponse)
      else
        body
      end
    end
  )

  # Creates an instance of HTMLCSSToImage with API credentials.
  #   If credentials are not provided, will try to use environment variables.
  #   `HCTI_USER_ID` and `HCTI_API_KEY`.
  #
  # @see https://htmlcsstoimage.com/dashboard
  #
  # @param user_id [String] the user_id for the account.
  # @param api_key [String] the api_key for the account.
  # @return [HTMLCSSToImage] an instance of the api client.
  def initialize(user_id: ENV["HCTI_USER_ID"], api_key: ENV["HCTI_API_KEY"])
    @auth = { username: user_id, password: api_key }
  end

  # Converts HTML/CSS to an image with the API
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/using-the-api
  #
  # @param html [String] This is the HTML you want to render. You can send an HTML snippet (`<div>Your content</div>`) or an entire webpage.
  #
  # @option params [String] :css The CSS for your image.
  # @option params [String] :google_fonts [Google fonts](https://docs.htmlcsstoimage.com/guides/using-google-fonts/) to be loaded. Example: `Roboto`. Multiple fonts can be loaded like this: `Roboto|Open Sans`
  # @option params [String] :selector A CSS selector for an element on the webpage. We'll crop the image to this specific element. For example: `section#complete-toolkit.container-lg`
  # @option params [Integer] :ms_delay The number of milliseconds the API should delay before generating the image. This is useful when waiting for JavaScript. We recommend starting with `500`. Large values slow down the initial render time.
  # @option params [Double] :device_scale This adjusts the pixel ratio for the screenshot. Minimum: `1`, Maximum: `3`.
  # @option params [Boolean] :render_when_ready Set to true to control when the image is generated. Call `ScreenshotReady()` from JavaScript to generate the image. [Learn more](https://docs.htmlcsstoimage.com/guides/render-when-ready/).
  # @option params [Integer] :viewport_width Set the width of Chrome's viewport. This will disable automatic cropping. Both height and width parameters must be set if using either.
  # @option params [Integer] :viewport_height Set the height of Chrome's viewport. This will disable automatic cropping. Both height and width parameters must be set if using either.
  #
  # @return [HTMLCSSToImage::ApiResponse] image URL available at `.url`.
  def create_image(html, params = {})
    body = { html: html }.merge(params).to_json
    options = { basic_auth: @auth, body: body, query: { includeId: true } }

    self.class.post("/v1/image", options)
  end

  # Deletes an image
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/using-the-api
  #
  # @param image_id [String] The ID for the image you would like to delete
  def delete_image(image_id)
    response = self.class.delete("/v1/image/#{image_id}", basic_auth: @auth)

    return true if response.success?

    response
  end

  # Creates a signed URL for generating an image from a template
  # This URL contains the template_values in it. It is signed with HMAC so that it cannot be changed
  # by anyone without the API Key.
  #
  # Does not make any network requests.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/using-the-api
  #
  # @param template_id [String] The ID for the template
  # @param template_values [Hash] A hash containing the values to replace in the template
  def create_image_from_template(template_id, template_values = {}, params = {})
    template = SIGNED_URL_TEMPLATE.partial_expand({
      template_id: template_id,
      query: template_values
    })

    query = Addressable::URI.parse(template.generate).query
    digest = OpenSSL::Digest.new('sha256')
    signed_token = OpenSSL::HMAC.hexdigest(digest, @auth[:password], CGI.unescape(query))

    url = template.expand({
      signed_token: signed_token
    }).to_s

    ApiResponse.new(url: url)
  end

  # Generate a screenshot of a URL
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/url-to-image/
  #
  # @param url [String] The fully qualified URL to a public webpage. Such as https://htmlcsstoimage.com.
  # @option params [String] :selector A CSS selector for an element on the webpage. We'll crop the image to this specific element. For example: `section#complete-toolkit.container-lg`
  # @option params [Integer] :ms_delay The number of milliseconds the API should delay before generating the image. This is useful when waiting for JavaScript. We recommend starting with `500`. Large values slow down the initial render time.
  # @option params [Double] :device_scale This adjusts the pixel ratio for the screenshot. Minimum: `1`, Maximum: `3`.
  # @option params [Boolean] :render_when_ready Set to true to control when the image is generated. Call `ScreenshotReady()` from JavaScript to generate the image. [Learn more](https://docs.htmlcsstoimage.com/guides/render-when-ready/).
  # @option params [Integer] :viewport_width Set the width of Chrome's viewport. This will disable automatic cropping. Both height and width parameters must be set if using either.
  # @option params [Integer] :viewport_height Set the height of Chrome's viewport. This will disable automatic cropping. Both height and width parameters must be set if using either.
  def url_to_image(url, params = {})
    body = { url: url }.merge(params).to_json
    options = { basic_auth: @auth, body: body, query: { includeId: true } }

    self.class.post("/v1/image", options)
  end

  # Retrieves all available templates
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/templates/
  def templates(params = {})
    options = params.merge({ basic_auth: @auth })
    self.class.get("/v1/template", options)
  end

  # Creates an image template
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/templates/
  #
  # @param html [String] This is the HTML you want to render. You can send an HTML snippet (`<div>Your content</div>`) or an entire webpage.
  #
  # @option params [String] :name A short name to identify your template max length 64
  # @option params [String] :description Description to elaborate on the use of your template max length 1024
  # @option params [String] :css The CSS for your image.
  # @option params [String] :google_fonts [Google fonts](https://docs.htmlcsstoimage.com/guides/using-google-fonts/) to be loaded. Example: `Roboto`. Multiple fonts can be loaded like this: `Roboto|Open Sans`
  # @option params [String] :selector A CSS selector for an element on the webpage. We'll crop the image to this specific element. For example: `section#complete-toolkit.container-lg`
  # @option params [Integer] :ms_delay The number of milliseconds the API should delay before generating the image. This is useful when waiting for JavaScript. We recommend starting with `500`. Large values slow down the initial render time.
  # @option params [Double] :device_scale This adjusts the pixel ratio for the screenshot. Minimum: `1`, Maximum: `3`.
  # @option params [Boolean] :render_when_ready Set to true to control when the image is generated. Call `ScreenshotReady()` from JavaScript to generate the image. [Learn more](https://docs.htmlcsstoimage.com/guides/render-when-ready/).
  # @option params [Integer] :viewport_width Set the width of Chrome's viewport. This will disable automatic cropping. Both height and width parameters must be set if using either.
  # @option params [Integer] :viewport_height Set the height of Chrome's viewport. This will disable automatic cropping. Both height and width parameters must be set if using either.
  #
  # @return [HTMLCSSToImage::ApiResponse] image URL available at `.url`.
  def create_template(html, params = {})
    body = { html: html }.merge(params).to_json
    options = { basic_auth: @auth, body: body }

    self.class.post("/v1/template", options)
  end
end
