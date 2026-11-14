# Values for RubyEvents that replace or add to the record's attributes.
module RubyeventsData
  extend ActiveSupport::Concern

  included do
    normalizes :rubyevents_data, with: ->(data) { data.presence }

    validate :rubyevents_data_fits_json_api
  end

  private

  # JSON:API attributes share their names with id and type.
  def rubyevents_data_fits_json_api
    case rubyevents_data
    when nil
    when Hash
      taken = rubyevents_data.keys & [ "id", "type" ]
      errors.add(:rubyevents_data, "can't use the reserved names #{taken.to_sentence}") if taken.any?
    else
      errors.add(:rubyevents_data, "must be a JSON object")
    end
  end
end
