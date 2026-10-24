class Events::CFP < ApplicationRecord
  include StringForeignKeys
  include Sluggable
  friendly_id :slug_candidates

  DEFAULT_NAME = "Call for Proposals".freeze

  belongs_to :event, class_name: "Events::Event", foreign_key: :events_event_id, inverse_of: :cfps

  string_fk :events_event_id

  validates :name, presence: true, uniqueness: { scope: :events_event_id, case_sensitive: false }
  validate :closes_after_it_opens

  scope :by_open_date, -> { order(:open_date, :name) }

  # A blank close date closes the CFP the day before its event.
  def close_date
    super || implied_close_date
  end

  def implied_close_date
    event&.start_date&.prev_day
  end

  def state
    if open_date&.future?
      "upcoming"
    elsif close_date&.past?
      "closed"
    else
      "open"
    end
  end

  # FriendlyId sets slugs `before_validation` and simply skips if this is `nil`.
  # We validate twice:
  # - During `Event#build_default_cfp` where the event has no slug yet.
  # - During the event's association autosave, where the event already has a slug.
  def slug_candidates
    [ [ event.slug, name ] ] if event&.slug
  end

  def url
    external_url.presence || page_url
  end

  # Absolute during a Parklife build, where parklife-rails sets
  # default_url_options from --base. Relative everywhere else.
  def page_url
    helpers = Rails.application.routes.url_helpers

    if Rails.application.default_url_options[:host].present?
      helpers.events_cfp_url(self)
    else
      helpers.events_cfp_path(self)
    end
  end

  def to_s
    name
  end

  private

  # Counts the implied close date too, so moving the event to an earlier date
  # can turn a CFP invalid.
  def closes_after_it_opens
    return unless open_date && close_date && close_date < open_date

    if read_attribute(:close_date)
      errors.add(:close_date, "can't be before the open date")
    else
      errors.add(:close_date, "defaults to the day before the event, which is before the open date")
    end
  end
end
