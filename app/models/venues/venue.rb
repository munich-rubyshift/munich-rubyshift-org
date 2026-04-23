class Venues::Venue < ApplicationRecord
  include FriendlyId
  friendly_id :name
end
