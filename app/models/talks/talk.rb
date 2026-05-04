class Talks::Talk < ApplicationRecord
  include FriendlyId
  friendly_id :title

  belongs_to :event, class_name: "Events::Event", foreign_key: :events_event_id, inverse_of: :talks

  has_many :speaker_talks, class_name: "Talks::SpeakerTalk", foreign_key: :talks_talk_id, inverse_of: :talk
  has_many :speakers, class_name: "Entities::Person", through: :speaker_talks

  def to_s
    title
  end
end
