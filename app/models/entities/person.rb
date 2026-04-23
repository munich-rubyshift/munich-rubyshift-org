class Entities::Person < ApplicationRecord
  include FriendlyId
  friendly_id :name
end
