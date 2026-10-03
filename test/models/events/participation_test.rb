require "test_helper"

class Events::ParticipationTest < ActiveSupport::TestCase
  test "reads as the person and the event they came to" do
    participation = events_participations(:one)
    participation.person.name = "Hans Schnedlitz"
    participation.event.kind = "meetup"
    participation.event.start_date = Date.new(2026, 4, 23)

    assert_equal "Hans Schnedlitz @ Meetup 2026-04-23", participation.to_s
  end
end
