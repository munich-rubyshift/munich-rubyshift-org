module NormalizedStrings
  extend ActiveSupport::Concern

  class_methods do
    def normalized_strings(*names)
      normalizes(*names, with: ->(value) { value.presence })
    end
  end
end
