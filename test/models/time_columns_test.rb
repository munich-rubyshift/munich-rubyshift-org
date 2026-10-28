require "test_helper"

class TimeColumnsTest < ActiveSupport::TestCase
  test "no model stores a time column" do
    Rails.application.eager_load!

    models = ApplicationRecord.descendants.reject(&:abstract_class?)
    assert_predicate models, :any?, "Found no models, the detection above is broken"

    time_columns = models.flat_map do |model|
      model.columns.select { |column| column.type == :time }.map { |column| "#{model.table_name}.#{column.name}" }
    end
    assert_empty time_columns, "Store a time of day as an \"HH:MM\" string, see LocalTimes"
  end
end
