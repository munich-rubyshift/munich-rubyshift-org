module Rubyevents
  # A record that already exists upstream keeps its id there: that one lives
  # in `rubyevents_slug`, maintained by hand, so that renaming a record here
  # cannot silently orphan a published rubyevents.org URL.
  #
  # Records new to upstream derive one instead, behind the series' id because
  # upstream ids are global. A meetup takes its date, as upstream's
  # MeetupFolder validator requires, with "-2", "-3", ... for another meetup
  # of the series on the same day. Other events take our own slug (kind and
  # start date, which only change by hand). Talks follow upstream's own
  # rules, see Rubyevents::TalkIds.
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
        return unless series

        if record.kind == "meetup" && record.start_date
          "#{series}-#{record.start_date.iso8601}#{counter(record)}"
        elsif record.slug.present?
          "#{series}-#{record.slug}"
        end
      else
        lenient ? (record.slug.presence || record.id) : nil
      end
    end

    def self.counter(meetup)
      index = meetup.series.events.where(kind: "meetup", start_date: meetup.start_date).order(:start_time, :slug).ids.index(meetup.id)
      "-#{index + 1}" if index.to_i.positive?
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
