module Rubyevents
  class Document::Venue < Document
    def initialize(event, **options)
      super(**options)
      @event = event
      @venue = event.venue
    end

    def path
      "#{Rubyevents::Id.path_segment(@event.series, lenient: lenient?)}/" \
        "#{Rubyevents::Id.path_segment(@event, lenient: lenient?)}/venue.yml"
    end

    def content
      {
        "name" => @venue.name,
        "description" => @venue.description,
        "instructions" => @venue.instructions,
        "url" => @venue.url,
        "address" => address,
        "coordinates" => coordinates,
        "maps" => maps,
        "accessibility" => accessibility,
        "nearby" => nearby
      }
    end

    private

    def city
      @venue.address&.city
    end

    def address
      return fallback(nil, {}) unless @venue.address

      {
        "street" => @venue.address.street,
        "city" => city&.name,
        "region" => city&.state_code,
        "postal_code" => @venue.address.zip_code,
        "country" => country_name(city&.country_code),
        "country_code" => city&.country_code,
        "display" => display
      }
    end

    # Upstream stores a formatted address; we compose one in their shape,
    # which is our own Locations::Address#to_s plus the country.
    def display
      [ @venue.address.to_s, country_name(city&.country_code) ].compact_blank.join(", ").presence
    end

    def coordinates
      pin = @venue.coordinates || city&.coordinates
      return fallback(nil, { "latitude" => 0.0, "longitude" => 0.0 }) unless pin

      { "latitude" => pin.latitude.to_f, "longitude" => pin.longitude.to_f }
    end

    # Locations::Mappable already resolves a curated link, falling back to one
    # derived from the coordinates.
    def maps
      {
        "google" => @venue.google_url,
        "apple" => @venue.apple_url,
        "openstreetmap" => @venue.openstreetmap_url
      }
    end

    # Our columns are non-null booleans, so `false` here cannot be told apart
    # from "we never checked". We only claim what is affirmatively true.
    def accessibility
      {
        "wheelchair" => @venue.accessibility_wheelchair.presence,
        "elevators" => @venue.accessibility_elevators.presence,
        "accessible_restrooms" => @venue.accessibility_restrooms.presence,
        "notes" => @venue.accessibility_notes
      }
    end

    def nearby
      {
        "public_transport" => @venue.nearby_public_transport,
        "parking" => @venue.nearby_parking
      }
    end
  end
end
