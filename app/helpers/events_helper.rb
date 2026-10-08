module EventsHelper
  # Event times are stored in UTC, but we always meet in Munich.
  EVENT_TIME_ZONE = ActiveSupport::TimeZone["Europe/Berlin"]

  def event_title(event)
    event.title.presence || event.to_s
  end

  def event_upcoming?(event)
    event.start_date.present? && event.start_date >= Date.current
  end

  # Respects the date precision, e.g. "2014", "March 2014" or "Thu, 24 Sep 2026".
  def event_date(event)
    return "Date to be announced" unless event.start_date

    case event.date_precision
    when "year" then event.start_date.strftime("%Y")
    when "month" then event.start_date.strftime("%B %Y")
    else
      dates = [ event.start_date, event.end_date ].compact.uniq
      dates.map { |date| date.strftime("%a, %-d %b %Y") }.join(" – ")
    end
  end

  # "18:30 – 21:30" in Munich time, or nil when there are no times.
  def event_time_range(event)
    starts_at = event_local_time(event.start_date, event.start_time)
    ends_at = event_local_time(event.end_date, event.end_time)
    return unless starts_at

    [ starts_at, ends_at ].compact.map { |time| time.strftime("%H:%M") }.join(" – ")
  end

  private

  def event_local_time(date, time)
    return unless date && time

    Time.utc(date.year, date.month, date.day, time.hour, time.min).in_time_zone(EVENT_TIME_ZONE)
  end
end
