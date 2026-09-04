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

    assert_equal "N 48.12°  E 11.60°", plain(coordinates.to_s)
  end

  test "names the southern and western hemispheres" do
    coordinates = Locations::Coordinates.new(latitude: -33.865143, longitude: -70.669266)

    assert_equal "S 33.87°  W 70.67°", plain(coordinates.to_s)
  end

  test "rounds a half up and carries into the degrees" do
    coordinates = Locations::Coordinates.new(latitude: 48.115, longitude: 1.999)

    assert_equal "N 48.12°  E 02.00°", plain(coordinates.to_s)
  end

  test "calls a spot that rounds onto the equator or meridian north and east" do
    coordinates = Locations::Coordinates.new(latitude: -0.004, longitude: -0.001)

    assert_equal "N 00.00°  E 00.00°", plain(coordinates.to_s)
  end

  test "pads both halves to the same width" do
    coordinates = Locations::Coordinates.new(latitude: 9.5, longitude: 0)

    assert_equal "N 09.50°  E 00.00°", plain(coordinates.to_s)
  end

  # Longitude runs past a hundred degrees, so the padding is a floor and not a
  # ceiling.
  test "keeps a third digit that is really there" do
    coordinates = Locations::Coordinates.new(latitude: 48.1, longitude: 133.5)

    assert_equal "N 48.10°  E 133.50°", plain(coordinates.to_s)
  end

  test "keeps each letter with its degrees and both halves on one line" do
    coordinates = Locations::Coordinates.new(latitude: 48.118196, longitude: 11.602731)

    assert_equal "N 48.12°  E 11.60°", coordinates.to_s
  end

  private

  # The tests above are about the numbers, and the no-break spaces between them
  # are invisible in an assertion, so read them as plain spaces.
  def plain(reading)
    reading.tr("  ", "  ")
  end
end
