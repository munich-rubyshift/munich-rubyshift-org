class CounterComponent < ApplicationComponent
  def initialize(initial_value: 0, label: false)
    @initial_value = initial_value
    @label = label
  end
end
