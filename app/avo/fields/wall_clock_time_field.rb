# Avo's time field for a string column holding a wall clock time like "19:00".
# Started from `bin/rails generate avo:field wall_clock_time --field-template time`.
module Avo
  module Fields
    class WallClockTimeField < DateTimeField
      attr_reader :format
      attr_reader :picker_format

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_string_prop args, :picker_format, "H:i"
        add_string_prop args, :format, "HH:mm"
      end

      def relative
        false
      end

      def time_24hr
        true
      end

      def formatted_value
        value
      end

      def edit_formatted_value
        value
      end

      # The form submits flatpickr's own input, "2026-11-12 19:30:00", because Avo's copy of
      # the value keeps a deleted time after a click elsewhere.
      def fill_field(record, key, value, params)
        record.public_send(:"#{key}=", value.presence&.split&.last&.first(5))
        record
      end
    end
  end
end
