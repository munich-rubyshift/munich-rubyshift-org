class Talks::Talk < ApplicationRecord
  include StringForeignKeys
  include Sluggable
  friendly_id :slug_candidates

  # The kinds rubyevents knows, in their order.
  KINDS = %w[
    keynote talk lightning_talk open_mic announcement city_pitch panel workshop gameshow podcast
    q_and_a discussion fireside_chat interview award demo trailer recap aftermovie intro outro
  ].freeze

  belongs_to :event, class_name: "Events::Event", foreign_key: :events_event_id, inverse_of: :talks

  string_fk :events_event_id

  has_many :additional_resources, -> { order(:kind, :name) },
    class_name: "Talks::AdditionalResource", foreign_key: :talks_talk_id, inverse_of: :talk

  has_many :speaker_talks, class_name: "Talks::SpeakerTalk", foreign_key: :talks_talk_id, inverse_of: :talk
  has_many :speakers, class_name: "Entities::Person", through: :speaker_talks

  validates :title, presence: true
  validates :kind, presence: true, inclusion: { in: KINDS, allow_blank: true }

  validates :language_code, presence: true, inclusion: { in: Language::NAMES.keys, allow_blank: true }

  validates :position, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :events_event_id }
  before_validation :append_to_event, if: -> { position.nil? }

  scope :by_running_order, -> { order(:position) }

  # Distinguish repeated titles by date
  def slug_candidates
    [
      title,
      ([ title, event.start_date ] if event&.start_date)
    ].compact
  end

  def language
    Language::NAMES[language_code]
  end

  # We announce talks in posts of their own, but a blank date means the talk
  # was announced together with its event.
  def announced_on
    super || event&.announced_on
  end

  def to_s
    title
  end

  private

  def append_to_event
    self.position = Talks::Talk.where(events_event_id: events_event_id).where.not(id: id).maximum(:position).to_i + 1
  end
end
