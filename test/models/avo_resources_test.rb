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
end
