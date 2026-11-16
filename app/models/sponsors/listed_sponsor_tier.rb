# The sponsor tiers as we list them: the stored ones, plus a "Meetup Host" tier for each event that an
# organization hosts at its venue (the events_meetup_hosts view). That tier and its sponsorship take ids
# derived from the event's: UUID version 8 instead of the stored records' 4, so they never clash.
class Sponsors::ListedSponsorTier < Sponsors::SponsorTier
  self.table_name = "sponsors_listed_sponsor_tiers"

  belongs_to :event, class_name: "Events::Event", foreign_key: :events_event_id, inverse_of: :listed_sponsor_tiers

  has_many :sponsorships, class_name: "Sponsors::ListedSponsorship", foreign_key: :sponsors_sponsor_tier_id, inverse_of: :sponsor_tier

  def readonly?
    true
  end
end
