require "test_helper"

class AvoResourcesTest < ActiveSupport::TestCase
  test "all fields exist" do
    Rails.application.eager_load!

    Avo::BaseResource.descendants.each do |resource|
      model = resource.model_class
      resource_instance = resource.new(view: :index).detect_fields

      resource_instance.get_field_definitions.each do |field|
        attr = field.id

        assert(model.attribute_names.include?(attr.to_s) || model.method_defined?(attr), "Invalid field #{attr} on #{resource}")
      end
    end
  end

  # Events::SeriesDefaults makes a blank event read back its series' value. A
  # form has to show the event's own value instead: prefilling the input with the
  # inherited one would copy it onto the event on the next save.
  test "an event form shows the event's own value, not the series fallback" do
    event = events_events(:one)
    event.website = nil
    event.series.website = "From the series"

    assert_equal "From the series", event.website
    assert_nil hydrated_field(Avo::Resources::EventsEvent, event, :edit, :website).value
  end

  test "an event form offers the series fallback as a placeholder" do
    event = events_events(:one)
    event.series.website = "From the series"

    assert_equal "From the series", hydrated_field(Avo::Resources::EventsEvent, event, :edit, :website).placeholder
  end

  test "an event form has no placeholder when the series has nothing to inherit" do
    event = events_events(:one)
    event.series.website = ""

    assert_nil hydrated_field(Avo::Resources::EventsEvent, event, :edit, :website).placeholder
  end

  test "an event page still shows the series fallback" do
    event = events_events(:one)
    event.website = nil
    event.series.website = "From the series"

    assert_equal "From the series", hydrated_field(Avo::Resources::EventsEvent, event, :show, :website).value
  end

  private

  def hydrated_field(resource_class, record, view, id)
    resource = resource_class.new(view: view, record: record).detect_fields
    definition = resource.get_field_definitions.find { |field| field.id == id }

    definition.hydrate(record: record, view: view, resource: resource)
  end
end
