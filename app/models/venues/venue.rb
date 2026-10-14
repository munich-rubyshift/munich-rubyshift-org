class Venues::Venue < ApplicationRecord
  include StringForeignKeys
  include Locations::Mappable
  include Sluggable
  friendly_id :name

  belongs_to :address, class_name: "::Locations::Address", foreign_key: :locations_address_id, inverse_of: :venues
  belongs_to :map, class_name: "::Locations::Map", foreign_key: :locations_map_id, inverse_of: :venues, optional: true
  belongs_to :organization, class_name: "::Entities::Organization", foreign_key: :entities_organization_id, inverse_of: :venues, optional: true

  string_fk :locations_address_id, :locations_map_id, :entities_organization_id

  has_one :coordinates, through: :address

  has_many :events, class_name: "::Events::Event", foreign_key: :venues_venue_id, inverse_of: :venue

  def to_s
    name
  end
end
