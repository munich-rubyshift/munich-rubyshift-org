require "test_helper"

class Sponsors::SponsorshipTest < ActiveSupport::TestCase
  test "reads as the tier and who sponsored it" do
    sponsorship = sponsors_sponsorships(:one)
    sponsorship.sponsor_tier.name = "Location & Drinks"
    sponsorship.organization.name = "Freeletics"

    assert_equal "Location & Drinks by Freeletics", sponsorship.to_s
  end
end
