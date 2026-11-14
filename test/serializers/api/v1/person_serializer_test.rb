require "test_helper"

class Api::V1::PersonSerializerTest < ActiveSupport::TestCase
  test "a person is valid for RubyEvents with their name, parameterized the way RubyEvents does, as slug" do
    person = Entities::Person.new(name: "Jannis Hübl", slug: "jannis-hubl")

    assert Api::V1::PersonSerializer.new(person.tap { |p| p.rubyevents_data = { "slug" => "jannis-huebl" } }, rubyevents: true).valid_for_rubyevents?

    serializer = Api::V1::PersonSerializer.new(person.tap { |p| p.rubyevents_data = nil }, rubyevents: true)
    assert_not serializer.valid_for_rubyevents?
    assert_equal [ "Slug must be the name parameterized the way RubyEvents does: jannis-huebl" ], serializer.errors.full_messages
  end
end
