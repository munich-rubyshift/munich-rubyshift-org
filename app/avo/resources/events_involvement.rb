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
    # Avo has no default for the type alone, but an unsaved person sets the
    # type and leaves the person to pick.
    field :entity, as: :belongs_to, **belongs_to_field_options(:entity), polymorphic_as: :entity, types: [ ::Entities::Person, ::Entities::Organization ], default: -> { ::Entities::Person.new }
    field :event, as: :belongs_to, **belongs_to_field_options(:event), attach_scope: -> { query.by_start_date.reverse_order }
    field :role, as: :text, sortable: true, default: "Organizer"
  end
end
