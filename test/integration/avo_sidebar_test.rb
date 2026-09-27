require "test_helper"

# The ejected Avo::SidebarComponent heads each model namespace with its own
# group instead of listing every resource under one "Resources" heading.
class AvoSidebarTest < ActionDispatch::IntegrationTest
  # Written out rather than read from NAMESPACE_ORDER, so a typo there moves
  # its group to the bottom and fails this.
  test "resources are grouped by namespace in the configured order" do
    assert_equal [ "Entities", "Talks", "Sponsors", "Events", "Venues", "Locations" ], sidebar_groups.keys
  end

  test "a group lists its resources alphabetically" do
    assert_equal [ "CFPs", "Events", "Involvements", "Participations", "Series" ], sidebar_groups["Events"]
  end

  test "a namespace missing from the order follows the listed ones alphabetically" do
    resources = [ Avo::Resources::EventsEvent, Avo::Resources::VenuesVenue, Avo::Resources::LocationsCity ]
    sidebar = Avo::SidebarComponent.new
    sidebar.define_singleton_method(:resources) { resources }

    stub_const(Avo::SidebarComponent, :NAMESPACE_ORDER, %w[Venues]) do
      assert_equal %w[Venues Events Locations], sidebar.resource_groups.map(&:first)
    end
  end

  private
    # { heading => link labels } as the desktop sidebar renders them.
    def sidebar_groups
      get "/avo/resources/events_events"
      assert_response :success

      css_select("[data-sidebar-target=sidebar] div.uppercase").to_h do |heading|
        group = heading.parent.parent
        [ heading.text.strip, group.css("a").map { |link| link.text.strip } ]
      end
    end
end
