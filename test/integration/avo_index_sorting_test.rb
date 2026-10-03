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

  test "a missing belongs_to sorts after every name" do
    venues_venues(:one).update!(slug: "mapped", map: locations_maps(:one))
    locations_maps(:one).update!(google_url: "https://example.com/aaa")
    venues_venues(:two).update!(slug: "unmapped", map: nil)

    assert_equal %w[mapped unmapped], index_order("venues_venues", sort_by: :map, sort_direction: :asc)
    assert_equal %w[unmapped mapped], index_order("venues_venues", sort_by: :map, sort_direction: :desc)
  end

  # A record holding an association with nothing to print belongs with those
  # holding no association at all.
  test "a belongs_to with nothing to show sorts as a missing one" do
    venues_venues(:one).update!(slug: "map-without-links", map: locations_maps(:one))
    locations_maps(:one).update!(google_url: "", apple_url: "", openstreetmap_url: "")
    venues_venues(:two).update!(slug: "mapped", map: locations_maps(:two))
    locations_maps(:two).update!(google_url: "https://example.com/zzz")

    assert_equal %w[mapped map-without-links], index_order("venues_venues", sort_by: :map, sort_direction: :asc)
    assert_equal %w[map-without-links mapped], index_order("venues_venues", sort_by: :map, sort_direction: :desc)
  end

  test "rows showing different records that read the same fall in their id order" do
    venues_venues(:one).update!(slug: "one", map: locations_maps(:one))
    venues_venues(:two).update!(slug: "two", map: locations_maps(:two))
    locations_maps(:one).update!(google_url: "https://example.com/same")
    locations_maps(:two).update!(google_url: "https://example.com/same")
    by_map_id = [ venues_venues(:one), venues_venues(:two) ].sort_by(&:locations_map_id).map(&:slug)

    assert_equal by_map_id, index_order("venues_venues", sort_by: :map, sort_direction: :asc)
    assert_equal by_map_id.reverse, index_order("venues_venues", sort_by: :map, sort_direction: :desc)
  end

  test "rows sharing a belongs_to fall in id order" do
    venues_venues(:one).update!(slug: "one", map: locations_maps(:one))
    venues_venues(:two).update!(slug: "two", map: locations_maps(:one))
    by_id = [ venues_venues(:one), venues_venues(:two) ].sort_by(&:id).map(&:slug)

    assert_equal by_id, index_order("venues_venues", sort_by: :map, sort_direction: :asc)
    assert_equal by_id.reverse, index_order("venues_venues", sort_by: :map, sort_direction: :desc)
  end

  test "a polymorphic belongs_to sorts by name across its types" do
    events_involvements(:one).entity.update!(name: "Anna")
    events_involvements(:two).entity.update!(name: "Zeta GmbH")
    person, organization = events_involvements(:one).id, events_involvements(:two).id

    assert_equal [ person, organization ], index_order("events_involvements", sort_by: :entity, sort_direction: :asc)
    assert_equal [ organization, person ], index_order("events_involvements", sort_by: :entity, sort_direction: :desc)
  end

  test "rows with nothing to show fall in id order too" do
    venues_venues(:one).update!(slug: "one", map: nil)
    venues_venues(:two).update!(slug: "two", map: nil)
    by_id = [ venues_venues(:one), venues_venues(:two) ].sort_by(&:id).map(&:slug)

    assert_equal by_id, index_order("venues_venues", sort_by: :map, sort_direction: :asc)
    assert_equal by_id.reverse, index_order("venues_venues", sort_by: :map, sort_direction: :desc)
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
