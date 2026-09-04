require "test_helper"

# Sorting is easy to get subtly wrong in ways the resource file does not show,
# so these ask the index for a sort and read back the order it rendered.
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

  private

  # The row links are where the index's order shows from the outside. "new" is
  # the toolbar's create link rather than a record.
  def index_order(resource, **sort)
    get "/avo/resources/#{resource}", params: sort

    assert_response :success

    response.body.scan(%r{/avo/resources/#{resource}/([^"/?]+)}).flatten.uniq - [ "new" ]
  end
end
