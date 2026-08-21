class HTMLCSSToImage
  # Retrieves saved templates.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/templates/
  #
  # @param params [Hash] pagination options
  # @option params [Integer] :count number of templates to return, up to 100
  # @option params [Integer] :max_version pagination cursor returned by the previous request
  # @return [HTMLCSSToImage::ApiResponse] paginated template response
  def list_templates(params = {})
    self.class.get(
      "/v1/template",
      basic_auth: @auth,
      query: params
    )
  end

  # Compatibility proxy for {#list_templates}.
  #
  # @param params [Hash] pagination options
  # @return [HTMLCSSToImage::ApiResponse] paginated template response
  def templates(params = {})
    list_templates(params)
  end

  # Retrieves versions of a saved template.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/templates/
  #
  # @param template_id [String] the saved template ID
  # @param params [Hash] pagination options
  # @option params [Integer] :count number of versions to return, up to 100
  # @option params [Integer] :max_version pagination cursor returned by the previous request
  # @return [HTMLCSSToImage::ApiResponse] paginated template version response
  def list_template_versions(template_id, params = {})
    self.class.get(
      "/v1/template/#{template_id}",
      basic_auth: @auth,
      query: params
    )
  end

  # Creates an image template.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/templates/
  #
  # @param html [String] HTML for the template
  # @param params [Hash] template and rendering options
  # @option params [String] :name A short name to identify the template. Maximum length: 64.
  # @option params [String] :description A description of the template. Maximum length: 1024.
  # @option params [String] :css The CSS for the template.
  # @option params [Numeric] :device_scale The pixel ratio for the screenshot. Minimum: `0.1`, Maximum: `3`.
  # @option params [String] :google_fonts Google Fonts to load. Separate multiple fonts with `|`.
  # @option params [Integer] :max_wait_ms The maximum time to wait before taking the screenshot. Minimum: `500`, Maximum: `10000`.
  # @option params [Integer] :ms_delay Extra time in milliseconds to wait before taking the screenshot. Maximum: `10000`.
  # @option params [Boolean] :render_when_ready Wait until `ScreenshotReady()` is called from JavaScript before taking the screenshot.
  # @option params [Boolean] :max_render_once Ensure images created from the template are only rendered and saved once.
  # @option params [String] :selector A CSS selector for the element to capture.
  # @option params [Integer] :viewport_height The Chrome viewport height. Both viewport dimensions must be set if using either.
  # @option params [Integer] :viewport_width The Chrome viewport width. Both viewport dimensions must be set if using either.
  # @option params [Boolean] :disable_twemoji Disable the Twemoji fallback and use native emoji fonts.
  # @option params [String] :color_scheme Render using the `light` or `dark` browser color scheme.
  # @option params [String] :timezone The browser timezone as an IANA timezone identifier, such as `America/New_York`.
  # @option params [Boolean] :viewport_mobile Whether to honor the page's mobile viewport behavior.
  # @option params [Boolean] :viewport_landscape Whether to render the viewport in landscape mode.
  # @option params [Boolean] :viewport_touch Whether the viewport supports touch events.
  # @option params [String] :media_type Render using `print` or `screen` media.
  # @option params [Integer] :jumbo_max_height Maximum output height in jumbo mode. Requires `jumbo_max_width`.
  # @option params [Integer] :jumbo_max_width Maximum output width in jumbo mode. Requires `jumbo_max_height`.
  # @option params [String] :proxy_id The ID of an organization proxy to use for the render.
  # @option params [String] :storage_destination_id The ID of an organization storage destination inherited by images created from the template.
  # @option params [Boolean] :transparent_background Whether images created from the template should use a transparent background.
  # @return [HTMLCSSToImage::ApiResponse] created template details
  def create_template(html, params = {})
    create_template_at_path("/v1/template", html, params)
  end

  # Creates a new version of a saved template.
  #
  # Accepts the same options as {#create_template}.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/templates/
  #
  # @param template_id [String] the saved template ID
  # @param html [String] HTML for the new template version
  # @param params [Hash] template and rendering options
  # @return [HTMLCSSToImage::ApiResponse] created template version details
  def create_template_version(template_id, html, params = {})
    create_template_at_path("/v1/template/#{template_id}", html, params)
  end

  private

  def create_template_at_path(path, html, params)
    body = { html: html }.merge(params).to_json

    self.class.post(path, basic_auth: @auth, body: body)
  end
end
