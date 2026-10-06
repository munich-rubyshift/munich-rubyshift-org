# The shared fixtures are scaffold output ("kind: MyString"), which cannot
# satisfy upstream's enums. Export tests therefore start from an empty database
# and build a small realistic graph instead.
module RubyeventsGraph
  # Children first: every table here is reachable by foreign key from the next.
  TABLES = [
    Talks::AdditionalResource, Talks::SpeakerTalk, Talks::Talk,
    Events::Participation, Events::Involvement, Events::CFP,
    Sponsors::Sponsorship, Sponsors::SponsorTier,
    Events::Event, Events::Series,
    Venues::Venue, Locations::Address, Locations::City, Locations::Coordinates, Locations::Map,
    Entities::Person, Entities::Organization
  ].freeze

  def build_graph(complete: true)
    TABLES.each(&:delete_all)

    city_pin = Locations::Coordinates.create!(latitude: 48.137108, longitude: 11.575382)
    venue_pin = Locations::Coordinates.create!(latitude: 48.129604, longitude: 11.625085)
    city = Locations::City.create!(name: "Munich", slug: "munich", state_code: "BY", country_code: "DE", coordinates: city_pin)
    address = Locations::Address.create!(street: "Berg-am-Laim-Straße 111", zip_code: "81673", city: city, slug: "bal-111")
    venue = Venues::Venue.create!(name: "Freeletics Office", slug: "freeletics-office", address: address, coordinates: venue_pin)

    series = Events::Series.create!(
      name: "Munich Rubyshift", slug: "munich-rubyshift", rubyevents_slug: "munich-rubyshift",
      kind: "meetup", frequency: "quarterly", language: "English", default_country_code: "DE", ended: false,
      website: "https://munich-rubyshift.org", discord: "https://discord.gg/EKqHWmCxGZ"
    )

    event = Events::Event.create!(
      series: series, venue: venue, title: "Ruby Meetup April 2026", slug: "meetup-april-2026",
      rubyevents_slug: complete ? "munich-rubyshift-2026-04" : "",
      kind: complete ? "meetup" : "", start_date: Date.new(2026, 4, 23)
    )

    speaker = Entities::Person.create!(
      name: "Hans Schnedlitz", slug: "hans-schnedlitz",
      rubyevents_slug: complete ? "hans-schnedlitz" : "",
      github: "hschne", twitter: "https://x.com/hschnedlitz",
      bluesky: "https://bsky.app/profile/hschne", linkedin: "https://www.linkedin.com/in/hschne",
      mastodon: "https://ruby.social/@hschne", website: "https://hansschnedlitz.com"
    )

    talk = Talks::Talk.create!(
      event: event, title: "Gems are overrated", slug: "gems-are-overrated",
      rubyevents_slug: complete ? "gems-are-overrated-at-munich-rubyshift" : "",
      description: complete ? "Why you should write less code." : "",
      date: complete ? Date.new(2026, 4, 23) : nil,
      video_provider: complete ? "not_recorded" : "", video_id: complete ? "gems-are-overrated" : ""
    )
    Talks::SpeakerTalk.create!(talk: talk, speaker: speaker)

    organization = Entities::Organization.create!(name: "Freeletics", slug: "freeletics", website: "https://www.freeletics.com")
    tier = Sponsors::SponsorTier.create!(event: event, name: "Location & Drinks", slug: "location-drinks", level: 1)
    Sponsors::Sponsorship.create!(
      sponsor_tier: tier, organization: organization, name: "Location & Drinks by Freeletics",
      slug: "location-drinks-by-freeletics", rubyevents_slug: complete ? "freeletics" : ""
    )

    Events::Involvement.create!(event: event, entity: speaker, role: "Organizer")

    { series: series, event: event, talk: talk, speaker: speaker, venue: venue }
  end
end
