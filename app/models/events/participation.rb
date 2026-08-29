class Events::Participation < ApplicationRecord
  include StringForeignKeys

  belongs_to :person, class_name: "Entities::Person", foreign_key: :entities_person_id, inverse_of: :participations

  belongs_to :event, class_name: "Events::Event", foreign_key: :events_event_id, inverse_of: :participations

  string_fk :entities_person_id, :events_event_id
end
