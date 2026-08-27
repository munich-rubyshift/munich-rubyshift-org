class Locations::City < ApplicationRecord
  include FriendlyId
  include Locations::Geocodable
  friendly_id :name

  GEOCODED_ATTRIBUTES = %w[name state_code country_code].freeze

  belongs_to :coordinates, class_name: "Locations::Coordinates", foreign_key: :locations_coordinates_id, inverse_of: :city, autosave: true

  has_many :addresses, class_name: "Locations::Address", foreign_key: :locations_city_id, inverse_of: :city

  def to_s
    name
  end

  private

  def geocoding_query
    [ name, state_code, country_code ].compact_blank.join(", ")
  end
end
