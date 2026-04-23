class Talks::SpeakerTalk < ApplicationRecord
  belongs_to :talks_talk
  belongs_to :entities_person
end
