require "test_helper"

class Events::CFPTest < ActiveSupport::TestCase
  setup do
    @event = events_events(:one)
    @event.update_columns(slug: "meetup-2026-11-12", start_date: "2026-11-12", end_date: "2026-11-12")
    Events::CFP.where(event: @event).delete_all
  end

  test "is slugged after its event" do
    cfp = Events::CFP.create!(event: @event, name: "Call for Proposals")

    assert_equal "meetup-2026-11-12-call-for-proposals", cfp.slug
  end

  test "requires a unique (case-insensitive) name within its event" do
    Events::CFP.create!(event: @event, name: "Call for Proposals")
    cfp = Events::CFP.new(event: @event, name: "call for proposals")

    assert_not cfp.valid?
    assert_includes cfp.errors[:name], "has already been taken"
  end

  test "may share its name with another event's CFP" do
    Events::CFP.create!(event: events_events(:two), name: "Call for Proposals")
    cfp = Events::CFP.new(event: @event, name: "Call for Proposals")

    assert cfp.valid?, cfp.errors.full_messages.to_sentence
  end
end
