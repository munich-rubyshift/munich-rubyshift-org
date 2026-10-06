require "zip"

module Rubyevents
  # Builds the tree rubyevents.org expects, as a pure function of our database
  # (decision 3A): no network, no reads of their repository, deterministic
  # output for a given set of records.
  #
  # The result replaces data/<series>/ wholesale upstream, so anything we do
  # not hold is data they lose. Check the diff before opening a pull request.
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
    # building. Only meaningful once #files has run.
    def warnings
      files
      @warnings
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
      record.events.order(:start_date, :title).flat_map do |event|
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

    def speakers_document
      Document::Speakers.new(Entities::Person.order(:name), **options)
    end

    def options
      { mode: mode, warnings: @warnings }
    end
  end
end
