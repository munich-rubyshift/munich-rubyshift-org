require "test_helper"

# Sorting is easy to get subtly wrong in ways the resource file does not show,
# so these read back the order the index rendered. The lists that open on an
# order are asked for none, the rest are asked for one explicitly.
class AvoIndexSortingTest < ActionDispatch::IntegrationTest
  test "a column can be sorted by what its belongs_to shows" do
    venues_venues(:one).update!(slug: "second", map: locations_maps(:one))
    venues_venues(:two).update!(slug: "first", map: locations_maps(:two))
    locations_maps(:one).update!(google_url: "https://example.com/zzz")
    locations_maps(:two).update!(google_url: "https://example.com/aaa")

    assert_equal %w[first second], index_order("venues_venues", sort_by: :map, sort_direction: :asc)
    assert_equal %w[second first], index_order("venues_venues", sort_by: :map, sort_direction: :desc)
  end

  test "a missing belongs_to sorts last in either direction" do
    venues_venues(:one).update!(slug: "mapped", map: locations_maps(:one))
    locations_maps(:one).update!(google_url: "https://example.com/aaa")
    venues_venues(:two).update!(slug: "unmapped", map: nil)

    assert_equal %w[mapped unmapped], index_order("venues_venues", sort_by: :map, sort_direction: :asc)
    assert_equal %w[mapped unmapped], index_order("venues_venues", sort_by: :map, sort_direction: :desc)
  end

  # It is `to_s.presence`, not `to_s`: a record holding an association with
  # nothing to print belongs with those holding no association at all.
  test "a belongs_to with nothing to show sorts as a missing one" do
    venues_venues(:one).update!(slug: "map-without-links", map: locations_maps(:one))
    locations_maps(:one).update!(google_url: "", apple_url: "", openstreetmap_url: "")
    venues_venues(:two).update!(slug: "mapped", map: locations_maps(:two))
    locations_maps(:two).update!(google_url: "https://example.com/zzz")

    assert_equal %w[mapped map-without-links], index_order("venues_venues", sort_by: :map, sort_direction: :asc)
    assert_equal %w[mapped map-without-links], index_order("venues_venues", sort_by: :map, sort_direction: :desc)
  end

  # A date and its time are one moment, so the time follows the date's direction
  # instead of settling ties in a fixed one.
  test "events sharing a day fall in start time order" do
    # The fixtures carry placeholder values that fail the model's validations,
    # and only the columns matter here.
    events_events(:one).update_columns(slug: "meetup-morning", start_date: Date.new(2026, 9, 24), start_time: "09:00")
    events_events(:two).update_columns(slug: "meetup-evening", start_date: Date.new(2026, 9, 24), start_time: "19:00")

    assert_equal %w[meetup-morning meetup-evening], index_order("events_events", sort_by: :start_date, sort_direction: :asc)
    assert_equal %w[meetup-evening meetup-morning], index_order("events_events", sort_by: :start_date, sort_direction: :desc)
  end

  test "addresses open sorted by slug" do
    locations_addresses(:one).update!(slug: "schellingstrasse")
    locations_addresses(:two).update!(slug: "leopoldstrasse")

    assert_equal %w[leopoldstrasse schellingstrasse], index_order("locations_addresses")
  end

  test "venues open sorted by slug" do
    venues_venues(:one).update!(slug: "zavvy-office")
    venues_venues(:two).update!(slug: "riskmethods-office")

    assert_equal %w[riskmethods-office zavvy-office], index_order("venues_venues")
  end

  # The count is not a column, so this is the one order Avo cannot pre-select as
  # a sort. It rides on the index scope instead.
  test "cities open sorted by descending address count" do
    locations_cities(:one).update!(slug: "one-address")
    locations_cities(:two).update!(slug: "two-addresses")
    locations_addresses(:one).update!(city: locations_cities(:two))

    assert_equal %w[two-addresses one-address], index_order("locations_cities")
  end

  test "coordinates open sorted by descending latitude, then ascending longitude" do
    north = locations_coordinates(:one)
    north.update!(latitude: 50.11, longitude: 8.68)
    south_east = locations_coordinates(:two)
    south_east.update!(latitude: 48.14, longitude: 11.58)
    south_west = Locations::Coordinates.create!(latitude: 48.14, longitude: 9.18)

    assert_equal [ north, south_west, south_east ].map(&:to_param), index_order("locations_coordinates")
  end

  test "events open sorted by descending start date" do
    events_events(:one).update_columns(slug: "meetup-2026-04-23", start_date: Date.new(2026, 4, 23))
    events_events(:two).update_columns(slug: "meetup-2026-09-24", start_date: Date.new(2026, 9, 24))

    assert_equal %w[meetup-2026-09-24 meetup-2026-04-23], index_order("events_events")
  end

  private

  # The row links are where the index's order shows from the outside. "new" is
  # the toolbar's create link rather than a record.
  def index_order(resource, **sort)
    get "/avo/resources/#{resource}", params: sort

    assert_response :success

    response.body.scan(%r{/avo/resources/#{resource}/([^"/?]+)}).flatten.uniq - [ "new" ]
  end
end
