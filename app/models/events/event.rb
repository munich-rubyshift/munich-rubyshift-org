class Events::Event < ApplicationRecord
  include FriendlyId
  friendly_id :title
  belongs_to :venues_venue
end
