class HTMLCSSToImage
  # Records an HTML document or fragment with optional CSS and Google Fonts.
  # Returns the recording ID, status URL, and media URL. The `recording_url` can
  # be embedded or requested directly; a request waits until the recording is
  # ready, so checking status is optional. Optional settings use the API defaults.
  #
  # @see https://docs.htmlcsstoimage.com/getting-started/recordings/
  # @see https://docs.htmlcsstoimage.com/parameters/actions/
  # @see https://docs.htmlcsstoimage.com/parameters/trigger/
  # @see https://docs.htmlcsstoimage.com/parameters/output/
  # @see https://docs.htmlcsstoimage.com/parameters/audio/
  #
  # @param html [String] HTML to record, as a fragment or a complete document
  # @param params [Hash] browser, timeline, and output options passed to the API
  # @option params [Integer] :duration_ms Required recording duration in milliseconds: 500–30000, or up to 90000 in target mode.
  # @option params [String] :css CSS used to style the recording.
  # @option params [String] :google_fonts Google Fonts to load, separated by `|`. Set font-family in the CSS to use them.
  # @option params [Numeric] :device_scale Capture pixel density. HTML/CSS defaults to 2; URL recordings default to 1.
  # @option params [Integer] :viewport_height Chrome viewport height in CSS pixels. Supply both viewport dimensions to set the recording size.
  # @option params [Integer] :viewport_width Chrome viewport width in CSS pixels. Supply both viewport dimensions to set the recording size.
  # @option params [Boolean] :disable_twemoji True disables Twemoji for HTML/CSS. URL recordings inject Twemoji only when explicitly false.
  # @option params [Integer] :dedupe_duration_s Reuse an identical recent recording for this many seconds. Set to 0 to disable deduplication.
  # @option params [String] :color_scheme Chrome's preferred color scheme: `light` or `dark`.
  # @option params [String] :timezone Browser timezone as an IANA identifier, such as `America/New_York`.
  # @option params [Boolean] :viewport_mobile Enable mobile viewport behavior, including the page's viewport meta tag.
  # @option params [Boolean] :viewport_landscape Emulate landscape orientation.
  # @option params [Boolean] :viewport_touch Emulate touch support.
  # @option params [String] :media_type CSS media type used while recording: `print` or `screen`.
  # @option params [String] :proxy_id Configured organization proxy to use while recording.
  # @option params [String] :storage_destination_id Configured storage destination to receive the recording.
  # @option params [Array<Hash>] :request_overrides Browser request block rules. Requires a paid plan.
  # @option params [Hash] :trigger Start condition: `type: "immediate"` (default), `"element_visible"` with a `selector`, or `"function_call"` to wait for `window.RecordingReady()`. Waiting triggers accept `timeout_ms`.
  # @option params [Array<Hash>] :actions Ordered timeline interactions: `simple_scroll`, `scroll`, `stall`, `click`, `locate_selector`, `execute_javascript`, or `error`. Each action has a `type` discriminator. Each `scroll` action step requires `duration_ms` of at least 1. Omit or use an empty array to record without interactions.
  # @option params [Hash] :output Media `format` (`mp4`, `webm`, or `gif`), `fps`, and pixel `scale`. Defaults to MP4 at 30 fps; GIF defaults to 15 fps.
  # @option params [Hash] :audio Optional MP4 or WebM soundtrack. Supply exactly one source, an Asset Library `asset_id` or a public HTTP(S) `url`.
  #   `source_start_ms` skips into the track and `delay_ms` delays playback in the video. Both default to 0.
  #   `when_audio_ends` accepts `"silence"` (default), `"loop"`, or `"trim_video"`.
  #   Set `error_on_source_invalid: false` to return the full video silently if the track cannot play.
  # @option params [String] :duration_mode `at_most` (default) stops when actions finish or the duration is reached. `fixed` pads or cuts off at that duration. `at_least` lets actions finish up to 90 seconds. `target` adjusts playback speed to fit the duration.
  # @option params [Boolean] :defer_render Wait to render until media or storage is requested. Defaults to false; does not reset deduplicated recordings.
  # @option params [Boolean] :skip_scroll_preload Skip the preparation scroll that loads lazy content. Scrolling actions still run. Defaults to false.
  # @return [HTMLCSSToImage::ApiResponse] recording details at `.id`, `.status_url`, and `.recording_url`
  def create_html_css_recording(html, params = {})
    body = { html: html }.merge(params).to_json

    self.class.post("/v1/recording", basic_auth: @auth, body: body)
  end

  # Records a public HTTP or HTTPS webpage.
  #
  # Accepts the browser, timeline, and output options documented on
  # {#create_html_css_recording}. CSS is injected into the page after it loads.
  #
  # @see #create_html_css_recording
  # @see https://docs.htmlcsstoimage.com/guides/recordings/scrolling-video/
  #
  # @param url [String] public HTTP or HTTPS URL to record
  # @param params [Hash] recording options, including the required `duration_ms`
  # @option params [Boolean] :block_consent_banners Attempt to hide cookie and consent banners before recording.
  # @option params [Boolean] :identify_as_hcti Add `X-HCTI-SCREENSHOT: 1` to the top-level navigation.
  # @option params [Hash{String => String}] :headers Custom HTTP headers for top-level navigations to the URL's origin and additional_header_origins.
  # @option params [Array<String>] :additional_header_origins Additional exact HTTP or HTTPS origins allowed to receive custom headers.
  # @option params [Boolean] :include_headers_on_subrequests Also send custom headers with subrequests to allowed origins. Defaults to false.
  # @return [HTMLCSSToImage::ApiResponse] recording details at `.id`, `.status_url`, and `.recording_url`
  def create_url_recording(url, params = {})
    body = { url: url }.merge(params).to_json

    self.class.post("/v1/recording", basic_auth: @auth, body: body)
  end

  # Fetches a recording's current lifecycle state once. Checking status is
  # optional: requesting the `recording_url` directly waits until it is ready.
  # HTTP 200 and 202 both return status information. The states `ready`,
  # `failed`, and `cancelled` are terminal; an error can also describe an
  # earlier, retryable attempt. `.status` is the raw API string: treat values
  # not listed here, which newer API versions may add, as unknown; the client
  # passes them through as-is.
  #
  # @see https://docs.htmlcsstoimage.com/management-api/recordings/
  #
  # @param recording_id [String] the recording ID returned by creation
  # @return [HTMLCSSToImage::ApiResponse] `.id`, `.status`, `.attempt_count`, `.status_entered_at`, `.stored_duration_ms`, `.storage_destination_hcti_storage_disabled`, `.recording_url`, and optional `.error`
  def fetch_recording_status(recording_id)
    self.class.get("/v1/recordings/#{recording_id}/status", basic_auth: @auth)
  end

  # Deletes a recording and clears its media from the CDN.
  #
  # @param recording_id [String] the recording ID to delete
  # @return [true, HTTParty::Response] true when accepted, or the API response on failure
  def delete_recording(recording_id)
    response = self.class.delete("/v1/recordings/#{recording_id}", basic_auth: @auth)

    response.success? ? true : response
  end

  # Deletes several recordings in one API request.
  # Empty lists succeed without calling the API, as with {#delete_image_batch}.
  #
  # @param recording_ids [Array<String>] the recording IDs to delete
  # @return [true, HTTParty::Response] true when accepted, or the API response on failure
  def delete_recording_batch(recording_ids)
    return true if recording_ids.empty?

    response = self.class.delete(
      "/v1/recordings/batch",
      basic_auth: @auth,
      body: { ids: recording_ids }.to_json
    )

    response.success? ? true : response
  end
end
