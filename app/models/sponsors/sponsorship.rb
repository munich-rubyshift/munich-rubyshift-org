class Sponsors::Sponsorship < ApplicationRecord
  include NormalizedStrings
  include RubyeventsData

  def self.serializer_relationships
    %w[organization]
  end

  belongs_to :organization, class_name: "Entities::Organization", foreign_key: :entities_organization_id, inverse_of: :sponsorships

  belongs_to :sponsor_tier, class_name: "Sponsors::SponsorTier", foreign_key: :sponsors_sponsor_tier_id, inverse_of: :sponsorships

  normalized_strings :entities_organization_id, :sponsors_sponsor_tier_id, :badge

  def to_s
    "#{sponsor_tier} by #{organization}"
  end
end
