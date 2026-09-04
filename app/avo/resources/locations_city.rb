class Avo::Resources::LocationsCity < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Locations::City
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  ADDRESS_COUNT = <<~SQL.squish
    (SELECT COUNT(*) FROM locations_addresses
      WHERE locations_addresses.locations_city_id = locations_cities.id)
  SQL

  # Avo can only pre-select a sort on a real column, and the address count is
  # not one, so the order rides on the index scope instead. Nothing overrides it
  # by default: Avo sorts on `created_at` unless told otherwise, this app has no
  # such column, and a resource without a sort column is left unsorted. Clicking
  # a column header still wins - Avo unscopes the order before applying its own.
  self.index_query = -> { query.order(Arel.sql("#{ADDRESS_COUNT} DESC")) }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :name, as: :text, sortable: true
    field :rubyevents_slug, as: :text, sortable: true
    field :state_code, as: :text, sortable: true
    field :country_code, as: :text, sortable: true
    field :coordinates, as: :belongs_to, **belongs_to_field_options(:coordinates)
  end
end
