class Locations::City < ApplicationRecord
  include FriendlyId
  friendly_id :name
  belongs_to :locations_coordinates
end
