module Rubyevents
  # A record that already exists upstream keeps its id there: that one lives
  # in `rubyevents_slug`, maintained by hand, so that renaming a record here
  # cannot silently orphan a published rubyevents.org URL.
  #
  # Records new to upstream derive one instead. An event takes our own slug
  # (kind and start date, which only change by hand) behind its series' id,
  # because upstream ids are global. Talks follow upstream's own rules, see
  # Rubyevents::TalkIds.
  #
  # A blank series id is a data problem: strict exports surface it as a schema
  # error naming the record, lenient exports fall back to our own slug.
  module Id
    MISSING = "_missing-id".freeze

    def self.for(record, lenient:)
      record.rubyevents_slug.presence || derived(record, lenient: lenient)
    end

    def self.derived(record, lenient:)
      case record
      when Events::Event
        series = self.for(record.series, lenient: lenient)
        "#{series}-#{record.slug}" if series && record.slug.present?
      else
        lenient ? (record.slug.presence || record.id) : nil
      end
    end

    # Path segments cannot be blank, even when the id is. Strict exports use a
    # placeholder that never ships, because validation raises first. It stays
    # unique per record so that several unfilled ids do not collapse onto one
    # path and hide each other's errors.
    def self.path_segment(record, lenient:)
      self.for(record, lenient: lenient) || "#{MISSING}-#{record.id}"
    end
  end
end
