class Api::V1::SponsorTierSerializer < Api::V1::Serializer
  def sponsorships
    record.sponsorships.sort_by { |sponsorship| sponsorship.organization.slug }
      .map { |sponsorship| Api::V1::SponsorshipSerializer.new(sponsorship) }
  end

  private

  def attributes
    record.slice(:name, :rubyevents_slug, :level, :description)
  end

  def relationships
    { sponsorships: { data: sponsorships.map(&:identifier) } }
  end
end
