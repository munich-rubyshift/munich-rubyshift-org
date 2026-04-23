class HeaderComponentPreview < ViewComponent::Preview
  # Header
  # ---
  # What does it do?
  # You should add a [type] to the params below!
  #
  def default
    render(HeaderComponent.new)
  end
end
