class Events::CFP < ApplicationRecord
  include FriendlyId
  friendly_id :name
  belongs_to :events_event
end
