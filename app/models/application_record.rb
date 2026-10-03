class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Order by "to_s". Pass the name of a "belongs_to" association to "on"
  # to order by the associated record's "to_s".
  def self.by_to_s(on: nil)
    records = on ? includes(on) : all

    # Sort in Ruby. It's currently fast enough and we can avoid caching "to_s".
    sorted = records.sort_by do |record|
      label = (on ? record.public_send(on) : record).to_s
      [ label.blank? ? 1 : 0, label.downcase, label, record.id ]
    end

    # Set "filter: false" to not discard any elements. However, if we pass an empty
    # list to `in_order_of`, it still discards everything, so we need to fix that.
    sorted.empty? ? all : in_order_of(:id, sorted.map(&:id), filter: false)
  end
end
