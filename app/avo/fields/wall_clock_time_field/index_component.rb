# frozen_string_literal: true

class Avo::Fields::WallClockTimeField::IndexComponent < Avo::Fields::IndexComponent
  erb_template <<~'ERB'
    <%= index_field_wrapper(**field_wrapper_args) do %>
      <%= @field.formatted_value %>
    <% end %>
  ERB
end
