# A form sends "" for an unselected `belongs_to` dropdown. For integers, this gets
# cast to `nil`. For strings, that doesn't happen and we need to do it ourselves.
module StringForeignKeys
  extend ActiveSupport::Concern

  class_methods do
    def string_fk(*names)
      normalizes(*names, with: ->(id) { id.presence })
    end
  end
end
