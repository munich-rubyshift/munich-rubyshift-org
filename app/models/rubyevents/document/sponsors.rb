module Rubyevents
  class Document::Sponsors < Document
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
    def content
      [ { "tiers" => @event.sponsor_tiers.map { |tier| tier(tier) } } ]
    end

    private

    def tier(tier)
      {
        "name" => tier.name,
        "description" => tier.description,
        "level" => tier.level,
        "sponsors" => tier.sponsorships.map { |sponsorship| sponsor(sponsorship) }
      }
    end

    # Upstream's sponsor name is the company. Ours is the label of the deal
    # ("Location & Drinks by Freeletics"), so the organisation wins where we
    # have one.
    def sponsor(sponsorship)
      organization = sponsorship.organization

      {
        "name" => organization&.name.presence || sponsorship.name,
        "slug" => id_for(sponsorship),
        "website" => fallback(sponsorship.website.presence || organization&.website, "https://example.com"),
        "description" => sponsorship.description.presence || organization&.description,
        "logo_url" => sponsorship.logo_url.presence || organization&.logo_url,
        "badge" => sponsorship.badge
      }
    end
  end
end
