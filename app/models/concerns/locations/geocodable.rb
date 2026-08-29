module Locations
  # Including models have to define GEOCODED_ATTRIBUTES and #geocoding_query,
  # and belong to :coordinates via locations_coordinates_id.
  module Geocodable
    extend ActiveSupport::Concern

    included do
      before_validation :geocode_coordinates, if: :needs_geocoding?
    end

    private

    def needs_geocoding?
      assigned_by_hand = locations_coordinates_id_changed? && locations_coordinates_id.present?
      return false if assigned_by_hand

      coordinates.blank? || changed.intersect?(self.class::GEOCODED_ATTRIBUTES)
    end

    def geocode_coordinates
      result = Geocoder.search(geocoding_query).first

      if result
        # Create a new record rather than updating in place, because coordinates may be shared with another record.
        self.coordinates = Locations::Coordinates.new(latitude: result.latitude, longitude: result.longitude)
      else
        errors.add(:coordinates, "could not be geocoded from #{geocoding_query.inspect}")
      end
    end
  end
end
