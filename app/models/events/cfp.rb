class Events::CFP < ApplicationRecord
  include FriendlyId
  friendly_id :slug_candidates

  DEFAULT_NAME = "Call for Proposals".freeze

  belongs_to :event, class_name: "Events::Event", foreign_key: :events_event_id, inverse_of: :cfps

  validates :name, presence: true

  # Most CFPs have the same name, so prepend the event name for better slugs.
  def slug_candidates
    [ [ event&.title, name ] ]
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
end
