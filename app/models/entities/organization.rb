class Entities::Organization < ApplicationRecord
  include Sluggable
  friendly_id :slug_candidates

  has_many :sponsorships, class_name: "Sponsors::Sponsorship", foreign_key: :entities_organization_id, inverse_of: :organization
  has_many :sponsor_tiers, class_name: "Sponsors::SponsorTier", through: :sponsorships

  has_many :venues, class_name: "Venues::Venue", foreign_key: :entities_organization_id, inverse_of: :organization

  has_many :hosted_events, -> { not_cancelled }, through: :venues, source: :events

  scope :meetup_hosts, -> {
    joins(:hosted_events)
      .group(:id)
      .order(Arel.sql("MAX(events_events.start_date) DESC NULLS LAST, LOWER(entities_organizations.name), entities_organizations.id"))
  }

  # The brand changes less often than the legal name, so it makes the steadier URL.
  def slug_candidates
    [ name, legal_name ]
  end

  # rubyevents.org slugs with plain `parameterize`, so "ä" becomes "a" there
  # rather than "ae" as in our own slugs.
  def rubyevents_slug
    I18n::Backend::Transliterator.get.transliterate(name.to_s).parameterize
  end

  def rubyevents_url
    "https://www.rubyevents.org/organizations/#{rubyevents_slug}" if rubyevents_slug.present?
  end

  def to_s
    name
  end
end
