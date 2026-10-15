class Entities::Person < ApplicationRecord
  include Sluggable
  friendly_id :name

  has_many :participations, class_name: "Events::Participation", foreign_key: :entities_person_id, inverse_of: :person
  has_many :events, through: :participations, class_name: "Events::Event"

  has_many :speaker_talks, class_name: "Talks::SpeakerTalk", foreign_key: :entities_person_id, inverse_of: :speaker
  has_many :talks, class_name: "Talks::Talk", through: :speaker_talks
  scope :with_talks, -> { where.not(id: where.missing(:talks)) }

  # We store handles like rubyevents does, except for Mastodon, where only the
  # full URL names the server.
  def github_url
    "https://github.com/#{github_username}" if github_username.present?
  end

  def twitter_url
    "https://x.com/#{twitter_username}" if twitter_username.present?
  end

  def mastodon_url
    mastodon.presence
  end

  def bluesky_url
    "https://bsky.app/profile/#{bluesky_handle}" if bluesky_handle.present?
  end

  def linkedin_url
    "https://www.linkedin.com/in/#{linkedin_username}" if linkedin_username.present?
  end

  def speakerdeck_url
    "https://speakerdeck.com/#{speakerdeck_username}" if speakerdeck_username.present?
  end

  def to_s
    name
  end
end
