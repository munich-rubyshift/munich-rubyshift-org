require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  test "sorts records by what they read as, blanks last" do
    events_series(:one).update_columns(name: "Rails Munich")
    events_series(:two).update_columns(name: "")
    munich_ruby = Events::Series.create!(name: "Munich Ruby")

    assert_equal [ munich_ruby, events_series(:one), events_series(:two) ], Events::Series.by_to_s.to_a
  end

  test "sorts records by what they read as, ignoring case" do
    events_series(:one).update_columns(name: "Rails Munich")
    events_series(:two).update_columns(name: "munich.rb")

    assert_equal [ events_series(:two), events_series(:one) ], Events::Series.by_to_s.to_a
  end

  test "sorts records with the same reading in id order" do
    events_series(:one).update_columns(name: "Munich Ruby")
    events_series(:two).update_columns(name: "Munich Ruby")

    assert_equal Events::Series.order(:id).to_a, Events::Series.by_to_s.to_a
  end

  test "sorts records by what their association reads as" do
    events_series(:one).update_columns(name: "Rails Munich")
    events_series(:two).update_columns(name: "Munich Ruby")

    assert_equal [ events_events(:two), events_events(:one) ], Events::Event.by_to_s(on: :series).to_a
  end

  test "stays a relation to chain onto" do
    events_series(:one).update_columns(name: "Rails Munich")
    events_series(:two).update_columns(name: "Munich Ruby")

    assert_equal [ events_series(:one), events_series(:two) ], Events::Series.by_to_s.reverse_order.to_a
    assert_equal [ events_series(:one) ], Events::Series.where(id: events_series(:one)).by_to_s.to_a
  end

  test "orders entries without an associated record last" do
    events_series(:one).update_columns(name: "Rails Munich")
    venueless = events_events(:two)
    venueless.update_columns(venues_venue_id: nil)

    events = Events::Event.left_joins(:venue).merge(Venues::Venue.by_to_s)

    assert_equal events_events(:one), events.first
    assert_equal venueless, events.last
  end

  test "keeps every record when there is nothing to sort by" do
    Events::Event.update_all(venues_venue_id: nil)
    Venues::Venue.delete_all

    assert_equal Events::Event.count, Events::Event.left_joins(:venue).merge(Venues::Venue.by_to_s).count
  end
end
