class Locations::Address < ApplicationRecord
  include FriendlyId
  include Locations::Geocodable
  friendly_id :street

  GEOCODED_ATTRIBUTES = %w[street zip_code locations_city_id].freeze

  belongs_to :city, class_name: "Locations::City", foreign_key: :locations_city_id, inverse_of: :addresses
  belongs_to :coordinates, class_name: "Locations::Coordinates", foreign_key: :locations_coordinates_id, inverse_of: :addresses, autosave: true

  has_many :venues, class_name: "Venues::Venue", foreign_key: :locations_address_id, inverse_of: :address

  def to_s
    [ street, [ zip_code, city&.name ].compact_blank.join(" ") ].compact_blank.join(", ")
  end

  private

  # Built from the individual fields rather than #to_s, so changing the display
  # format cannot silently change what we geocode.
  def geocoding_query
    [ street, [ zip_code, city&.name ].compact_blank.join(" "), city&.state_code, city&.country_code ].compact_blank.join(", ")
  end
end
