module Rubyevents
  # The ids of one event's talks, derived like upstream's Talk::StaticID and
  # deduplicated like their TalkId validator, which every non-meetup event has
  # to pass: "firstname-lastname-<event id>" for one or two speakers, the kind
  # alone for any other number, the kind added when two talks share speakers,
  # the title when even that collides, and a number as the last resort.
  #
  # A talk with a rubyevents_slug keeps it, and nobody else gets that id.
  class TalkIds
    # talks: each talk with the speaker names it is exported with, in order.
    def initialize(event_id, talks)
      @event_id = event_id
      @talks = talks
    end

    def [](talk)
      ids[talk]
    end

    private

    def ids
      @ids ||= @talks.keys.to_h { |talk| [ talk, talk.rubyevents_slug.presence ] }.merge(derived)
    end

    def derived
      return {} if @event_id.blank?

      @talks.keys.reject { |talk| talk.rubyevents_slug.present? }.group_by { speaker_id(_1) }.each_with_object({}) do |(id, group), result|
        next if id.blank?
        next result[group.first] = id if group.one? && available?(id)

        group.group_by { kind_id(_1) }.each do |with_kind, kind_group|
          next if with_kind.blank?
          next result[kind_group.first] = with_kind if kind_group.one? && available?(with_kind)

          kind_group.group_by { title_id(_1) }.each do |with_title, title_group|
            next if with_title.blank?
            next result[title_group.first] = with_title if title_group.one? && available?(with_title)

            title_group.each.with_index(1) { |talk, index| result[talk] = numbered(with_title, index) }
          end
        end
      end
    end

    def speaker_id(talk)
      speakers = @talks[talk] - [ "TODO" ]

      if speakers.size.between?(1, 2)
        id_from(*speakers)
      elsif talk.kind == "talk"
        title_id(talk)
      else
        id_from(talk.kind.dasherize)
      end
    end

    def kind_id(talk)
      speakers = @talks[talk] - [ "TODO" ]

      if speakers.size.between?(1, 2) && talk.kind != "talk"
        id_from(*speakers, talk.kind.dasherize)
      else
        speaker_id(talk)
      end
    end

    def title_id(talk)
      id_from(talk.title)
    end

    def id_from(*parts)
      base = parts.map { Rubyevents.parameterize(_1) }.compact_blank
      [ *base, @event_id ].join("-") if base.any?
    end

    def numbered(id, index)
      index += 1 until available?(candidate = id.delete_suffix("-#{@event_id}") + "-#{index}-#{@event_id}")
      candidate
    end

    def available?(id)
      @talks.keys.none? { |talk| talk.rubyevents_slug == id }
    end
  end
end
