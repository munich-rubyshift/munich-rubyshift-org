class Events::Series < ApplicationRecord
  include NormalizedStrings
  include Sluggable
  friendly_id :name

  KINDS = %w[conference meetup retreat hackathon event podcast online organisation workshop].freeze
  FREQUENCIES = %w[yearly monthly weekly irregular biweekly biyearly quarterly].freeze
  TIME_ZONES = TZInfo::Timezone.all_identifiers.freeze

  has_many :events, class_name: "Events::Event", foreign_key: :events_series_id, inverse_of: :series

  normalized_strings :bluesky_handle, :default_country_code, :description, :discord, :facebook, :frequency,
    :github, :guild, :kind, :language_code, :linkedin, :luma, :mastodon, :meetup, :name, :rubyevents_slug,
    :time_zone, :twitter_username, :website

  validates :kind, inclusion: { in: KINDS }, allow_blank: true
  validates :frequency, inclusion: { in: FREQUENCIES }, allow_blank: true
  validates :language_code, inclusion: { in: Language::NAMES.keys }, allow_blank: true
  validates :time_zone, inclusion: { in: TIME_ZONES }

  def language
    Language::NAMES[language_code]
  end

  def to_s
    name.to_s
  end
end
