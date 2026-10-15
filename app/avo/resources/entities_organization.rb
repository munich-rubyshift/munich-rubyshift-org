class Avo::Resources::EntitiesOrganization < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Entities::Organization
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  self.default_sort_column = :slug
  self.default_sort_direction = :asc

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :name, as: :text, sortable: true, help: -> {
      "This is the secondary matching criterium for rubyevents.org. Also, their slug derives from this value: #{record&.rubyevents_slug}"
    }
    field :rubyevents_url, as: :text, only_on: :show,
      format_display_using: -> { link_to value, value, target: "_blank", rel: "noopener noreferrer" if value }
    field :legal_name, as: :text, sortable: true, help: "The legal name, as of the last meetup they hosted."
    field :website, as: :text, sortable: true, help: "This is the primary matching criterium for rubyevents.org."
    field :internal_notes, as: :textarea, help: "Only shown here, e.g. renamings and acquisitions."
    field :venues, as: :has_many, attach_scope: -> { query.by_to_s }
  end
end
