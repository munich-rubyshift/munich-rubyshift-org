require "test_helper"

class Events::SeriesTest < ActiveSupport::TestCase
  test "may leave its language blank" do
    series = Events::Series.new(name: "Munich Rubyshift", time_zone: "Europe/Berlin", language_code: nil)

    assert series.valid?, series.errors.full_messages.to_sentence
    assert_nil series.language
  end

  test "only takes a language we list" do
    series = Events::Series.new(name: "Munich Rubyshift", language_code: "English")

    assert_not series.valid?
    assert_includes series.errors[:language_code], "is not included in the list"
  end

  test "needs a time zone that rubyevents knows" do
    [ nil, "", "Munich", "CET+1" ].each do |time_zone|
      series = Events::Series.new(name: "Munich Rubyshift", time_zone: time_zone)

      assert_not series.valid?, time_zone.inspect
      assert_includes series.errors[:time_zone], "is not included in the list"
    end
  end

  test "reads its language as the English name" do
    assert_equal "English", Events::Series.new(language_code: "en").language
  end
end
