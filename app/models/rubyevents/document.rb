module Rubyevents
  # One generated file. Subclasses map our records onto the shape rubyevents.org
  # expects; this base holds the two rules that apply to all of them.
  class Document
    attr_reader :mode, :warnings

    def initialize(mode:, warnings:)
      @mode = mode
      @warnings = warnings
    end

    def path
      raise NotImplementedError
    end

    def content
      raise NotImplementedError
    end

    # Memoised because #content records warnings as a side effect, and
    # because the export asks twice: once to skip empty files, once to write.
    def document
      @document ||= compact(content)
    end

    def to_yaml
      document.to_yaml
    end

    def empty?
      document.blank?
    end

    private

    def lenient?
      mode == :lenient
    end

    # Decision 23. A strict export copies what we hold, blanks included, and
    # lets the schema check fail loudly on what is missing. A lenient export
    # substitutes so the check passes, for experimenting before the data is
    # complete.
    def fallback(value, fake)
      return value unless lenient?

      value.presence || fake
    end

    # Decision 17.1A. Blank strings are how our dumps spell "unset", and
    # upstream simply omits those keys. `false` and `0` are NOT blank here:
    # `ended: false` is a statement, and `coordinates: false` is how upstream
    # marks an online event. This is why `compact_blank` cannot be used.
    def compact(node)
      case node
      when Hash then node.transform_values { compact(_1) }.reject { |_, value| blank_value?(value) }
      when Array then node.map { compact(_1) }.reject { |value| blank_value?(value) }
      else node
      end
    end

    # Deliberately not #blank?: `false` must survive.
    def blank_value?(value)
      value.nil? || value == "" || value == {} || value == []
    end

    def id_for(record)
      Rubyevents::Id.for(record, lenient: lenient?)
    end

    def handle(value)
      Rubyevents::Handle.from(value).presence
    end

    def date(value)
      value&.to_date&.iso8601
    end

    def drop(field, reason)
      warnings << "#{field}: #{reason}"
      nil
    end

    # TZInfo ships with Rails and knows both of the things our schema lacks:
    # the English country name and a representative zone for a country code.
    def country_name(code)
      TZInfo::Country.get(code.to_s.upcase).name
    rescue TZInfo::InvalidCountryCode
      nil
    end

    def country_timezone(code)
      TZInfo::Country.get(code.to_s.upcase).zone_identifiers.first
    rescue TZInfo::InvalidCountryCode
      nil
    end
  end
end
