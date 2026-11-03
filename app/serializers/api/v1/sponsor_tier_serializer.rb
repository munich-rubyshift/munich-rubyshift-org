class Api::V1::SponsorTierSerializer < Api::V1::Serializer
  def sponsorships
    record.sponsorships.sort_by(&:slug)
  end

  private

  def attributes
    record.slice(:name, :rubyevents_slug, :level, :description)
  end

  def relationships
    { sponsorships: { data: sponsorships.map { |sponsorship| identify(sponsorship) } } }
  end
end
