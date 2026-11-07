module Rubyevents
  # Upstream titles a meetup after its group and month, "Munich Rubyshift
  # Meetup October 2025", and keeps what the organizers call it as its
  # subtitle. Ported from their Static::Validators::MeetupTitle, whose fix
  # turns an old title into a subtitle the same way, so generic wording like
  # "Ruby Meetup October 2025" leaves none.
  class MeetupTitle
    GERMAN_MONTHS = %w[Januar Februar März April Mai Juni Juli August September Oktober November Dezember].freeze
    MONTH_NAMES = (Date::MONTHNAMES.compact + GERMAN_MONTHS).uniq.freeze
    GENERIC_NAMES = [ "ruby", "rails", "ruby on rails" ].freeze
    GROUP_WORDS = /\b(user ?groups?|users group|usergroup|group|brigade|grupa|workshop|meetup)\b/i

    # same_month: whether the series has another event that month, which
    # upstream tells apart by the day.
    def initialize(event, same_month:)
      @event = event
      @date = event.start_date
      @same_month = same_month
    end

    def title
      month = @same_month ? "#{Date::MONTHNAMES[@date.month]} #{@date.day}," : Date::MONTHNAMES[@date.month]
      "#{group_name.match?(GROUP_WORDS) ? group_name : "#{group_name} Meetup"} #{month} #{@date.year}"
    end

    def subtitle
      own = @event.title.to_s
      return if own.blank? || own == title

      months = [ Date::MONTHNAMES[@date.month], GERMAN_MONTHS[@date.month - 1] ].uniq.map { Regexp.escape(_1) }
      match = own.match(/\A(?<prefix>.*?)[\s\-–:,]*\b(?:#{months.join("|")})(?:\s+\d{1,2},?)?\s+#{@date.year}(?<suffix>.*)\z/)
      match ||= own.match(/\A(?<prefix>.*?)[\s\-–:,]*\b(?:#{MONTH_NAMES.join("|")})(?:\s+\d{1,2},?)?\s+\d{4}(?<suffix>.*)\z/)
      return (own unless group_name?(own)) unless match

      prefix = match[:prefix].sub(/[\s\-–:,]+\z/, "").sub(/\s+meetup\z/i, "")
      suffix = match[:suffix].sub(/\A[\s\-–:,]+/, "").strip.sub(/\A\((.*)\)\z/, '\1')
      [ (prefix unless prefix.empty? || group_name?(prefix)), suffix.presence ].compact.join(": ").presence
    end

    private

    def group_name
      @event.series.name.to_s
    end

    def group_name?(name)
      name = normalize(name)
      GENERIC_NAMES.include?(name) || (words_of(name) - words_of(normalize(group_name))).empty?
    end

    def words_of(name)
      name.split(/[^[:alnum:].+#]+/).compact_blank.map { |word| word.delete_suffix("s") }
    end

    def normalize(name)
      name.to_s.sub(/\s+meetup\z/i, "").strip.downcase
    end
  end
end
