module Locations
  # A curated map link wins. If absent, fall back to the coordinate-derived pin.
  module Mappable
    extend ActiveSupport::Concern

    def google_url
      map&.google_url.presence || coordinates&.google_url
    end

    def apple_url
      map&.apple_url.presence || coordinates&.apple_url
    end

    def openstreetmap_url
      map&.openstreetmap_url.presence || coordinates&.openstreetmap_url
    end
  end
end
