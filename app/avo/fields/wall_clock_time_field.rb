# Avo's time field for a string column holding a wall clock time like "19:00".
# Started from `bin/rails generate avo:field wall_clock_time --field-template time`;
# the edit template is still Avo's.
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

      def relative = false

      def formatted_value = value

      def edit_formatted_value = value

      # The picker submits "19:30:00".
      def fill_field(record, key, value, params)
        record.public_send(:"#{key}=", value.presence&.sub(/\A(\d\d:\d\d):00\z/, '\1'))
        record
      end
    end
  end
end
