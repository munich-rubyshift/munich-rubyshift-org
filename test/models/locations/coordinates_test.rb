require "test_helper"

class Locations::CoordinatesTest < ActiveSupport::TestCase
  test "requires both degrees" do
    coordinates = Locations::Coordinates.new

    assert_not coordinates.valid?
    assert_includes coordinates.errors[:latitude], "can't be blank"
    assert_includes coordinates.errors[:longitude], "can't be blank"
  end

  # A point on the equator or the prime meridian is a real place, and `presence`
  # is the one blank check that agrees.
  test "counts zero as a degree" do
    coordinates = Locations::Coordinates.new(latitude: 0, longitude: 0)

    assert coordinates.valid?, coordinates.errors.full_messages.to_sentence
  end

  # The validation is skippable, the column is not.
  test "the column refuses a missing degree as well" do
    coordinates = Locations::Coordinates.create!(latitude: 48.118196, longitude: 11.602731)

    assert_raises ActiveRecord::NotNullViolation do
      coordinates.update_columns(longitude: nil)
    end
  end
end
