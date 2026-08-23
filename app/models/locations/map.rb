class Locations::Map < ApplicationRecord
  def to_s
    [ google_url, apple_url, openstreetmap_url ].compact_blank.first.to_s
  end
end
