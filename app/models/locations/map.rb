class Locations::Map < ApplicationRecord
  include NormalizedStrings

  has_many :venues, class_name: "Venues::Venue", foreign_key: :locations_map_id, inverse_of: :map

  normalized_strings :apple_url, :google_url, :openstreetmap_url

  def to_s
    [ google_url, apple_url, openstreetmap_url ].compact_blank.first.to_s
  end
end
