module Rubyevents
  class Document::Sponsors < Document
    # Upstream's tier for the organization whose office a meetup took place in.
    HOST_TIER = "Meetup Host".freeze

    def initialize(event, **options)
      super(**options)
      @event = event
    end

    def path
      "#{Rubyevents::Id.path_segment(@event.series, lenient: lenient?)}/" \
        "#{Rubyevents::Id.path_segment(@event, lenient: lenient?)}/sponsors.yml"
    end

    # The file is a one-element array wrapping the tier list - odd, but it is
    # what SponsorsSchema's "[]" selector describes and what upstream writes.
    # The host comes first, ahead of our sponsor tiers.
    def content
      [ { "tiers" => [ host_tier ].compact + @event.sponsor_tiers.map { |tier| tier(tier) } } ]
    end

    private

    def tier(tier)
      {
        "name" => tier.name,
        "description" => text(tier.description),
        "level" => tier.level,
        "sponsors" => tier.sponsorships.map { |sponsorship| sponsor(sponsorship.organization, badge: sponsorship.badge) }
      }
    end

    # Their slug must be the name parameterized, so rubyevents_slug has no say here.
    def sponsor(organization, badge: nil)
      {
        "name" => organization.name,
        "slug" => Rubyevents.parameterize(organization.name),
        "website" => fallback(organization.website, "https://example.com"),
        "badge" => badge
      }
    end

    # We hold no sponsorship for a host, only the organization a venue
    # belongs to. Its logo is a file of ours with no public URL yet.
    def host_tier
      organization = @event.venue&.organization
      return unless organization

      {
        "name" => HOST_TIER,
        "sponsors" => [ sponsor(organization) ]
      }
    end
  end
end
