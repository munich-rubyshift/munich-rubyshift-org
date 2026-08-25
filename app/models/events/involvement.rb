class Events::Involvement < ApplicationRecord
  belongs_to :entity, polymorphic: true
  belongs_to :events_event
end
