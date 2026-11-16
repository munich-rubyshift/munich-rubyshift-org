# The sponsorships as we list them: the stored ones, plus each event's host in its "Meetup Host" tier
# (see Sponsors::ListedSponsorTier).
class Sponsors::ListedSponsorship < Sponsors::Sponsorship
  self.table_name = "sponsors_listed_sponsorships"

  belongs_to :organization, class_name: "Entities::Organization", foreign_key: :entities_organization_id, inverse_of: :listed_sponsorships

  belongs_to :sponsor_tier, class_name: "Sponsors::ListedSponsorTier", foreign_key: :sponsors_sponsor_tier_id, inverse_of: :sponsorships

  def readonly?
    true
  end
end
