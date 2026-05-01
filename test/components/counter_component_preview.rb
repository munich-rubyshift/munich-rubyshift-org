class CounterComponentPreview < ViewComponent::Preview
  # A counter with custom initial value
  # ---
  # You probably don't want to use this component for real,
  # because it doesn't persist the counter value anywhere.
  #
  # @label Custom
  # @param initial_value [Integer]
  def custom(initial_value: 0)
    render CounterComponent.new(initial_value: initial_value)
  end

  # @!group Initial Values

  # @label Default
  def zero
    render CounterComponent.new
  end

  # @label Manually set
  def forty_two
    render CounterComponent.new(initial_value: 42)
  end

  # @!endgroup

  # @hidden
  def negative_one
    render CounterComponent.new(initial_value: -1)
  end

  # @!group I18n

  # @label English
  def english
    I18n.with_locale(:en) do
      render CounterComponent.new(label: true)
    end
  end

  # Caution
  # ---
  # Getting too sophisticated within a preview isn't supported:
  # - [https://github.com/lookbook-hq/lookbook/issues/793](https://github.com/lookbook-hq/lookbook/issues/793)
  #
  # @label German [Lookbook BUG, see Notes tab]
  def german
    I18n.with_locale(:de) do
      render CounterComponent.new(label: true)
    end
  end

  # @!endgroup
end
