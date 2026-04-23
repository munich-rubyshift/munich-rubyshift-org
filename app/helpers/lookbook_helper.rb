module LookbookHelper
  def render_preview_scenario(preview_entity_or_name, scenario_entity_or_name, params: {})
    preview = case preview_entity_or_name
    when Lookbook::PreviewEntity
      preview_entity_or_name
    when String, Symbol
      Lookbook.previews.find { |p| p.lookup_path == preview_entity_or_name.to_s }
    else
      raise ArgumentError, "Expected a Lookbook::PreviewEntity or a String/Symbol lookup path"
    end

    scenario_name = case scenario_entity_or_name
    when Lookbook::ScenarioEntity
      scenario_entity_or_name.name
    when String, Symbol
      scenario_entity_or_name.to_s
    else
      raise ArgumentError, "Expected a Lookbook::ScenarioEntity or a String/Symbol scenario name"
    end

    render_args = preview.render_args(scenario_name, params: params)

    # https://github.com/lookbook-hq/lookbook/blob/main/app/views/lookbook/previews/preview.html.erb
    if render_args[:component]
      if defined?(Phlex::SGML) && render_args[:component].is_a?(Phlex::SGML)
        if defined?(Phlex::VERSION) && Gem::Version.new(Phlex::VERSION) < Gem::Version.new("2.0.0")
          raw(render_args[:component].call(view_context: self, &render_args[:block]))
        else
          render(render_args[:component], render_args[:args], &render_args[:block])
        end
      else
        render(render_args[:component], render_args[:args], &render_args[:block])
      end
    else
      render(render_args[:template], **render_args[:locals], &render_args[:block])
    end
  end
end
