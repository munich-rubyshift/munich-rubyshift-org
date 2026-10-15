require "test_helper"

class Entities::OrganizationTest < ActiveSupport::TestCase
  include StorageTestHelper

  test "names its logo after the organization" do
    check_out_storage

    acme = Entities::Organization.create!(name: "Acme", logo: image_upload)

    assert_equal "acme-logo.png", acme.reload.logo.filename.to_s
  end

  test "the slug follows the brand" do
    organization = Entities::Organization.create!(name: "Freeletics", legal_name: "Freeletics GmbH")

    assert_equal "freeletics", organization.slug
  end

  test "the slug falls back to the legal name without a brand" do
    organization = Entities::Organization.create!(legal_name: "makandra GmbH")

    assert_equal "makandra-gmbh", organization.slug
  end

  test "the rubyevents slug transliterates like rubyevents.org, unlike our slug" do
    organization = Entities::Organization.create!(name: "Café Größenwahn & Söhne")

    assert_equal "cafe-groessenwahn-soehne", organization.slug
    assert_equal "cafe-grossenwahn-sohne", organization.rubyevents_slug
    assert_equal "https://www.rubyevents.org/organizations/cafe-grossenwahn-sohne", organization.rubyevents_url
  end

  test "an organization without a brand has no rubyevents url" do
    organization = Entities::Organization.new(legal_name: "makandra GmbH")

    assert_nil organization.rubyevents_url
  end

  test "a brand marked as a guess slugs as the plain brand" do
    organization = Entities::Organization.create!(name: "? Zavvy ?", legal_name: "? Zavvy GmbH ?")

    assert_equal "zavvy", organization.slug
  end

  test "an organization hosts by providing the venue of an event" do
    freeletics = organization("Freeletics GmbH")
    event_at(venue_of(freeletics), "2026-04-23")
    organization("Without venue")
    venue_of(organization("Without events"))

    assert_equal [ freeletics ], Entities::Organization.meetup_hosts.to_a
  end

  test "a cancelled event was never hosted" do
    xempus = organization("Xempus AG")
    event_at(venue_of(xempus), "2020-03-11", status: "cancelled")

    assert_empty Entities::Organization.meetup_hosts
    assert_empty xempus.hosted_events
  end

  test "a cancelled event leaves the latest hosted one to sort by" do
    xempus = organization("Xempus AG")
    event_at(venue_of(xempus), "2019-09-11")
    event_at(venue_of(xempus), "2026-03-11", status: "cancelled")
    metoda = organization("Metoda GmbH")
    event_at(venue_of(metoda), "2025-03-20")

    assert_equal [ metoda, xempus ], Entities::Organization.meetup_hosts.to_a
  end

  test "the most recent host comes first, an upcoming one before all" do
    metoda = organization("Metoda GmbH")
    event_at(venue_of(metoda), "2025-03-20")
    experteer = organization("Experteer GmbH")
    event_at(venue_of(experteer), "2023-07-13")
    event_at(venue_of(experteer), "2013-07-12")
    pharos = organization("PHAROS")
    event_at(venue_of(pharos), Date.current.next_year.iso8601)

    assert_equal [ pharos, metoda, experteer ], Entities::Organization.meetup_hosts.to_a
  end

  test "an organization with several offices counts its latest event at any of them" do
    freeletics = organization("Freeletics GmbH")
    event_at(venue_of(freeletics), "2018-12-12")
    event_at(venue_of(freeletics), "2026-04-23")
    metoda = organization("Metoda GmbH")
    event_at(venue_of(metoda), "2025-03-20")

    assert_equal [ freeletics, metoda ], Entities::Organization.meetup_hosts.to_a
  end

  test "hosts of the same day go by name, ignoring case" do
    makandra = organization("makandra GmbH")
    event_at(venue_of(makandra), "2026-01-22")
    codecentric = organization("codecentric AG")
    event_at(venue_of(codecentric), "2026-01-22")
    jetbrains = organization("JetBrains GmbH")
    event_at(venue_of(jetbrains), "2026-01-22")

    assert_equal [ codecentric, jetbrains, makandra ], Entities::Organization.meetup_hosts.to_a
  end

  test "hosts of undated events only come last" do
    undated = organization("A undated host")
    event_at(venue_of(undated), nil)
    dated = organization("Z dated host")
    event_at(venue_of(dated), "2013-07-10")

    assert_equal [ dated, undated ], Entities::Organization.meetup_hosts.to_a
  end

  private
    def organization(name)
      Entities::Organization.create!(name: name)
    end

    def venue_of(organization)
      Venues::Venue.create!(name: "#{organization.name} Office", address: locations_addresses(:one), organization: organization)
    end

    def event_at(venue, date, status: "scheduled")
      Events::Event.create!(series: events_series(:one), kind: "meetup", attendance_mode: "in_person", status: status,
        venue: venue, start_date: date, end_date: date)
    end
end
