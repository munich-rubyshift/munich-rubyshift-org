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

    # Every field here except mastodon and website is a bare handle.
    def speaker(person)
      {
        "name" => person.name,
        "github" => handle(person.github_username).to_s,
        "twitter" => handle(person.twitter_username),
        "mastodon" => person.mastodon,
        "bluesky" => handle(person.bluesky_handle),
        "linkedin" => handle(person.linkedin_username),
        "website" => person.website,
        "speakerdeck" => handle(person.speakerdeck_username),
        "slug" => slug(person)
      }
    end

    # Upstream requires the parameterized name, or the GitHub handle for a
    # name that has none. rubyevents_slug is something else: the profile URL
    # on rubyevents.org, which is usually the GitHub handle.
    def slug(person)
      Rubyevents.parameterize(person.name).presence || Rubyevents.parameterize(handle(person.github_username))
    end

    # github is required upstream, and "" is how they spell "unknown".
    def keep_blank
      %w[github]
    end
  end
end
