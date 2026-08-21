class HTMLCSSToImage
  # Converts HTML/CSS to an image with the API.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/using-the-api
  #
  # @param html [String] HTML to render, as a snippet or an entire webpage
  # @param params [Hash] image creation options
  # @option params [String] :css The CSS for your image.
  # @option params [Numeric] :device_scale The pixel ratio for the screenshot. Minimum: `0.1`, Maximum: `3`.
  # @option params [String] :google_fonts Google Fonts to load. Separate multiple fonts with `|`.
  # @option params [Integer] :max_wait_ms The maximum time to wait before taking the screenshot. Minimum: `500`, Maximum: `10000`.
  # @option params [Integer] :ms_delay Extra time in milliseconds to wait before taking the screenshot. Maximum: `10000`.
  # @option params [Boolean] :render_when_ready Wait until `ScreenshotReady()` is called from JavaScript before taking the screenshot.
  # @option params [String] :selector A CSS selector for the element to capture.
  # @option params [Integer] :viewport_height The Chrome viewport height. Both viewport dimensions must be set if using either.
  # @option params [Integer] :viewport_width The Chrome viewport width. Both viewport dimensions must be set if using either.
  # @option params [Hash] :pdf_options Options for generating a PDF, including page size, margins, scale, and background printing.
  # @option params [Boolean] :disable_twemoji Disable the Twemoji fallback and use native emoji fonts.
  # @option params [Boolean] :max_render_once Ensure the image is only rendered and saved once.
  # @option params [Integer] :dedupe_duration_s Reuse an identical image created within this many seconds. Only supported for single-image POST requests.
  # @option params [String] :color_scheme Render using the `light` or `dark` browser color scheme.
  # @option params [String] :timezone The browser timezone as an IANA timezone identifier, such as `America/New_York`.
  # @option params [Boolean] :viewport_mobile Whether to honor the page's mobile viewport behavior.
  # @option params [Boolean] :viewport_landscape Whether to render the viewport in landscape mode.
  # @option params [Boolean] :viewport_touch Whether the viewport supports touch events.
  # @option params [String] :media_type Render using `print` or `screen` media.
  # @option params [String] :proxy_id The ID of an organization proxy to use for the render.
  # @option params [String] :storage_destination_id The ID of an organization storage destination for the rendered image.
  # @option params [Integer] :jumbo_max_height Maximum output height in jumbo mode. Requires `jumbo_max_width`.
  # @option params [Integer] :jumbo_max_width Maximum output width in jumbo mode. Requires `jumbo_max_height`.
  # @option params [Boolean] :transparent_background Whether to render the image with a transparent background.
  # @return [HTMLCSSToImage::ApiResponse] image details, including `.url`
  def create_image(html, params = {})
    body = { html: html }.merge(params).to_json
    options = { basic_auth: @auth, body: body, query: { includeId: true } }

    self.class.post("/v1/image", options)
  end

  # Generates a screenshot of a public URL.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/url-to-image/
  #
  # @param url [String] the fully qualified URL to capture
  # @param params [Hash] image creation options
  # @option params [String] :css CSS to inject into the webpage.
  # @option params [Numeric] :device_scale The pixel ratio for the screenshot. Minimum: `0.1`, Maximum: `3`.
  # @option params [Boolean] :full_screen Take a screenshot of the entire scrollable page.
  # @option params [Integer] :max_wait_ms The maximum time to wait before taking the screenshot. Minimum: `500`, Maximum: `10000`.
  # @option params [Integer] :ms_delay Extra time in milliseconds to wait before taking the screenshot. Maximum: `10000`.
  # @option params [Boolean] :render_when_ready Wait until `ScreenshotReady()` is called from JavaScript before taking the screenshot.
  # @option params [String] :selector A CSS selector for the element to capture.
  # @option params [Integer] :viewport_height The Chrome viewport height. Both viewport dimensions must be set if using either.
  # @option params [Integer] :viewport_width The Chrome viewport width. Both viewport dimensions must be set if using either.
  # @option params [Hash] :pdf_options Options for generating a PDF, including page size, margins, scale, and background printing.
  # @option params [Boolean] :disable_twemoji Disable the Twemoji fallback and use native emoji fonts.
  # @option params [Boolean] :max_render_once Ensure the image is only rendered and saved once.
  # @option params [Integer] :dedupe_duration_s Reuse an identical image created within this many seconds. Only supported for single-image POST requests.
  # @option params [String] :color_scheme Render using the `light` or `dark` browser color scheme.
  # @option params [String] :timezone The browser timezone as an IANA timezone identifier, such as `America/New_York`.
  # @option params [Boolean] :block_consent_banners Attempt to block cookie and consent banners.
  # @option params [Hash{String => String}] :headers Custom HTTP headers to send to allowed origins.
  # @option params [Array<String>] :additional_header_origins Additional exact origins allowed to receive custom headers.
  # @option params [Boolean] :include_headers_on_subrequests Send custom headers on subrequests to allowed origins.
  # @option params [Boolean] :identify_as_hcti Add `X-HCTI-SCREENSHOT: 1` to the top-level page request.
  # @option params [Boolean] :viewport_mobile Whether to honor the page's mobile viewport behavior.
  # @option params [Boolean] :viewport_landscape Whether to render the viewport in landscape mode.
  # @option params [Boolean] :viewport_touch Whether the viewport supports touch events.
  # @option params [String] :media_type Render using `print` or `screen` media.
  # @option params [String] :proxy_id The ID of an organization proxy to use for the render.
  # @option params [String] :storage_destination_id The ID of an organization storage destination for the rendered image.
  # @option params [Integer] :jumbo_max_height Maximum output height in jumbo mode. Requires `jumbo_max_width`.
  # @option params [Integer] :jumbo_max_width Maximum output width in jumbo mode. Requires `jumbo_max_height`.
  # @option params [Boolean] :transparent_background Whether to render the image with a transparent background.
  # @return [HTMLCSSToImage::ApiResponse] image details, including `.url`
  def url_to_image(url, params = {})
    body = { url: url }.merge(params).to_json
    options = { basic_auth: @auth, body: body, query: { includeId: true } }

    self.class.post("/v1/image", options)
  end

  # Creates an image from a saved template with an API request.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/templates/
  #
  # @param template_id [String] the saved template ID
  # @param template_values [Hash] values to substitute into the template
  # @param template_version [Integer, nil] a specific template version, or the latest when omitted
  # @param keyword_values [Hash] template values passed as Ruby keyword arguments
  # @return [HTMLCSSToImage::ApiResponse] image details, including `.url`
  def create_templated_image(
    template_id,
    template_values = {},
    template_version: nil,
    **keyword_values
  )
    template_values = template_values.merge(keyword_values)
    body = {
      template_id: template_id,
      template_values: template_values
    }
    body[:template_version] = template_version unless template_version.nil?

    self.class.post(
      "/v1/image",
      basic_auth: @auth,
      body: body.to_json,
      query: { includeId: true }
    )
  end

  # Creates several HTML/CSS or URL images in one API request.
  #
  # Templates are not supported in batch requests.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/using-the-api
  #
  # @param variations [Array<Hash>] per-image values
  # @param default_options [Hash, nil] shared values inherited by each variation
  # @return [HTMLCSSToImage::ApiResponse] batch response with images available at `.images`
  def create_image_batch(variations, default_options = nil)
    return ApiResponse.new(images: []) if variations.empty?

    body = { variations: variations }
    body[:default_options] = default_options unless default_options.nil?

    self.class.post(
      "/v1/image/batch",
      basic_auth: @auth,
      body: body.to_json
    )
  end

  # Deletes an image.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/using-the-api
  #
  # @param image_id [String] the ID of the image to delete
  # @return [Boolean, HTMLCSSToImage::ApiResponse] true on success, or the API response on failure
  def delete_image(image_id)
    response = self.class.delete("/v1/image/#{image_id}", basic_auth: @auth)

    return true if response.success?

    response
  end

  # Deletes multiple images in one request.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/using-the-api
  #
  # @param image_ids [Array<String>] IDs of the images to delete
  # @return [Boolean, HTMLCSSToImage::ApiResponse] true on success, or the API response on failure
  def delete_image_batch(image_ids)
    return true if image_ids.empty?

    response = self.class.delete(
      "/v1/image/batch",
      basic_auth: @auth,
      body: { ids: image_ids }.to_json
    )

    return true if response.success?

    response
  end
end
