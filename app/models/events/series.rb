class Events::Series < ApplicationRecord
  include FriendlyId
  friendly_id :name

  KINDS = %w[conference meetup retreat hackathon event podcast online organisation workshop].freeze
  FREQUENCIES = %w[yearly monthly weekly irregular biweekly biyearly quarterly].freeze

  has_many :events, class_name: "Events::Event", foreign_key: :events_series_id, inverse_of: :series

  validates :kind, inclusion: { in: KINDS }, allow_blank: true
  validates :frequency, inclusion: { in: FREQUENCIES }, allow_blank: true

  def to_s
    name
  end
end
