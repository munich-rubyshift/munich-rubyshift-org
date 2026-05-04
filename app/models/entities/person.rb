class Entities::Person < ApplicationRecord
  include FriendlyId
  friendly_id :name

  has_many :participations, class_name: "Events::Participation", foreign_key: :entities_person_id, inverse_of: :person
  has_many :events, through: :participations, class_name: "Events::Event"

  def to_s
    name
  end
end
