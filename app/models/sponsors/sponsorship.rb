class Sponsors::Sponsorship < ApplicationRecord
  include StringForeignKeys
  include Sluggable
  friendly_id :name

  belongs_to :organization, class_name: "Entities::Organization", foreign_key: :entities_organization_id, inverse_of: :sponsorships

  belongs_to :sponsor_tier, class_name: "Sponsors::SponsorTier", foreign_key: :sponsors_sponsor_tier_id, inverse_of: :sponsorships

  string_fk :entities_organization_id, :sponsors_sponsor_tier_id

  # Reads the same as the `name` we store by hand, which is the point: the tier
  # and the sponsor are the whole of what a sponsorship is.
  def to_s
    "#{sponsor_tier} by #{organization}"
  end
end
