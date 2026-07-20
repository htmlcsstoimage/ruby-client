class HTMLCSSToImage
  # Generates a signed URL for rendering an image from a saved template.
  #
  # This method makes no network requests. Hashes and arrays in
  # `template_values` are encoded as JSON before the query string is signed.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/create-and-render/
  #
  # @param template_id [String] the saved template ID
  # @param template_values [Hash] values to substitute into the template
  # @param template_version [Integer, nil] a specific template version, or the latest when omitted
  # @param keyword_values [Hash] template values passed as Ruby keyword arguments
  # @return [HTMLCSSToImage::ApiResponse] signed URL available at `.url`
  def generate_templated_image_url(
    template_id,
    template_values = {},
    template_version: nil,
    **keyword_values
  )
    template_values = template_values.merge(keyword_values)
    pairs = []
    pairs << ["template_version", template_version.to_s] unless template_version.nil?

    template_values.sort_by { |key, _value| key.to_s }.each do |key, value|
      next if value.nil?

      pairs << [key.to_s, signed_value(value)]
    end

    query = Addressable::URI.form_encode(pairs)
    token = generate_hmac_token(query)
    separator = query.empty? ? "" : "?"

    ApiResponse.new(
      url: "https://hcti.io/v1/image/#{template_id}/#{token}#{separator}#{query}"
    )
  end

  # Compatibility proxy for {#generate_templated_image_url}.
  #
  # The third positional hash was accepted by previous versions but was not
  # used. Its `template_version` value is now honored when present.
  #
  # @deprecated Use {#generate_templated_image_url} instead.
  # @param template_id [String] the saved template ID
  # @param template_values [Hash] values to substitute into the template
  # @param params [Hash] legacy options; only `template_version` is used
  # @param template_version [Integer, nil] a specific template version
  # @param keyword_values [Hash] template values passed as Ruby keyword arguments
  # @return [HTMLCSSToImage::ApiResponse] signed URL available at `.url`
  def create_image_from_template(
    template_id,
    template_values = {},
    params = {},
    template_version: nil,
    **keyword_values
  )
    params ||= {}
    template_values = template_values.merge(keyword_values)
    legacy_version =
      if params.is_a?(Hash)
        params[:template_version] || params["template_version"]
      end

    generate_templated_image_url(
      template_id,
      template_values,
      template_version: template_version || legacy_version
    )
  end

  # Generates a signed create-and-render URL for a URL screenshot.
  #
  # This method makes no network requests. PDF options are omitted because the
  # create-and-render endpoint does not support them. False boolean values are
  # omitted except for `transparent_background`, where both values are meaningful.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/create-and-render/
  #
  # @param url [String] the fully qualified URL to capture
  # @param params [Hash] URL screenshot options
  # @return [HTMLCSSToImage::ApiResponse] signed URL available at `.url`
  def generate_create_and_render_url(url, params = {})
    pairs = [["url", url.to_s]]

    params
      .reject { |key, _value| %w[url pdf_options].include?(key.to_s) }
      .sort_by { |key, _value| key.to_s }
      .each do |key, value|
        next if value.nil?
        next if value == false && key.to_s != "transparent_background"

        pairs << [key.to_s, signed_value(value)]
      end

    query = Addressable::URI.form_encode(pairs)
    token = generate_hmac_token(query)

    ApiResponse.new(
      url: "https://hcti.io/v1/image/create-and-render/#{@auth[:username]}/#{token}?#{query}"
    )
  end

  private

  def generate_hmac_token(query)
    OpenSSL::HMAC.hexdigest("sha256", @auth[:password], query)
  end

  def signed_value(value)
    value.is_a?(Array) || value.is_a?(Hash) ? JSON.generate(value) : value.to_s
  end
end
