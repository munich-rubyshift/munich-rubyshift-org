---
title: "Welcome"
category_slugs: []
---
<%= render HeroComponent.new %>

<section>
<h2 class="section-title">Recent talks</h2>
<div class="talks-grid">
<% Talks::Talk.includes(:speakers, :event).sort_by { |talk| talk.event.start_date || Date.new(0) }.last(3).reverse_each do |talk| %>
<%= render Talks::TalkCardComponent.new(talk) %>
<% end %>
</div>
<p><%= link_to "All talks →", talks_talks_path %></p>
</section>

<%= render GetInvolvedComponent.new %>
