require "test_helper"

class Events::ParticipationTest < ActiveSupport::TestCase
  test "reads as the person and the event they came to" do
    participation = events_participations(:one)
    participation.person.name = "Hans Schnedlitz"
    participation.event.title = "Meetup April 2026"

    assert_equal "Hans Schnedlitz @ Meetup April 2026", participation.to_s
  end
end
