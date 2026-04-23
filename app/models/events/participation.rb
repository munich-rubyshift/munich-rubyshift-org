class Events::Participation < ApplicationRecord
  belongs_to :entities_person
  belongs_to :events_event
end
