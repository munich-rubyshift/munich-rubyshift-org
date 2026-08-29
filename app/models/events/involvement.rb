class Events::Involvement < ApplicationRecord
  include StringForeignKeys

  ENTITY_TYPES = %w[Entities::Person Entities::Organization].freeze

  belongs_to :event, class_name: "Events::Event", foreign_key: :events_event_id, inverse_of: :involvements
  belongs_to :entity, polymorphic: true

  string_fk :events_event_id, :entity_id

  # `belongs_to` only validates when the foreign key is nil or changed, so validate explicitly.
  validates :entity, presence: true
  validates :entity_type, inclusion: { in: ENTITY_TYPES }
  validates :entity_id, uniqueness: { scope: [ :entity_type, :events_event_id, :role ] }

  def to_s
    "#{entity} (#{role} @ #{event})"
  end
end
