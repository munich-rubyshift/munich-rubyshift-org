class Events::Participation < ApplicationRecord
  belongs_to :entities_person, class_name: "Entities::Person"
  belongs_to :events_event, class_name: "Events::Event"
end
