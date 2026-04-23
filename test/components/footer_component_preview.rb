class FooterComponentPreview < ViewComponent::Preview
  # Footer
  # ---
  # What does it do?
  # You should add a [type] to the params below!
  #
  def default
    render(FooterComponent.new)
  end
end
