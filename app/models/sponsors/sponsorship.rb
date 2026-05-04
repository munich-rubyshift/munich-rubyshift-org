class Sponsors::Sponsorship < ApplicationRecord
  include FriendlyId
  friendly_id :name
  belongs_to :organization, class_name: "Entities::Organization", foreign_key: :entities_organization_id, inverse_of: :sponsorships
  belongs_to :sponsor_tier, class_name: "Sponsors::SponsorTier", foreign_key: :sponsors_sponsor_tier_id, inverse_of: :sponsorships
end
