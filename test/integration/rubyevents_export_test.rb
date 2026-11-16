require "test_helper"

class RubyeventsExportTest < ActionDispatch::IntegrationTest
  SCHEMA = JSONSchemer.openapi(YAML.load_file(Rails.root.join("public/api/rubyevents-v1/schema.yaml")))
  LISTS = { "people" => "PeopleDocument", "cities" => "CitiesDocument", "organizations" => "OrganizationsDocument",
    "series" => "SeriesDocument" }.freeze

  # Swaps the fixtures for content/data. The test's transaction rolls it back.
  setup do
    connection = ApplicationRecord.connection
    connection.disable_referential_integrity do
      (connection.tables - %w[ar_internal_metadata schema_migrations]).each do |table|
        connection.execute("DELETE FROM #{connection.quote_table_name(table)}")
      end
    end
    capture_io { StaticDb::Load.new.send(:load_data!) }
  end

  test "each RubyEvents document of our data matches the RubyEvents schema" do
    errors = documents.to_h do |path, schema|
      get "/api/rubyevents-v1/#{path}"
      [ path, SCHEMA.schema(schema).validate(response.parsed_body).map { |error| error["error"] } ]
    end

    assert_empty errors.reject { |_path, messages| messages.empty? }
  end

  # Each serializer on its own: an event's leaves the records it includes to theirs. Those may not be stored,
  # like a meetup host's sponsorship, so they come from the event's serializer rather than by id.
  test "each record that RubyEvents gets is valid for RubyEvents" do
    serializers = LISTS.keys.flat_map do |list|
      get "/api/rubyevents-v1/#{list}.json"
      response.parsed_body["data"].map do |resource|
        record = Api::V1::Serializer::TYPES.key(resource["type"]).constantize.find(resource["id"])
        "Api::V1::#{record.class.name.demodulize}Serializer".constantize.new(record, rubyevents: true)
      end
    end
    serializers += Events::Event.all.flat_map do |event|
      serializer = Api::V1::EventSerializer.new(event, rubyevents: true)
      [ serializer, *serializer.included ]
    end
    assert_not_empty serializers

    errors = serializers.uniq(&:identifier).filter_map do |serializer|
      "#{serializer.identifier.values_at(:type, :id).join(" ")}: #{serializer.errors.full_messages.to_sentence}" unless serializer.valid_for_rubyevents?
    end

    assert_empty errors
  end

  private

  def documents
    assert_not_empty Events::Event.ids
    LISTS.to_h { |list, schema| [ "#{list}.json", schema ] }.merge(Events::Event.ids.to_h { |id| [ "events/#{id}.json", "EventDocument" ] })
  end
end
