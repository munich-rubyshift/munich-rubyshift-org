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
    super || event&.start_date&.prev_day
  end

  # A CFP yet to open counts as open, too.
  def closed?
    close_date.present? && close_date.before?(Date.current)
  end

  # Most CFPs have the same name, so prepend the event's slug, which is unique.
  # Avo builds a new event's CFP before saving the event, so wait for its slug.
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
