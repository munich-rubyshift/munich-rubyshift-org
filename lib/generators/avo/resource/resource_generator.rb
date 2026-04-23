require "generators/avo/resource_generator"

module Generators
  module Avo
    class ResourceGenerator
      no_tasks do
        def field_string(name, type, options)
          return "field :slug, as: :id, format_using: -> { link_to value, main_app.polymorphic_path(record), \"data-turbo\": false }" if name.to_sym == :slug
          "field :#{name}, as: :#{type}#{options}"
        end

        def generate_fields_from_args
          @args.each do |arg|
            name, type = arg.split(":")
            type = "string" if type.blank?
            fields[name] = field(name, type.to_sym)
          end

          ", format_index_using: -> { content_tag(:span, \"#\", title: value) }#{generated_fields_template}"
        end

        def field(name, type)
          return { field: "id" } if name.to_sym == :id
          return { field: "id" } if name.to_sym == :slug
          ::Avo::Mappings::NAMES_MAPPING[name.to_sym] || ::Avo::Mappings::FIELDS_MAPPING[type&.to_sym] || { field: "text" }
        end
      end
    end
  end
end
