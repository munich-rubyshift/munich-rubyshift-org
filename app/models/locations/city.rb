class Locations::City < ApplicationRecord
  include FriendlyId
  friendly_id :name

  belongs_to :coordinates, class_name: "Locations::Coordinates", foreign_key: :locations_coordinates_id, inverse_of: :city

  has_many :addresses, class_name: "Locations::Address", foreign_key: :locations_city_id, inverse_of: :city

  def to_s
    name
  end
end
