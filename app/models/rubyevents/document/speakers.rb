module Rubyevents
  class Document::Speakers < Document
    def initialize(people, **options)
      super(**options)
      @people = people
    end

    # Global upstream, so it ships in its own directory for a manual merge
    # into data/speakers.yml rather than inside the series tree (decision 2X).
    def path
      "speakers/speakers.yml"
    end

    def content
      @people.map { |person| speaker(person) }
    end

    private

    def speaker(person)
      {
        "name" => person.name,
        "slug" => id_for(person),
        # github is required upstream even when empty, and every field here
        # except mastodon and website is a bare handle.
        "github" => fallback(handle(person.github), "todo"),
        "twitter" => handle(person.twitter),
        "website" => person.website,
        "mastodon" => person.mastodon,
        "bluesky" => handle(person.bluesky),
        "linkedin" => handle(person.linkedin),
        "speakerdeck" => handle(person.speakerdeck)
      }
    end
  end
end
