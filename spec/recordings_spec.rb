require "spec_helper"

RSpec.describe "HTMLCSSToImage recordings" do
  let(:client) { HTMLCSSToImage.new(user_id: "id", api_key: "key") }
  let(:authorization) { "Basic #{Base64.strict_encode64('id:key')}" }
  let(:created) do
    {
      id: "recording-id",
      status_url: "https://hcti.io/v1/recordings/recording-id/status",
      recording_url: "https://hcti.io/v1/recording/recording-id.mp4"
    }
  end
  let(:options) do
    {
      duration_ms: 5000,
      css: "body { color: red; }",
      device_scale: 2,
      viewport_width: 1280,
      viewport_height: 720,
      disable_twemoji: false,
      dedupe_duration_s: 0,
      color_scheme: "dark",
      timezone: "America/New_York",
      viewport_mobile: false,
      viewport_landscape: true,
      viewport_touch: false,
      media_type: "screen",
      proxy_id: "proxy-id",
      storage_destination_id: "storage-id",
      request_overrides: [{ action: "block", resource_types: [HTMLCSSToImage::RequestOverrideResourceType::Script] }],
      trigger: { type: "element_visible", selector: "#ready", timeout_ms: 1000 },
      actions: [
        { type: "locate_selector", selector: "#dialog", if_not_found: [], if_found: [
          { type: "click", selector: "#close", button: "right", count: 2, delay_ms: 0,
            offset_x: 0, offset_y: -1, if_not_found: [{ type: "error" }] }
        ] },
        { type: "execute_javascript", script: "await Promise.resolve();" },
        { type: "execute_javascript", script: "throw Error();", if_error: [] },
        { type: "execute_javascript", script: "throw Error();", if_error: nil },
        { type: "scroll", container_selector: "main", if_not_found: [], steps: [
          { to: { type: "position", position: "bottom" }, duration_ms: 800, easing: "ease_in_out_cubic" },
          { to: { type: "coordinates", x: 0, y: 200 }, duration_ms: 500 },
          { to: { type: "selector", selector: "#footer", offset_y: -40, if_not_found: [] }, duration_ms: 800 }
        ] },
        { type: "simple_scroll", scroll_duration_ms: 800, ms_between_scrolls: 0,
          scroll_distance: "90vh", easing: "ease_in_out_expo", stall_at_end_ms: 0 },
        { type: "simple_scroll", scroll_distance: 900 },
        { type: "stall", duration_ms: 0 }
      ],
      output: { format: "webm", fps: 15, scale: 0.5 },
      duration_mode: "at_least",
      defer_render: false,
      skip_scroll_preload: true
    }
  end

  after { WebMock.reset! }

  def stub_api(method, path, status: 200, body: nil)
    WebMock.stub_request(method, "https://hcti.io#{path}").with(
      headers: { "Authorization" => authorization }
    ).to_return(
      status: status,
      body: body.nil? ? "" : JSON.generate(body),
      headers: { "Content-Type" => "application/json" }
    )
  end

  it "creates HTML recordings with all options and preserves nested branches without mutation" do
    params = options.merge(
      google_fonts: "Roboto|Open Sans",
      audio: {
        asset_id: "asset_1", source_start_ms: 0, delay_ms: 500,
        when_audio_ends: "loop", error_on_source_invalid: false
      }
    ).freeze
    before = Marshal.dump(params)
    expected = JSON.parse({ html: "<h1>Hello</h1>" }.merge(params).to_json)
    WebMock.stub_request(:post, "https://hcti.io/v1/recording").with do |request|
      expect(request.headers["Authorization"]).to eq(authorization)
      expect(request.headers["Content-Type"]).to include("application/json")
      expect(JSON.parse(request.body)).to eq(expected)
      true
    end.to_return(status: 200, body: created.to_json, headers: { "Content-Type" => "application/json" })

    result = client.create_html_css_recording("<h1>Hello</h1>", params)

    expect(result.id).to eq(created[:id])
    expect(result.status_url).to eq(created[:status_url])
    expect(result.recording_url).to eq(created[:recording_url])
    expect(Marshal.dump(params)).to eq(before)
  end

  it "creates URL recordings with headers and source-specific options" do
    params = options.merge(
      audio: { "url" => "https://cdn.example.com/audio/intro.mp3" },
      headers: { "Authorization" => "Bearer test" },
      additional_header_origins: ["https://assets.example.com"],
      include_headers_on_subrequests: false,
      identify_as_hcti: true,
      block_consent_banners: true
    ).freeze
    expected = JSON.parse({ url: "https://example.com" }.merge(params).to_json)
    WebMock.stub_request(:post, "https://hcti.io/v1/recording").with do |request|
      expect(request.headers["Authorization"]).to eq(authorization)
      expect(JSON.parse(request.body)).to eq(expected)
      true
    end.to_return(status: 200, body: created.to_json, headers: { "Content-Type" => "application/json" })

    expect(client.create_url_recording("https://example.com", params).id).to eq("recording-id")
  end

  [{ type: "immediate" }, { type: "function_call", timeout_ms: 1000 }].each do |trigger|
    it "passes the #{trigger[:type]} trigger without adding defaults" do
      stub_api(:post, "/v1/recording", body: created).with(
        body: { html: "<b>Demo</b>", duration_ms: 1000, trigger: trigger }.to_json
      )

      expect(client.create_html_css_recording("<b>Demo</b>", duration_ms: 1000, trigger: trigger).id).to eq("recording-id")
    end
  end

  it "leaves option validation to the API" do
    stub_api(:post, "/v1/recording", status: 400, body: { error: "Bad Request" }).with(
      body: { html: "", duration_ms: 0 }.to_json
    )

    expect(client.create_html_css_recording("", duration_ms: 0).error).to eq("Bad Request")
  end

  it "returns the API error when both audio sources are supplied" do
    audio = { asset_id: "asset_1", url: "https://cdn.example.com/audio/intro.mp3" }
    stub_api(:post, "/v1/recording", status: 400, body: { error: "Bad Request" }).with(
      body: { html: "<b>Demo</b>", duration_ms: 1000, audio: audio }.to_json
    )

    expect(client.create_html_css_recording("<b>Demo</b>", duration_ms: 1000, audio: audio).code).to eq(400)
  end

  {
    "awaiting_render" => 202,
    "processing" => 202,
    "pending_retry" => 202,
    "ready" => 200,
    "failed" => 200,
    "cancelled" => 200
  }.each do |status, http_status|
    it "fetches #{status} status from HTTP #{http_status}" do
      data = {
        id: "recording-id", recording_url: created[:recording_url], status: status,
        status_entered_at: "2026-11-16T10:00:00Z", attempt_count: 2,
        stored_duration_ms: status == "ready" ? 1500 : nil,
        storage_destination_hcti_storage_disabled: status == "ready" ? true : nil,
        error: {
          code: "action_error", message: "Missing element", occurred_at: "2026-11-16T09:59:00Z",
          retryable: true, action_path: "actions[1].if_found[0]"
        }
      }
      stub_api(:get, "/v1/recordings/recording-id/status", status: http_status, body: data)

      result = client.fetch_recording_status("recording-id")

      expect(result.success?).to be true
      expect(result.code).to eq(http_status)
      expect(result.id).to eq("recording-id")
      expect(result.status).to eq(status)
      expect(result.status_entered_at).to eq(data[:status_entered_at])
      expect(result.attempt_count).to eq(2)
      expect(result.stored_duration_ms).to eq(data[:stored_duration_ms])
      expect(result.storage_destination_hcti_storage_disabled).to eq(data[:storage_destination_hcti_storage_disabled])
      expect(result.error.code).to eq("action_error")
      expect(result.error.retryable).to be true
      expect(result.error.action_path).to eq("actions[1].if_found[0]")
    end
  end

  it "preserves absent attempt errors" do
    stub_api(:get, "/v1/recordings/recording-id/status", status: 202, body: {
      id: "recording-id", status: "processing", error: nil, stored_duration_ms: nil
    })

    expect(client.fetch_recording_status("recording-id").error).to be_nil
  end

  it "returns true for accepted deletes with an empty response body" do
    stub_api(:delete, "/v1/recordings/recording-id", status: 202)

    expect(client.delete_recording("recording-id")).to be true
  end

  it "deletes a batch in one authenticated request" do
    stub_api(:delete, "/v1/recordings/batch", status: 202).with(
      body: { ids: ["first-id", "second-id"] }.to_json
    )

    expect(client.delete_recording_batch(["first-id", "second-id"])).to be true
  end

  it "treats an empty delete batch as a successful no-op, like image batches" do
    expect(HTMLCSSToImage).not_to receive(:delete)

    expect(client.delete_recording_batch([])).to be true
  end

  {
    create_html_css_recording: ["<h1>Hello</h1>", { duration_ms: 1000 }],
    create_url_recording: ["https://example.com", { duration_ms: 1000 }],
    fetch_recording_status: ["recording-id"],
    delete_recording: ["recording-id"],
    delete_recording_batch: [["recording-id"]]
  }.each do |method, arguments|
    verb, path = case method
                 when :create_html_css_recording, :create_url_recording then [:post, "/v1/recording"]
                 when :fetch_recording_status then [:get, "/v1/recordings/recording-id/status"]
                 when :delete_recording then [:delete, "/v1/recordings/recording-id"]
                 else [:delete, "/v1/recordings/batch"]
                 end

    it "returns API errors unchanged from #{method}" do
      stub_api(verb, path, status: 403, body: {
        error: "Forbidden", message: "Missing permission",
        validation_errors: [{ path: "duration_ms", message: "Invalid duration" }]
      })

      result = client.public_send(method, *arguments)

      expect(result.code).to eq(403)
      expect(result.error).to eq("Forbidden")
      expect(result.message).to eq("Missing permission")
      expect(result.validation_errors.first.path).to eq("duration_ms")
    end

    it "preserves raw non-JSON server responses from #{method}" do
      WebMock.stub_request(verb, "https://hcti.io#{path}").to_return(status: 502, body: "Unavailable")

      result = client.public_send(method, *arguments)

      expect(result.code).to eq(502)
      expect(result.body).to eq("Unavailable")
    end

    it "propagates transport failures from #{method}" do
      WebMock.stub_request(verb, "https://hcti.io#{path}").to_raise(Net::ReadTimeout)

      expect { client.public_send(method, *arguments) }.to raise_error(Net::ReadTimeout)
    end
  end
end
