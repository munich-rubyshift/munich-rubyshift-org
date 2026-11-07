module Rubyevents
  class Document::Videos < Document
    def initialize(event, **options)
      super(**options)
      @event = event
    end

    def path
      "#{Rubyevents::Id.path_segment(@event.series, lenient: lenient?)}/" \
        "#{Rubyevents::Id.path_segment(@event, lenient: lenient?)}/videos.yml"
    end

    def content
      @event.talks.map { |talk| video(talk) }
    end

    private

    # None of our talks was recorded, so there is nothing to publish: no
    # published_at, thumbnails or external player.
    def video(talk)
      {
        "id" => talk_id(talk),
        "title" => talk.title,
        "kind" => kind(talk),
        "event_name" => @event.title,
        # We hold no talk dates: a talk happens on its event's first day.
        "date" => date(@event.start_date),
        "announced_at" => date(talk.announced_on),
        "language" => talk.language,
        "slides_url" => talk.slides_url,
        "video_provider" => video_provider,
        # Upstream wants a value even without a video, and uses the talk's id.
        "video_id" => talk_id(talk),
        "description" => text(talk.description).to_s,
        "speakers" => speakers(talk),
        "additional_resources" => talk.additional_resources.map { |resource| additional_resource(resource) }
      }
    end

    def talk_id(talk)
      @talk_ids ||= Rubyevents::TalkIds.new(id_for(@event), @event.talks.to_h { [ _1, speakers(_1) ] })
      @talk_ids[talk] || fallback(nil, talk.slug)
    end

    # Upstream infers the kind from the title and rejects an explicit "talk"
    # that agrees with it, so that one only appears to overrule the title.
    def kind(talk)
      talk.kind unless talk.kind == "talk" && Rubyevents::TalkKind.from_title(talk.title) == :talk
    end

    def keep_blank
      %w[description]
    end

    # Until the event is over its talks may still be recorded, including on
    # the day itself.
    def video_provider
      @event.end_date && !@event.end_date.past? ? "scheduled" : "not_recorded"
    end

    # Upstream skips a talk without speakers, and has a "TODO" person for
    # exactly this case.
    def speakers(talk)
      names = talk.speakers.map(&:name).compact_blank.sort
      names.presence || [ "TODO" ]
    end

    def additional_resource(resource)
      {
        "name" => resource.name,
        "url" => resource.url,
        "type" => resource.kind,
        "title" => resource.title
      }
    end
  end
end
