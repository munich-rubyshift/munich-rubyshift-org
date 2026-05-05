class Events::Event < ApplicationRecord
  include FriendlyId
  friendly_id :title

  belongs_to :venue, class_name: "Venues::Venue", foreign_key: :venues_venue_id, inverse_of: :events

  has_many :participations, class_name: "Events::Participation", foreign_key: :events_event_id, inverse_of: :event
  has_many :participants, through: :participations, source: :person, class_name: "Entities::Person"

  has_many :talks, class_name: "Talks::Talk", foreign_key: :events_event_id, inverse_of: :event

  has_many :sponsor_tiers, class_name: "Sponsors::SponsorTier", foreign_key: :events_event_id, inverse_of: :event

  def to_s
    title
  end
end
