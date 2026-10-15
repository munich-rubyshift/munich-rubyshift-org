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

  test "waits for a new event's slug" do
    event = Events::Event.new(kind: "meetup", start_date: Date.new(2026, 11, 19), end_date: Date.new(2026, 11, 19),
      series: @event.series, venue: @event.venue, attendance_mode: "in_person")
    cfp = event.cfps.build(name: "Call for Proposals")

    assert cfp.valid?, cfp.errors.full_messages.to_sentence
    assert_nil cfp.slug

    event.save!

    assert_equal "meetup-2026-11-19-call-for-proposals", cfp.reload.slug
  end

  test "requires a name of its own within its event, ignoring case" do
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
