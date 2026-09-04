class Avo::Resources::EventsParticipation < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Events::Participation
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :person, as: :belongs_to, **belongs_to_field_options(:person)
    field :event, as: :belongs_to, **belongs_to_field_options(:event)
    field :attended_as, as: :text, sortable: true
  end
end
