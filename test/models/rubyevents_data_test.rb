require "test_helper"

class RubyeventsDataTest < ActiveSupport::TestCase
  test "a record without RubyEvents data stores nil" do
    series = events_series(:one)

    [ {}, "", " " ].each do |blank|
      series.rubyevents_data = blank

      assert_nil series.rubyevents_data, blank.inspect
    end
  end

  test "RubyEvents data is a JSON object, whose values may be null" do
    series = events_series(:one)

    series.rubyevents_data = { "slug" => "munich-rubyshift", "name" => nil, "colors" => { "featured" => "#9A0100" } }
    assert_empty series.tap(&:validate).errors[:rubyevents_data]

    [ [ "slug" ], "not JSON", 1 ].each do |data|
      series.rubyevents_data = data

      assert_includes series.tap(&:validate).errors[:rubyevents_data], "must be a JSON object", data.inspect
    end
  end

  test "RubyEvents data can't change how the API identifies a record" do
    series = events_series(:one)

    { { "id" => "1" } => "id", { "type" => "events" } => "type" }.each do |data, name|
      series.rubyevents_data = data

      assert_includes series.tap(&:validate).errors[:rubyevents_data], "can't use the reserved names #{name}"
    end
  end

  test "every table holds RubyEvents data except join tables, coordinates and those of gems" do
    connection = ApplicationRecord.connection
    without = connection.tables.reject { |table| connection.column_exists?(table, :rubyevents_data) }

    assert_equal %w[active_storage_attachments active_storage_blobs active_storage_variant_records ar_internal_metadata
      events_participations friendly_id_slugs locations_coordinates schema_migrations talks_speaker_talks], without.sort
  end

  test "every model with RubyEvents data checks it" do
    Rails.application.eager_load!
    models = ApplicationRecord.descendants.select { |model| !model.abstract_class? && model.column_names.include?("rubyevents_data") }

    assert_not_empty models
    assert_empty models.reject { |model| model.include?(RubyeventsData) }.map(&:name)
  end

  test "every model with RubyEvents data can edit it in Avo" do
    Rails.application.eager_load!
    resources = Avo::BaseResource.descendants.select { |resource| resource.model_class.column_names.include?("rubyevents_data") }

    assert_not_empty resources
    assert_empty resources.reject { |resource|
      resource.new(view: :edit).detect_fields.get_field_definitions.any? { |field| field.id == :rubyevents_data }
    }.map(&:name)
  end
end
