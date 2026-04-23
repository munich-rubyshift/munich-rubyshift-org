module Linkable
  extend ActiveSupport::Concern

  included do
    extend ActiveModel::Naming
  end

  class_methods do
    def id_method(name = nil, &block)
      define_method(:to_param) do
        if name
          send(name)
        elsif block_given?
          instance_exec(&block)
        else
          raise "Please provide a method name or block!"
        end
      end
    end

    def label_method(name = nil, &block)
      define_method(:to_s) do
        if name
          send(name)
        elsif block_given?
          instance_exec(&block)
        else
          raise "Please provide a method name or block!"
        end
      end
    end
  end

  def to_model
    self
  end

  def persisted?
    true
  end
end
