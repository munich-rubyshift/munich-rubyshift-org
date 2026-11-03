class Api::V1::SponsorshipSerializer < Api::V1::Serializer
  # Sponsorships have no slug, so their id joins the slugs around them.
  def identifier
    tier = record.sponsor_tier
    { type: "sponsorships", id: [ tier.event.slug, tier.name&.parameterize, record.organization.slug ].compact_blank.join("-") }
  end

  private

  def attributes
    { badge: record.badge }
  end

  def relationships
    { organization: { data: identify(record.organization) } }
  end
end
