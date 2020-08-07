require "spec_helper"

RSpec.describe HTMLCSSToImage do
  let(:client) { described_class.new }

  it "has a version number" do
    expect(HTMLCSSToImage::VERSION).not_to be nil
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

  describe "#create_image_from_template" do
    it "generates a signed url for the image" do
      # The key is used to generate the token, so we hardcode it here
      client = described_class.new(user_id: "test", api_key: "test")
      image = client.create_image_from_template("t-123", { title: "Flexbox for life!" })

      expect(image.url).to eql "https://hcti.io/v1/image/t-123/dd59fca7573133c27c5adc0fc9e4d246f27064db3cd182f03f3b3df8e9ea1b77?title=Flexbox%20for%20life%21"
    end
  end
end
