module Rubyevents
  class Document::CFP < Document
    def initialize(event, **options)
      super(**options)
      @event = event
    end

    def path
      "#{Rubyevents::Id.path_segment(@event.series, lenient: lenient?)}/" \
        "#{Rubyevents::Id.path_segment(@event, lenient: lenient?)}/cfp.yml"
    end

    def content
      @event.cfps.map do |cfp|
        {
          # Events::CFP#url falls back to our own /cfps/<slug> page when there
          # is no external one.
          "link" => fallback(cfp.url, "https://example.com"),
          "name" => cfp.name,
          "open_date" => date(cfp.open_date),
          "close_date" => date(cfp.close_date)
        }
      end
    end
  end
end
