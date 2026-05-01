class ComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../../templates/view_component/frozen_extensions", __dir__)

  argument :attrs, type: :array, default: [], banner: "attribute"

  def generate_component_with_preview_and_locale
    in_root do
      system("bin/rails generate view_component:component #{name} #{attrs.join(" ")} --preview --preview_path=test/components --locale --skip-test-framework --skip-template-engine")
    end
  end

  def add_erb_template
    template "erb_template.html.erb.tt", File.join("app/components", class_path, "#{file_name}_component.html.erb")
  end

  def add_css_file
    template "bem_stylesheet.css.tt", File.join("app/components", class_path, "#{file_name}_component.css")
  end

  def add_unpoly_compiler
    template "unpoly_compiler.js.tt", File.join("app/components", class_path, "#{file_name}_component.js")
  end

  def add_view_spec
    template "view_spec.rb.tt", File.join("test/components", class_path, "#{file_name}_component_test.rb")
  end

  def add_jasmine_spec
    template "jasmine_spec.js.tt", File.join("test/components", class_path, "#{file_name}_component_spec.js")
  end

  # Needs to only apply to files with a git diff. Otherwise, very annoying.
  # def fix_module_nesting_via_rubocop_because_it_was_impossible_to_get_module_namespacing_to_work_as_expected
  #   in_root do
  #     system("bash", "-c", 'bin/rubocop --only Style/ClassAndModuleChildren,Layout/IndentationWidth,Layout/CommentIndentation --autocorrect-all --force-exclusion --config <(echo "Style/ClassAndModuleChildren: { EnforcedStyle: nested }")')
  #   end
  # end

  private

  def js_attributes
    attrs.map { |attr| attr.camelize(:lower) }
  end

  def css_attributes
    attrs.map(&:dasherize)
  end

  def bem_selectors
    base = file_path.gsub("/", "---").dasherize.prepend(".")
    [
      base,
      *css_attributes.map { |attr| "#{base}--#{attr}" }
    ]
  end

  def up_data
    data = js_attributes.zip(attrs).map { |js_attr, attr| "#{js_attr}: @#{attr}" }.join(", ")
    "{ #{data} }"
  end

  def up_data_params
    data = js_attributes.join(", ")
    "{ #{data} }"
  end

  # https://github.com/ViewComponent/view_component/blob/main/lib/generators/view_component/preview/preview_generator.rb#L32
  def render_signature
    return if attributes.blank?

    attributes.map { |attr| %(#{attr.name}: "#{attr.name}") }.join(", ")
  end
end
