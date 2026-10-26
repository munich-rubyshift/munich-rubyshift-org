class Events::Series < ApplicationRecord
  include NormalizedStrings
  include Sluggable
  friendly_id :name

  KINDS = %w[conference meetup retreat hackathon event podcast online organisation workshop].freeze
  FREQUENCIES = %w[yearly monthly weekly irregular biweekly biyearly quarterly].freeze

  has_many :events, class_name: "Events::Event", foreign_key: :events_series_id, inverse_of: :series

  normalized_strings :bluesky_handle, :default_country_code, :description, :discord, :facebook, :frequency,
    :github, :guild, :kind, :language_code, :linkedin, :luma, :mastodon, :meetup, :name, :rubyevents_slug,
    :twitter_username, :website

  validates :kind, inclusion: { in: KINDS }, allow_blank: true
  validates :frequency, inclusion: { in: FREQUENCIES }, allow_blank: true
  validates :language_code, inclusion: { in: Language::NAMES.keys }, allow_blank: true

  def language
    Language::NAMES[language_code]
  end

  def to_s
    name.to_s
  end
end
