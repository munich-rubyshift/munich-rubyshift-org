class Api::V1::SponsorTierSerializer < Api::V1::Serializer
  attribute :slug
  attribute :name
  attribute :level
  attribute :description

  def sponsorships
    record.sponsorships.sort_by { |sponsorship| sponsorship.organization.slug }
      .map { |sponsorship| Api::V1::SponsorshipSerializer.new(sponsorship, rubyevents:) }
  end

  private

  def relationships
    { sponsorships: { data: sponsorships.map(&:identifier) } }
  end
end
