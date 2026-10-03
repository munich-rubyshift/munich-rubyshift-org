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
    field :entity, as: :belongs_to, **belongs_to_field_options(:entity), polymorphic_as: :entity, types: [ ::Entities::Person, ::Entities::Organization ]
    field :event, as: :belongs_to, **belongs_to_field_options(:event), attach_scope: -> { query.order(start_date: :desc, start_time: :desc) }
    field :role, as: :text, sortable: true
  end
end
