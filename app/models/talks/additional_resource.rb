class Talks::AdditionalResource < ApplicationRecord
  KINDS = %w[
    write-up blog article source-code code repo github documentation docs
    presentation video podcast audio gem library transcript handout notes
    photos link book
  ].freeze

  belongs_to :talk, class_name: "Talks::Talk", foreign_key: :talks_talk_id, inverse_of: :additional_resources

  validates :name, presence: true
  validates :url, presence: true
  validates :kind, inclusion: { in: KINDS }

  def to_s
    "#{name} (#{kind} @ #{talk})"
  end
end
