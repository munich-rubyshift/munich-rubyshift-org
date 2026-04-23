class Talks::Talk < ApplicationRecord
  include FriendlyId
  friendly_id :title
  belongs_to :events_event, class_name: "Events::Event"
end
