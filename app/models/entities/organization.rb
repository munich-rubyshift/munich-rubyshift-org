class Entities::Organization < ApplicationRecord
  include FriendlyId
  friendly_id :name
end
