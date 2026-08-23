class Locations::Address < ApplicationRecord
  include FriendlyId
  friendly_id :street

  belongs_to :city, class_name: "Locations::City", foreign_key: :locations_city_id, inverse_of: :addresses

  def to_s
    [ street, [ zip_code, city&.name ].compact_blank.join(" ") ].compact_blank.join(", ")
  end
end
