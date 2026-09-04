class Avo::Resources::LocationsAddress < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Locations::Address
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :street, as: :text, sortable: true
    field :zip_code, as: :text, sortable: true
    field :city, as: :belongs_to, **belongs_to_field_options(:city)
    field :coordinates, as: :belongs_to, **belongs_to_field_options(:coordinates)
  end
end
