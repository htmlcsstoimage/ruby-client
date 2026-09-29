# Named browser resource types for request_overrides rules.
class HTMLCSSToImage
  class RequestOverrideResourceType
    attr_reader :value

    def initialize(value)
      @value = value.freeze
      freeze
    end
    private_class_method :new

    def to_json(*args)
      @value.to_json(*args)
    end

    Beacon = new("beacon")
    Document = new("document")
    Stylesheet = new("stylesheet")
    Image = new("image")
    ImageSet = new("image_set")
    Media = new("media")
    Font = new("font")
    Script = new("script")
    TextTrack = new("text_track")
    Xhr = new("xhr")
    Fetch = new("fetch")
    EventSource = new("event_source")
    Manifest = new("manifest")
    Ping = new("ping")
    Img = new("img")
    Other = new("other")
  end
end
