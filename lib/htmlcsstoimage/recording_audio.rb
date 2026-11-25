class HTMLCSSToImage
  # One soundtrack for an MP4 or WebM recording.
  # @see https://docs.htmlcsstoimage.com/parameters/audio/
  class RecordingAudio
    # @param asset_id [String, nil] ID of a completed audio upload in your organization, which may be private
    # @param url [String, nil] public HTTP or HTTPS URL serving the audio file at render time
    # @param source_start_ms [Integer, nil] offset into the source file in milliseconds (default 0)
    # @param delay_ms [Integer, nil] delay from the start of the finished video in milliseconds (default 0)
    # @param when_audio_ends [String, nil] "silence" (default), "loop" from the source offset, or "trim_video"
    # @param error_on_source_invalid [Boolean, nil] defaults to true; set false to return the full silent
    #   video if the track cannot play at render time
    def initialize(asset_id: nil, url: nil, source_start_ms: nil, delay_ms: nil,
                   when_audio_ends: nil, error_on_source_invalid: nil)
      if asset_id.nil? == url.nil?
        raise ArgumentError, "Supply exactly one recording audio source: asset_id or url"
      end
      if !when_audio_ends.nil? && !%w[silence loop trim_video].include?(when_audio_ends)
        raise ArgumentError, "when_audio_ends must be silence, loop, or trim_video"
      end

      @options = {
        asset_id: asset_id, url: url, source_start_ms: source_start_ms, delay_ms: delay_ms,
        when_audio_ends: when_audio_ends, error_on_source_invalid: error_on_source_invalid
      }.compact
    end

    def to_json(*args)
      @options.to_json(*args)
    end
  end
end
