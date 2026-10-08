class Entities::PersonComponent < ApplicationComponent
  attr_reader :person

  def initialize(person)
    @person = person
  end

  def initials
    person.name.to_s.split.map(&:first).first(2).join.upcase
  end

  def links
    {
      "Website" => person.website,
      "GitHub" => (person.github.presence && "https://www.github.com/#{person.github}"),
      "Rubyevents" => (person.rubyevents_slug.presence && "https://www.rubyevents.org/profiles/#{person.rubyevents_slug}"),
      "LinkedIn" => person.linkedin,
      "Mastodon" => person.mastodon,
      "Bluesky" => person.bluesky,
      "X" => person.twitter,
      "Speakerdeck" => person.speakerdeck
    }.compact_blank
  end
end
