module LocalTimes
  extend ActiveSupport::Concern

  TIME_ZONE = ActiveSupport::TimeZone["Europe/Berlin"]

  class_methods do
    def local_time(name, date:, time:)
      # Like the database, keep only the time of day. A picked time comes on today's date.
      normalizes time, with: ->(clock) { Time.utc(2000, 1, 1, clock.hour, clock.min, clock.sec) }

      define_method(name) do
        day = public_send(date)
        clock = public_send(time)
        TIME_ZONE.local(day.year, day.month, day.day, clock.hour, clock.min, clock.sec) if day && clock
      end
    end
  end
end
