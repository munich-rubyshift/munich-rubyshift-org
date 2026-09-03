class Events::Event < ApplicationRecord
  include StringForeignKeys
  include Sluggable
  include Events::SeriesDefaults
  friendly_id :slug_candidates

  KINDS = %w[conference meetup retreat hackathon event workshop].freeze
  STATUSES = %w[cancelled postponed scheduled].freeze
  DATE_PRECISIONS = %w[year month day].freeze
  ATTENDANCE_MODES = %w[in_person hybrid online].freeze

  belongs_to :series, class_name: "Events::Series", foreign_key: :events_series_id, inverse_of: :events
  belongs_to :venue, class_name: "Venues::Venue", foreign_key: :venues_venue_id, inverse_of: :events, optional: true

  string_fk :events_series_id, :venues_venue_id

  has_many :participations, class_name: "Events::Participation", foreign_key: :events_event_id, inverse_of: :event
  has_many :participants, through: :participations, source: :person, class_name: "Entities::Person"

  has_many :cfps, class_name: "Events::CFP", foreign_key: :events_event_id, inverse_of: :event

  has_many :involvements, class_name: "Events::Involvement", foreign_key: :events_event_id, inverse_of: :event

  has_many :talks, class_name: "Talks::Talk", foreign_key: :events_event_id, inverse_of: :event

  has_many :sponsor_tiers, class_name: "Sponsors::SponsorTier", foreign_key: :events_event_id, inverse_of: :event

  validates :kind, inclusion: { in: KINDS }, allow_blank: true
  validates :status, inclusion: { in: STATUSES }, allow_blank: true
  validates :date_precision, inclusion: { in: DATE_PRECISIONS }, allow_blank: true
  validates :attendance_mode, presence: true, inclusion: { in: ATTENDANCE_MODES, allow_blank: true }
  validates :venue, presence: true, if: :venue_required?
  validates :venue, absence: true, if: :online?

  def slug_candidates
    [
      ([ kind, start_date ] if start_date),
      ([ kind, title ] if title.present?),
      kind
    ].compact
  end

  def cancelled?
    status == "cancelled"
  end

  # A hybrid event also happens in person, so only "online" rules out a venue.
  def online?
    attendance_mode == "online"
  end

  # Only an event people can actually show up to needs a venue.
  def venue_required?
    !online? && !cancelled?
  end

  def to_s
    title
  end
end
