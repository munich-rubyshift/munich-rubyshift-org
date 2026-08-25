class Events::CFP < ApplicationRecord
  include FriendlyId
  friendly_id :name

  belongs_to :event, class_name: "Events::Event", foreign_key: :events_event_id, inverse_of: :cfps
end
