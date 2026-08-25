class Events::Event < ApplicationRecord
  include FriendlyId
  include Events::SeriesDefaults
  friendly_id :title

  KINDS = %w[conference meetup retreat hackathon event workshop].freeze
  STATUSES = %w[cancelled postponed scheduled].freeze
  DATE_PRECISIONS = %w[year month day].freeze

  belongs_to :series, class_name: "Events::Series", foreign_key: :events_series_id, inverse_of: :events
  belongs_to :venue, class_name: "Venues::Venue", foreign_key: :venues_venue_id, inverse_of: :events

  has_many :participations, class_name: "Events::Participation", foreign_key: :events_event_id, inverse_of: :event
  has_many :participants, through: :participations, source: :person, class_name: "Entities::Person"

  has_many :cfps, class_name: "Events::CFP", foreign_key: :events_event_id, inverse_of: :event

  has_many :talks, class_name: "Talks::Talk", foreign_key: :events_event_id, inverse_of: :event

  has_many :sponsor_tiers, class_name: "Sponsors::SponsorTier", foreign_key: :events_event_id, inverse_of: :event

  validates :kind, inclusion: { in: KINDS }, allow_blank: true
  validates :status, inclusion: { in: STATUSES }, allow_blank: true
  validates :date_precision, inclusion: { in: DATE_PRECISIONS }, allow_blank: true

  def to_s
    title
  end
end
