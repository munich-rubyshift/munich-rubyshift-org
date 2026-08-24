class Events::Series < ApplicationRecord
  include FriendlyId
  friendly_id :name
end
