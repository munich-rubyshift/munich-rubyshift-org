class Venues::Venue < ApplicationRecord
  include Locations::Mappable
  include FriendlyId
  friendly_id :name

  belongs_to :address, class_name: "::Locations::Address", foreign_key: :locations_address_id, inverse_of: :venues
  belongs_to :map, class_name: "::Locations::Map", foreign_key: :locations_map_id, inverse_of: :venues, optional: true

  has_one :coordinates, through: :address

  has_many :events, class_name: "::Events::Event", foreign_key: :venues_venue_id, inverse_of: :venue

  def to_s
    name
  end
end
