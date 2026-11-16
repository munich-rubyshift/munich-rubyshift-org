class Api::V1::EventSerializer < Api::V1::Serializer
  attribute :slug
  attribute :title
  attribute :kind
  attribute :status
  attribute :attendance_mode
  attribute :start_date
  attribute :start_time
  attribute :end_date
  attribute :end_time
  attribute :date_precision
  attribute :announced_on
  attribute :description
  attribute :tickets_url
  attribute :website
  attribute :twitter_username
  attribute :mastodon
  attribute :github
  attribute :meetup
  attribute :luma

  attribute :participants_count do
    record.participations.size
  end

  def included
    [ venue, address, *talks, *sponsor_tiers, *sponsorships, *involvements, *cfps ].compact
  end

  private

  def relationships
    {
      series: { data: series.identifier },
      venue: { data: venue&.identifier },
      talks: { data: talks.map(&:identifier) },
      sponsor_tiers: { data: sponsor_tiers.map(&:identifier) },
      involvements: { data: involvements.map(&:identifier) },
      cfps: { data: cfps.map(&:identifier) }
    }
  end

  def series
    Api::V1::SeriesSerializer.new(record.series, rubyevents:)
  end

  def venue
    Api::V1::VenueSerializer.new(record.venue, rubyevents:) if record.venue
  end

  def address
    Api::V1::AddressSerializer.new(record.venue.address, rubyevents:) if record.venue
  end

  def talks
    @talks ||= record.talks.includes(:speakers, :additional_resources).map { |talk| Api::V1::TalkSerializer.new(talk, rubyevents:) }
  end

  def sponsor_tiers
    @sponsor_tiers ||= record.listed_sponsor_tiers.includes(sponsorships: :organization).order(:level, :slug)
      .map { |tier| Api::V1::SponsorTierSerializer.new(tier, rubyevents:) }
  end

  def sponsorships
    sponsor_tiers.flat_map(&:sponsorships)
  end

  def involvements
    @involvements ||= record.involvements.includes(:entity)
      .sort_by { |involvement| [ involvement.role.to_s, involvement.entity_type, involvement.entity.slug ] }
      .map { |involvement| Api::V1::InvolvementSerializer.new(involvement, rubyevents:) }
  end

  def cfps
    @cfps ||= record.cfps.map { |cfp| Api::V1::CFPSerializer.new(cfp, rubyevents:) }
  end
end
