class Locations::Address < ApplicationRecord
  include FriendlyId
  friendly_id :street
  belongs_to :locations_city
end
