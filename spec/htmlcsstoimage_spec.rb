require "spec_helper"

RSpec.describe HTMLCSSToImage do
  let(:client) { described_class.new }

  it "has a version number" do
    expect(HTMLCSSToImage::VERSION).not_to be nil
  end

  describe "request parameter passthrough" do
    it "passes all HTML/CSS image parameters through unchanged" do
      params = {
        css: "body { color: black }",
        device_scale: 1.5,
        google_fonts: "Roboto|Open Sans",
        max_wait_ms: 5000,
        ms_delay: 250,
        render_when_ready: false,
        selector: "#content",
        viewport_height: 600,
        viewport_width: 800,
        pdf_options: { print_background: true, margins: ["1px", "2px", "3px", "4px"] },
        disable_twemoji: false,
        max_render_once: true,
        color_scheme: "dark",
        timezone: "America/New_York",
        viewport_mobile: false,
        viewport_landscape: true,
        viewport_touch: false,
        media_type: "print",
        proxy_id: "proxy-123",
        jumbo_max_height: 9000,
        jumbo_max_width: 10000,
        transparent_background: false
      }

      expect(described_class).to receive(:post).with(
        "/v1/image",
        hash_including(
          body: { html: "<div>test</div>" }.merge(params).to_json,
          query: { includeId: true }
        )
      )

      client.create_image("<div>test</div>", params)
    end

    it "passes all URL image parameters through unchanged" do
      params = {
        css: "body { color: black }",
        device_scale: 1.5,
        full_screen: false,
        max_wait_ms: 5000,
        ms_delay: 250,
        render_when_ready: false,
        selector: "#content",
        viewport_height: 600,
        viewport_width: 800,
        pdf_options: { print_background: true },
        disable_twemoji: false,
        max_render_once: true,
        color_scheme: "dark",
        timezone: "America/New_York",
        block_consent_banners: false,
        viewport_mobile: false,
        viewport_landscape: true,
        viewport_touch: false,
        media_type: "screen",
        proxy_id: "proxy-123",
        jumbo_max_height: 9000,
        jumbo_max_width: 10000,
        transparent_background: false
      }

      expect(described_class).to receive(:post).with(
        "/v1/image",
        hash_including(
          body: { url: "https://example.com" }.merge(params).to_json,
          query: { includeId: true }
        )
      )

      client.url_to_image("https://example.com", params)
    end

    it "passes all template parameters through unchanged" do
      params = {
        name: "Example",
        description: "All template options",
        css: "body { color: black }",
        device_scale: 1.5,
        google_fonts: "Roboto|Open Sans",
        max_wait_ms: 5000,
        ms_delay: 250,
        render_when_ready: false,
        max_render_once: true,
        selector: "#content",
        viewport_height: 600,
        viewport_width: 800,
        disable_twemoji: false,
        color_scheme: "dark",
        timezone: "America/New_York",
        viewport_mobile: false,
        viewport_landscape: true,
        viewport_touch: false,
        media_type: "print",
        jumbo_max_height: 9000,
        jumbo_max_width: 10000,
        proxy_id: "proxy-123",
        transparent_background: false
      }

      expect(described_class).to receive(:post).with(
        "/v1/template",
        hash_including(body: { html: "<div>{{title}}</div>" }.merge(params).to_json)
      )

      client.create_template("<div>{{title}}</div>", params)
    end
  end

  describe "#create_templated_image" do
    it "posts template values and an optional template version" do
      expect(described_class).to receive(:post).with(
        "/v1/image",
        hash_including(
          body: {
            template_id: "t-123",
            template_values: { title: "Hello" },
            template_version: 42
          }.to_json,
          query: { includeId: true }
        )
      )

      client.create_templated_image(
        "t-123",
        { title: "Hello" },
        template_version: 42
      )
    end
  end

  describe "#create_image_batch" do
    it "posts variations and shared default options" do
      variations = [
        { html: "<h1>First</h1>" },
        { html: "<h1>Second</h1>", transparent_background: true }
      ]
      defaults = { viewport_width: 1200 }

      expect(described_class).to receive(:post).with(
        "/v1/image/batch",
        hash_including(
          body: {
            variations: variations,
            default_options: defaults
          }.to_json
        )
      )

      client.create_image_batch(variations, defaults)
    end

    it "returns an empty response without making a request for no variations" do
      expect(described_class).not_to receive(:post)

      response = client.create_image_batch([])

      expect(response.images).to eq([])
    end
  end

  describe "#create_image", :vcr do
    it "creates an image" do
      image = client.create_image("<div>test</div>")

      expect(image.url).to match /hcti.io\/v1\/image/
      expect(image.url).to_not be_nil
      expect(image.id).to_not be_nil
    end

    it "accepts additional params" do
      image = client.create_image("<div>test</div>",
                                  css: "body { background-color: orange }",
                                  ms_delay: 500,
                                  google_fonts: "Roboto")

      expect(image.url).to match /hcti.io\/v1\/image/
      expect(image.url).to_not be_nil
      expect(image.id).to_not be_nil
    end
  end

  describe "#url_to_image", :vcr do
    it "creates an image from a url" do
      image = client.url_to_image("https://hcti.io")

      expect(image.url).to match /hcti.io\/v1\/image/
      expect(image.url).to_not be_nil
      expect(image.id).to_not be_nil
    end

    it "accepts additional params" do
      image = client.url_to_image("https://hcti.io",
                                  viewport_width: 800,
                                  viewport_height: 1200,
                                  ms_delay: 500)

      expect(image.url).to match /hcti.io\/v1\/image/
      expect(image.url).to_not be_nil
      expect(image.id).to_not be_nil
    end
  end

  describe "#delete_image", :vcr do
    it "deletes an image" do
      response = client.delete_image("254b444c-dd82-4cc1-94ef-aa4b3a6870a6")
      expect(response).to be true
    end
  end

  describe "#templates", :vcr do
    it "retrieves templates" do
      templates = client.templates

      expect(templates.data.count).to eql 2
      expect(templates.data.first.id).to_not be_nil
      expect(templates.data.first.html).to_not be_nil
      expect(templates.data.first.css).to_not be_nil
    end
  end

  describe "template listing" do
    it "sends pagination parameters in the query string" do
      expect(described_class).to receive(:get).with(
        "/v1/template",
        hash_including(query: { count: 25, max_version: 123 })
      )

      client.list_templates(count: 25, max_version: 123)
    end

    it "keeps templates as a compatibility proxy" do
      expect(client).to receive(:list_templates).with({ count: 5 })

      client.templates(count: 5)
    end

    it "lists versions for one template" do
      expect(described_class).to receive(:get).with(
        "/v1/template/t-123",
        hash_including(query: { count: 20, max_version: 456 })
      )

      client.list_template_versions(
        "t-123",
        count: 20,
        max_version: 456
      )
    end
  end

  describe "#create_template", :vcr do
    it "creates a new template" do
      template = client.create_template("<div>{{title}}</div>")

      expect(template.template_id).to_not be_nil
      expect(template.template_version).to_not be_nil
    end
  end

  describe "#create_template_version" do
    it "posts a new version to the existing template" do
      expect(described_class).to receive(:post).with(
        "/v1/template/t-123",
        hash_including(
          body: {
            html: "<div>{{title}}</div>",
            css: "div { color: blue }"
          }.to_json
        )
      )

      client.create_template_version(
        "t-123",
        "<div>{{title}}</div>",
        css: "div { color: blue }"
      )
    end
  end

  describe "#generate_templated_image_url" do
    it "generates a signed url for the image" do
      # The key is used to generate the token, so we hardcode it here
      client = described_class.new(user_id: "test", api_key: "test")
      image = client.generate_templated_image_url(
        "t-123",
        { title: "Flexbox for life!" }
      )

      expect(image.url).to eql "https://hcti.io/v1/image/t-123/699fe5119b7b2bae4c863f86049d3756133afc1a203d460fed63311045510b2e?title=Flexbox+for+life%21"
    end

    it "sorts and serializes values and includes a template version" do
      client = described_class.new(user_id: "test", api_key: "test")
      image = client.generate_templated_image_url(
        "t-123",
        { z: [1, 2], a: false, skipped: nil },
        template_version: 42
      )
      uri = Addressable::URI.parse(image.url)
      query = "template_version=42&a=false&z=%5B1%2C2%5D"
      token = OpenSSL::HMAC.hexdigest("sha256", "test", query)

      expect(uri.query).to eq(query)
      expect(uri.path).to eq("/v1/image/t-123/#{token}")
    end
  end

  describe "#create_image_from_template" do
    it "proxies to the renamed method and honors the legacy params hash" do
      expect(client).to receive(:generate_templated_image_url).with(
        "t-123",
        { title: "Hello" },
        template_version: 42
      )

      client.create_image_from_template(
        "t-123",
        { title: "Hello" },
        { template_version: 42 }
      )
    end

    it "continues to accept template values as keyword arguments" do
      expect(client).to receive(:generate_templated_image_url).with(
        "t-123",
        { title: "Hello" },
        template_version: nil
      )

      client.create_image_from_template("t-123", title: "Hello")
    end

    it "continues to ignore unsupported legacy params" do
      expect(client).to receive(:generate_templated_image_url).with(
        "t-123",
        { title: "Hello" },
        template_version: nil
      )

      client.create_image_from_template(
        "t-123",
        { title: "Hello" },
        "previously ignored"
      )
    end
  end

  describe "#generate_create_and_render_url" do
    it "signs sorted URL options and preserves transparent background false" do
      client = described_class.new(user_id: "test-id", api_key: "test-key")
      image = client.generate_create_and_render_url(
        "https://example.com/a path",
        viewport_width: 1200,
        css: "body { background: none; }",
        full_screen: false,
        transparent_background: false,
        pdf_options: { print_background: true }
      )
      uri = Addressable::URI.parse(image.url)
      query = "url=https%3A%2F%2Fexample.com%2Fa+path&css=body+%7B+background%3A+none%3B+%7D&transparent_background=false&viewport_width=1200"
      token = OpenSSL::HMAC.hexdigest("sha256", "test-key", query)

      expect(uri.query).to eq(query)
      expect(uri.path).to eq(
        "/v1/image/create-and-render/test-id/#{token}"
      )
    end
  end
end
