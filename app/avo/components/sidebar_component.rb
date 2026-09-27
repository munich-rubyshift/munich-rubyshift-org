# frozen_string_literal: true

class Avo::SidebarComponent < Avo::BaseComponent
  # The sidebar groups resources by their model's namespace, in this order.
  # A namespace missing from the list still shows up, alphabetically after
  # the listed ones, so a new one needs no change here to be reachable.
  NAMESPACE_ORDER = %w[Entities Talks Sponsors Events Venues Locations].freeze

  prop :sidebar_open, default: false
  prop :for_mobile, default: false

  def dashboards
    return [] unless Avo.plugin_manager.installed?("avo-dashboards")

    Avo::Dashboards.dashboard_manager.dashboards_for_navigation
  end

  def resources
    Avo.resource_manager.resources_for_navigation helpers._current_user
  end

  # [[heading, resources]] pairs. A model outside any namespace has none to
  # head its group, so that group takes Avo's own "Resources" heading.
  def resource_groups
    resources
      .group_by { |resource| resource.model_class.name.deconstantize.presence }
      .sort_by { |namespace, _| [ NAMESPACE_ORDER.index(namespace) || NAMESPACE_ORDER.size, namespace.to_s ] }
      .map { |namespace, group| [ namespace&.titleize || t("avo.resources"), group.sort_by(&:navigation_label) ] }
  end

  def tools
    Avo.tool_manager.tools_for_navigation
  end

  def stimulus_target
    @for_mobile ? "mobileSidebar" : "sidebar"
  end
end
