class ApplicationComponent < ViewComponent::Base
  delegate :avo, to: :helpers
end
