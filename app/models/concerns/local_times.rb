module LocalTimes
  extend ActiveSupport::Concern

  TIME_ZONE = ActiveSupport::TimeZone["Europe/Berlin"]
  TIME_OF_DAY = /\A([01]\d|2[0-3]):[0-5]\d\z/

  class_methods do
    def local_time(name, date:, time:)
      validates time, format: { with: TIME_OF_DAY, message: "must be a time like 19:00" }, allow_nil: true

      define_method(name) do
        day = public_send(date)
        clock = public_send(time)
        return unless day && clock&.match?(TIME_OF_DAY)

        hour, minute = clock.split(":").map(&:to_i)
        TIME_ZONE.local(day.year, day.month, day.day, hour, minute)
      end
    end
  end
end
