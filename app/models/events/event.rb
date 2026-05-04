class Events::Event < ApplicationRecord
  include FriendlyId
  friendly_id :title

  belongs_to :venue, class_name: "Venues::Venue", foreign_key: :venues_venue_id, inverse_of: :events
  has_many :participations, class_name: "Events::Participation", foreign_key: :events_event_id, inverse_of: :event
  has_many :participants, through: :participations, source: :person, class_name: "Entities::Person"

  def to_s
    title
  end
end
