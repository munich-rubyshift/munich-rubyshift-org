class Talks::SpeakerTalk < ApplicationRecord
  include StringForeignKeys

  belongs_to :talk, class_name: "Talks::Talk", foreign_key: :talks_talk_id, inverse_of: :speaker_talks

  belongs_to :speaker, class_name: "Entities::Person", foreign_key: :entities_person_id, inverse_of: :speaker_talks

  string_fk :talks_talk_id, :entities_person_id

  def to_s
    "\"#{talk}\" by #{speaker}"
  end
end
