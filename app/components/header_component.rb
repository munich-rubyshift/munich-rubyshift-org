class HeaderComponent < ApplicationComponent
  # Marks the link as current on its own page and on all pages below it.
  # (Unpoly manages aria-current itself and only for exact matches.)
  def nav_link(name, path, also: [])
    current = [ path, *also ].include?(request.path) || request.path.start_with?("#{path}/")
    link_to name, path, class: ("header--link-current" if current)
  end
end
