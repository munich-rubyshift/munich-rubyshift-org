require "test_helper"

class EventsHelperTest < ActionView::TestCase
  test "event times are shown in Munich time, also during summer time" do
    summer = Events::Event.new(start_date: Date.new(2026, 9, 24), start_time: "16:30", end_date: Date.new(2026, 9, 24), end_time: "19:30")
    winter = Events::Event.new(start_date: Date.new(2026, 1, 22), start_time: "17:00", end_date: Date.new(2026, 1, 22), end_time: "20:00")

    assert_equal "18:30 – 21:30", event_time_range(summer)
    assert_equal "18:00 – 21:00", event_time_range(winter)
  end

  test "event without times has no time range" do
    assert_nil event_time_range(Events::Event.new(start_date: Date.new(2026, 1, 22)))
  end

  test "event date respects the date precision" do
    date = Date.new(2014, 3, 12)

    assert_equal "2014", event_date(Events::Event.new(start_date: date, end_date: date, date_precision: "year"))
    assert_equal "March 2014", event_date(Events::Event.new(start_date: date, end_date: date, date_precision: "month"))
    assert_equal "Wed, 12 Mar 2014", event_date(Events::Event.new(start_date: date, end_date: date, date_precision: "day"))
    assert_equal "Wed, 12 Mar 2014 – Thu, 13 Mar 2014", event_date(Events::Event.new(start_date: date, end_date: date + 1))
    assert_equal "Date to be announced", event_date(Events::Event.new)
  end

  test "event title falls back to kind and date" do
    assert_equal "Meetup 2026-01-22", event_title(Events::Event.new(kind: "meetup", start_date: Date.new(2026, 1, 22)))
    assert_equal "Rails Night", event_title(Events::Event.new(title: "Rails Night"))
  end
end
