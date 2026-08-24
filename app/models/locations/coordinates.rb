class Locations::Coordinates < ApplicationRecord
  # Centroid coordinates belongs to exactly one city. Venues and addresses may share coordinates.
  has_one :city, class_name: "Locations::City", foreign_key: :locations_coordinates_id, inverse_of: :coordinates
  has_many :venues, class_name: "Venues::Venue", foreign_key: :locations_coordinates_id, inverse_of: :coordinates

  # Fallbacks for Locations::Map, which only stores curated links.
  def google_url
    "https://www.google.com/maps/search/?api=1&query=#{latitude},#{longitude}"
  end

  def apple_url
    "https://maps.apple.com/?ll=#{latitude},#{longitude}"
  end

  def openstreetmap_url
    "https://www.openstreetmap.org/?mlat=#{latitude}&mlon=#{longitude}"
  end

  def to_s
    "#{latitude}, #{longitude}"
  end
end
