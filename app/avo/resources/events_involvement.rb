class Avo::Resources::EventsInvolvement < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Events::Involvement
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :role, as: :text
    field :entity, as: :belongs_to, polymorphic_as: :entity, types: [ ::Entities::Person, ::Entities::Organization ]
    field :event, as: :belongs_to
  end
end
