# Values that /api/rubyevents-v1 puts over the record's attributes, replacing or adding them.
module RubyeventsData
  extend ActiveSupport::Concern

  included do
    normalizes :rubyevents_data, with: ->(data) { data.presence }

    validate :rubyevents_data_fits_json_api
  end

  class_methods do
    def serializer_relationships
      []
    end
  end

  private

  # JSON:API attributes share their names with id, type and the resource's relationships.
  def rubyevents_data_fits_json_api
    case rubyevents_data
    when nil
    when Hash
      taken = rubyevents_data.keys & [ "id", "type", *self.class.serializer_relationships ]
      errors.add(:rubyevents_data, "can't use the reserved names #{taken.to_sentence}") if taken.any?
    else
      errors.add(:rubyevents_data, "must be a JSON object")
    end
  end
end
