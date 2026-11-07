require "json_schemer"

module Rubyevents
  # Validates a generated document against the JSON schema rubyevents.org
  # publishes for it (decision 19.1A).
  #
  # Their JSON files carry no `$ref`, so each one validates standalone. What
  # they do not carry is the `data_file` glob from their Ruby DSL, which is
  # where the array-or-object shape of each file is declared - hence the map.
  class Schema
    ROOT = Rails.root.join("lib", "rubyevents", "schemas")

    DOCUMENTS = {
      "series.yml" => [ "series_schema.json", false ],
      "event.yml" => [ "event_schema.json", false ],
      "venue.yml" => [ "venue_schema.json", false ],
      "videos.yml" => [ "video_schema.json", true ],
      "sponsors.yml" => [ "sponsors_schema.json", true ],
      "involvements.yml" => [ "involvement_schema.json", true ],
      "cfp.yml" => [ "cfp_schema.json", true ],
      "speakers.yml" => [ "speaker_schema.json", true ]
    }.freeze

    def self.for(path)
      file, array = DOCUMENTS[File.basename(path.to_s)]
      return nil unless file

      (@instances ||= {})[file] ||= new(file, array)
    end

    def initialize(file, array)
      @schemer = JSONSchemer.schema(JSON.parse(ROOT.join(file).read))
      @array = array
    end

    # Validates the YAML we are actually going to ship rather than the hash we
    # built, so that a Date leaking through as an unquoted scalar is caught
    # here instead of by their CI.
    def errors(yaml)
      entries(YAML.safe_load(yaml, permitted_classes: [ Date, Time ])).flat_map.with_index do |entry, index|
        @schemer.validate(entry).map { |error| message(error, index) }
      end
    end

    private

    def entries(document)
      @array ? Array(document) : [ document ]
    end

    def message(error, index)
      pointer = error["data_pointer"].presence || "/"
      prefix = @array ? "[#{index}]#{pointer}" : pointer

      "#{prefix}: #{error["type"] == "required" ? missing(error) : error["type"]}"
    end

    def missing(error)
      "missing #{error.dig("details", "missing_keys").to_a.join(", ")}"
    end
  end
end
