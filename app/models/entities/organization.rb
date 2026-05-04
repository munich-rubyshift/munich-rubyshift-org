class Entities::Organization < ApplicationRecord
  include FriendlyId
  friendly_id :name

  has_many :sponsorships, class_name: "Sponsors::Sponsorship", foreign_key: :entities_organization_id, inverse_of: :organization

  has_many :sponsor_tiers, class_name: "Sponsors::SponsorTier", through: :sponsorships

  def to_s
    name
  end
end
