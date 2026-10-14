require "test_helper"

class Venues::VenueTest < ActiveSupport::TestCase
  test "a venue needs no organization" do
    venue = venues_venues(:one)
    venue.organization = nil

    assert venue.valid?
  end
end
