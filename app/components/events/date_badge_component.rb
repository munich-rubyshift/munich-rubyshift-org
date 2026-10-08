class Events::DateBadgeComponent < ApplicationComponent
  attr_reader :date, :precision

  def initialize(date, precision: "day")
    @date = date
    @precision = precision
  end

  def top
    return "TBA" unless date

    precision == "year" ? "" : date.strftime("%b")
  end

  def main
    return "?" unless date

    precision == "day" ? date.day : date.strftime("%Y")
  end

  def bottom
    date.year if date && precision != "year"
  end
end
