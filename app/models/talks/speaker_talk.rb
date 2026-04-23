class Talks::SpeakerTalk < ApplicationRecord
  belongs_to :talks_talk, class_name: "Talks::Talk"
  belongs_to :entities_person, class_name: "Entities::Person"
end
