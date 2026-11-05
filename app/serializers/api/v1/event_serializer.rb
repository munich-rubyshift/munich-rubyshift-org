class Api::V1::EventSerializer < Api::V1::Serializer
  def included
    [ venue, address, *talks, *sponsor_tiers, *sponsorships, *involvements, *cfps ].compact.map(&:resource)
  end

  private

  def attributes
    # Stored values, without the fallbacks some readers add, like Events::SeriesDefaults.
    record.attributes.slice("title", "rubyevents_slug", "kind", "status", "attendance_mode", "last_edition",
      "start_date", "start_time", "end_date", "end_time", "date_precision", "announced_on", "published_at", "description",
      "tickets_url", "website", "twitter_username", "mastodon", "github", "meetup", "luma")
      .merge(participants_count: record.participations.size)
  end

  def relationships
    {
      series: { data: identify(record.series) },
      venue: { data: venue&.identifier },
      talks: { data: talks.map(&:identifier) },
      sponsor_tiers: { data: sponsor_tiers.map(&:identifier) },
      involvements: { data: involvements.map(&:identifier) },
      cfps: { data: cfps.map(&:identifier) }
    }
  end

  def venue
    Api::V1::VenueSerializer.new(record.venue) if record.venue
  end

  def address
    Api::V1::AddressSerializer.new(record.venue.address) if record.venue
  end

  def talks
    @talks ||= record.talks.includes(:speakers, :additional_resources).map { |talk| Api::V1::TalkSerializer.new(talk) }
  end

  def sponsor_tiers
    @sponsor_tiers ||= record.sponsor_tiers.includes(sponsorships: :organization).order(:level, :slug)
      .map { |tier| Api::V1::SponsorTierSerializer.new(tier) }
  end

  def sponsorships
    sponsor_tiers.flat_map(&:sponsorships).map { |sponsorship| Api::V1::SponsorshipSerializer.new(sponsorship) }
  end

  def involvements
    @involvements ||= record.involvements.includes(:entity)
      .sort_by { |involvement| [ involvement.role.to_s, involvement.entity_type, involvement.entity.slug ] }
      .map { |involvement| Api::V1::InvolvementSerializer.new(involvement) }
  end

  def cfps
    @cfps ||= record.cfps.map { |cfp| Api::V1::CFPSerializer.new(cfp) }
  end
end
