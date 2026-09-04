class Locations::Coordinates < ApplicationRecord
  # Centroid coordinates belongs to exactly one city. Addresses may share coordinates.
  has_one :city, class_name: "Locations::City", foreign_key: :locations_coordinates_id, inverse_of: :coordinates
  # autosave: false - geocoding assigns an unsaved coordinates record to an
  # address, and without this both sides would try to save each other before
  # the foreign key exists.
  has_many :addresses, class_name: "Locations::Address", foreign_key: :locations_coordinates_id, inverse_of: :coordinates, autosave: false

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

  # "N48.11 E11.60". A minus sign says the same thing, but a hemisphere letter is
  # how coordinates are written wherever people read them.
  def to_s
    return "" unless latitude && longitude

    "#{hemisphere(latitude, "N", "S")} #{hemisphere(longitude, "E", "W")}"
  end

  private

  # A fixed width keeps a column of these aligned, which is the whole point of
  # padding degrees that need no padding. The decimals are cut rather than
  # rounded, so the reading never names a spot the record does not hold.
  def hemisphere(degrees, positive, negative)
    "#{degrees.negative? ? negative : positive}#{format("%05.2f", degrees.abs.truncate(2))}"
  end
end
