class Avo::Resources::TalksSpeakerTalk < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Talks::SpeakerTalk
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :talk, as: :belongs_to, **belongs_to_field_options(:talk)
    field :speaker, as: :belongs_to, **belongs_to_field_options(:speaker)
  end
end
