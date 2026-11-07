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
        "speakerdeck" => handle(person.speakerdeck_username) || slides_handle(person),
        "slug" => slug(person)
      }
    end

    # Upstream requires the parameterized name, or the GitHub handle for a
    # name that has none. rubyevents_slug is something else: the profile URL
    # on rubyevents.org, which is usually the GitHub handle.
    def slug(person)
      Rubyevents.parameterize(person.name).presence || Rubyevents.parameterize(handle(person.github_username))
    end

    # Upstream's speakerdeck:check wants the handle of whoever alone gave
    # talks with slides on SpeakerDeck, all under one account.
    def slides_handle(person)
      talks = person.talks.joins(:event).merge(Events::Event.not_cancelled).select { |talk| talk.speakers.one? }
      handles = talks.filter_map { |talk| talk.slides_url.to_s[%r{speakerdeck\.com/(?:u/)?([^/]+)/}, 1] }.uniq
      handles.first if handles.one?
    end

    # github is required upstream, and "" is how they spell "unknown".
    def keep_blank
      %w[github]
    end
  end
end
