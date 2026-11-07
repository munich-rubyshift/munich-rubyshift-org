require "zip"

module Rubyevents
  # Builds the tree rubyevents.org expects, as a pure function of our database
  # (decision 3A): no network, no reads of their repository, deterministic
  # output for a given set of records and day. The day only decides whether
  # the talks of an event that is not over yet are "scheduled".
  #
  # The result replaces data/<series>/ wholesale upstream, so anything we do
  # not hold is data they lose. Check the diff before opening a pull request.
  # In a checkout of rubyevents/rubyevents:
  #
  # 1. Replace data/<series>/ with the series directory of the export.
  # 2. Merge speakers/speakers.yml into data/speakers.yml by hand. Many of our
  #    people are already listed there, often with handles we lack.
  # 3. `bundle exec yerba apply` for their quoting and blank lines. The keys
  #    are already in their order, so this changes nothing else.
  # 4. `bin/rails validate:all`, which also runs the checks their schemas
  #    cannot express, such as talk ids and speaker slugs.
  class Export
    class InvalidDocument < StandardError; end

    MODES = %i[strict lenient].freeze
    REPORTED_ERRORS = 25

    attr_reader :mode

    def initialize(mode: :strict)
      raise ArgumentError, "unknown mode #{mode}" unless mode.in?(MODES)

      @mode = mode
      @warnings = []
    end

    def files
      @files ||= documents.reject(&:empty?).to_h { |document| [ document.path, document.to_yaml ] }
    end

    # Fields of ours that have no home in their schemas, collected while
    # building, once per field however many records hold one.
    def warnings
      files
      @warnings.tally.map { |warning, count| count > 1 ? "#{warning} (#{count}x)" : warning }
    end

    def errors
      @errors ||= files.sort_by(&:first).flat_map do |path, yaml|
        schema = Rubyevents::Schema.for(path)
        schema ? schema.errors(yaml).map { |error| "#{path} #{error}" } : []
      end
    end

    def validate!
      return self if errors.empty?

      raise InvalidDocument, <<~MESSAGE.strip
        #{errors.size} schema violation(s) in the #{mode} export:

        #{errors.take(REPORTED_ERRORS).join("\n")}
      MESSAGE
    end

    # The same tree as #zip, for diffing against a checkout of their data/.
    def write_to(directory)
      files.each do |path, content|
        file = Pathname(directory).join(path)
        file.dirname.mkpath
        file.write(content)
      end
    end

    def zip
      buffer = Zip::OutputStream.write_buffer(StringIO.new) do |stream|
        files.sort_by(&:first).each do |path, content|
          stream.put_next_entry(path)
          stream.write(content)
        end
      end

      buffer.string
    end

    private

    def documents
      series.flat_map { |record| [ series_document(record) ] + event_documents(record) } + [ speakers_document ]
    end

    def series
      Events::Series.order(:name)
    end

    def series_document(record)
      Document::Series.new(record, **options)
    end

    def event_documents(record)
      events.where(series: record).order(:start_date, :title).flat_map do |event|
        [
          Document::Event.new(event, **options),
          Document::Venue.new(event, **options),
          Document::Videos.new(event, **options),
          Document::Sponsors.new(event, **options),
          Document::Involvements.new(event, **options),
          Document::CFP.new(event, **options)
        ]
      end
    end

    # A cancelled meetup is not worth an entry upstream, unlike a cancelled
    # conference.
    def events
      Events::Event.not_cancelled
    end

    # Upstream requires a speakers.yml entry for every name in videos.yml and
    # involvements.yml, and rejects entries nobody refers to. So attendees
    # who never spoke or helped out stay ours, and so do those who only
    # organized cancelled events.
    def speakers_document
      speakers = Entities::Person.where(id: Talks::SpeakerTalk.where(talk: Talks::Talk.where(event: events)).select(:entities_person_id))
      involved = Entities::Person.where(id: Events::Involvement.where(event: events, entity_type: Entities::Person.name).select(:entity_id))

      Document::Speakers.new(speakers.or(involved).order(:name), **options)
    end

    def options
      { mode: mode, warnings: @warnings }
    end
  end
end
