require "test_helper"

class HostPagesTest < ActionDispatch::IntegrationTest
  setup do
    @freeletics = Entities::Organization.create!(name: "Freeletics", legal_name: "Freeletics GmbH")
    @makandra = Entities::Organization.create!(name: "makandra", legal_name: "makandra GmbH")
    Entities::Organization.create!(name: "Never hosted GmbH")

    old_office = venue("Freeletics Office", @freeletics)
    new_office = venue("Freeletics Office 2", @freeletics)
    @older = event_at(old_office, "2018-12-12")
    @newer = event_at(new_office, "2026-04-23")
    event_at(new_office, "2020-04-15", status: "cancelled")
    event_at(venue("makandra Office", @makandra), "2026-01-22")
  end

  test "the menu leads to the hosts" do
    get "/"

    assert_select "header nav a[href='/hosts']", text: "Hosts"
  end

  test "the hosts page lists who provided a venue, most recent host first" do
    get "/hosts"

    assert_response :success
    assert_select "h1", text: /\AHosts/
    assert_match(/We are always looking for meetup hosts/, response.body)
    assert_equal %w[/organizations/freeletics /organizations/makandra],
      css_select("#hosts > li > p > a").map { |link| link["href"] }
    assert_no_match(/Never hosted/, response.body)
  end

  test "a host lists the events it hosted at which office, newest first" do
    get "/organizations/freeletics"

    assert_response :success
    hosted = css_select("article li").map { |item| item.text.squish }
    assert_equal [ "#{@newer} at Freeletics Office 2", "#{@older} at Freeletics Office" ], hosted
  end


  private
    def venue(name, organization)
      Venues::Venue.create!(name: name, address: locations_addresses(:one), organization: organization)
    end

    def event_at(venue, date, status: "scheduled")
      Events::Event.create!(series: events_series(:one), kind: "meetup", attendance_mode: "in_person", status: status,
        venue: venue, start_date: date, end_date: date)
    end
end
