class Talks::Talk < ApplicationRecord
  include FriendlyId
  friendly_id :title
  belongs_to :event, class_name: "Events::Event", foreign_key: :events_event_id, inverse_of: :talks

  def to_s
    title
  end
end
