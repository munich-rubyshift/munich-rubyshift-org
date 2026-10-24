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

  test "closes the day before its event without a close date" do
    cfp = Events::CFP.new(event: @event)

    assert_equal Date.new(2026, 11, 11), cfp.close_date
    assert_nil cfp.read_attribute(:close_date)
  end

  test "keeps a close date of its own" do
    assert_equal Date.new(2026, 11, 1), Events::CFP.new(event: @event, close_date: "2026-11-01").close_date
  end

  test "follows its event to a new date" do
    cfp = Events::CFP.create!(event: @event, name: "Call for Proposals")
    @event.update_columns(start_date: "2026-12-03", end_date: "2026-12-03")

    assert_equal Date.new(2026, 12, 2), cfp.reload.close_date
  end

  test "stays open-ended for an undated event" do
    @event.update_columns(start_date: nil, end_date: nil)

    assert_nil Events::CFP.new(event: @event).close_date
  end

  test "may close the day it opens" do
    cfp = Events::CFP.new(event: @event, name: "Call for Proposals", open_date: "2026-11-11")

    assert cfp.valid?, cfp.errors.full_messages.to_sentence
  end

  test "can't close before it opens" do
    cfp = Events::CFP.new(event: @event, name: "Call for Proposals", open_date: "2026-11-05", close_date: "2026-11-04")

    assert_not cfp.valid?
    assert_includes cfp.errors[:close_date], "can't be before the open date"
  end

  test "can't open after the day before its event without a close date" do
    cfp = Events::CFP.new(event: @event, name: "Call for Proposals", open_date: "2026-11-12")

    assert_not cfp.valid?
    assert_includes cfp.errors[:close_date], "defaults to the day before the event, which is before the open date"
  end

  test "is upcoming until it opens" do
    cfp = Events::CFP.new(event: @event, open_date: "2026-11-05")

    travel_to Date.new(2026, 11, 4)
    assert_equal "upcoming", cfp.state

    travel_to Date.new(2026, 11, 5)
    assert_equal "open", cfp.state
  end

  test "is open through the day before its event without a close date" do
    cfp = Events::CFP.new(event: @event, open_date: "2026-10-01")

    travel_to Date.new(2026, 11, 11)
    assert_equal "open", cfp.state

    travel_to Date.new(2026, 11, 12)
    assert_equal "closed", cfp.state
  end

  test "is closed after a close date of its own" do
    cfp = Events::CFP.new(event: @event, open_date: "2026-10-01", close_date: "2026-10-31")

    travel_to Date.new(2026, 11, 1)
    assert_equal "closed", cfp.state
  end

  test "stays open without any dates" do
    @event.update_columns(start_date: nil, end_date: nil)

    travel_to Date.new(2030, 1, 1)
    assert_equal "open", Events::CFP.new(event: @event).state
  end
end
