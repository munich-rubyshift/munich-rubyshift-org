require "decant/content"

module Decant
  class Content
    def self.where(**kwargs)
      scope = all
      kwargs.each do |key, value|
        if value.to_s != "all"
          scope.select! { |page| Array.wrap(page.send(key)).intersect?(Array.wrap(value)) }
        end
      end
      scope
    end
  end
end
