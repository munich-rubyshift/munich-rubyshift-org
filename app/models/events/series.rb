class Events::Series < ApplicationRecord
  include FriendlyId
  friendly_id :name

  has_many :events, class_name: "Events::Event", foreign_key: :events_series_id, inverse_of: :series
end
