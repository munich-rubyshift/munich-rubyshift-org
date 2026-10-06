module Rubyevents
  # Upstream ids are never derived. They live in `rubyevents_slug` and are
  # maintained by hand, so that renaming a talk here cannot silently orphan a
  # published rubyevents.org URL.
  #
  # A blank slug is a data problem: strict exports surface it as a schema
  # error naming the record, lenient exports fall back to our own slug.
  module Id
    MISSING = "_missing-id".freeze

    def self.for(record, lenient:)
      slug = record.rubyevents_slug.presence
      return slug if slug

      lenient ? (record.slug.presence || record.id) : nil
    end

    # Path segments cannot be blank, even when the id is. Strict exports use a
    # placeholder that never ships, because validation raises first. It stays
    # unique per record so that several unfilled slugs do not collapse onto one
    # path and hide each other's errors.
    def self.path_segment(record, lenient:)
      self.for(record, lenient: lenient) || "#{MISSING}-#{record.id}"
    end
  end
end
