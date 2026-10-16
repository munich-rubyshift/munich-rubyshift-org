module Rubyevents
  # We store full profile URLs, upstream wants bare handles for some fields
  # (decision 7A). The handle is always the last path segment, which covers
  # every shape we hold: x.com/<user>, bsky.app/profile/<user>,
  # linkedin.com/in/<user>, github.com/<org>, speakerdeck.com/<user>.
  #
  # Values that are already bare are returned untouched.
  module Handle
    URL = %r{\A[a-z][a-z0-9+.-]*://}i

    def self.from(value)
      value = value.to_s.strip
      return value unless value.match?(URL)

      URI.parse(value).path.to_s.split("/").reject(&:empty?).last.to_s.delete_prefix("@")
    rescue URI::InvalidURIError
      value
    end
  end
end
