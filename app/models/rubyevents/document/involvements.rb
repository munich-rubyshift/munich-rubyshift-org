module Rubyevents
  class Document::Involvements < Document
    def initialize(event, **options)
      super(**options)
      @event = event
    end

    def path
      "#{Rubyevents::Id.path_segment(@event.series, lenient: lenient?)}/" \
        "#{Rubyevents::Id.path_segment(@event, lenient: lenient?)}/involvements.yml"
    end

    # We hold one row per (event, entity, role); upstream groups by role and
    # splits people from organisations.
    def content
      @event.involvements.group_by(&:role).map do |role, involvements|
        entities = involvements.filter_map(&:entity)

        {
          "name" => fallback(role, "Organizer"),
          "users" => names(entities, Entities::Person),
          "organisations" => names(entities, Entities::Organization)
        }
      end
    end

    private

    def names(entities, type)
      entities.grep(type).map(&:name).compact_blank.sort
    end
  end
end
