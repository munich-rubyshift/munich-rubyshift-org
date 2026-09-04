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

  test "reads as degrees behind a hemisphere letter" do
    coordinates = Locations::Coordinates.new(latitude: 48.118196, longitude: 11.602731)

    assert_equal "N48.11 E11.60", coordinates.to_s
  end

  test "names the southern and western hemispheres" do
    coordinates = Locations::Coordinates.new(latitude: -33.865143, longitude: -70.669266)

    assert_equal "S33.86 W70.66", coordinates.to_s
  end

  # Rounding would move the reading to a spot the record does not hold, and at
  # the second decimal that spot is most of a kilometre away.
  test "cuts the decimals rather than rounding them" do
    coordinates = Locations::Coordinates.new(latitude: 48.999999, longitude: 1.999)

    assert_equal "N48.99 E01.99", coordinates.to_s
  end

  test "pads both halves to the same width" do
    coordinates = Locations::Coordinates.new(latitude: 9.5, longitude: 0)

    assert_equal "N09.50 E00.00", coordinates.to_s
  end

  # Longitude runs past a hundred degrees, so the padding is a floor and not a
  # ceiling.
  test "keeps a third digit that is really there" do
    coordinates = Locations::Coordinates.new(latitude: 48.1, longitude: 133.5)

    assert_equal "N48.10 E133.50", coordinates.to_s
  end
end
