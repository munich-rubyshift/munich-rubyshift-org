class Locations::Map < ApplicationRecord
  has_many :venues, class_name: "Venues::Venue", foreign_key: :locations_map_id, inverse_of: :map

  def to_s
    [ google_url, apple_url, openstreetmap_url ].compact_blank.first.to_s
  end
end
