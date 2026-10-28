# frozen_string_literal: true

class Avo::Fields::WallClockTimeField::ShowComponent < Avo::Fields::ShowComponent
  erb_template <<~'ERB'
    <%= field_wrapper(**field_wrapper_args) do %>
      <%= @field.formatted_value %>
    <% end %>
  ERB
end
