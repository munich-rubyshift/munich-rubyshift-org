class LayoutComponentPreview < ViewComponent::Preview
  # Layout
  # ---
  # What does it do?
  # You should add a [type] to the params below!
  #
  def default
    render(LayoutComponent.new)
  end
end
