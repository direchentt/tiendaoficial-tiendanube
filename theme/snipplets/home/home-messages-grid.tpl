{% set welcome = welcome | default(false) %}
{% set announcement = announcement | default(false) %}

{% if welcome %}
	{% set num_messages = 0 %}
	{% set section_id = 'welcome' %}
	{% set section_animated = settings.welcome_animate %}
	{% set section_text_classes = settings.welcome_size == 'big' ? 'h1-huge' : settings.welcome_size == 'medium' ? 'h2-huge' : 'h1' %}
	{% set section_repeat_number = settings.welcome_repeat %}
{% endif %}

{% if announcement %}
	{% set num_messages = 0 %}
	{% set section_id = 'announcement' %}
	{% set section_animated = settings.announcement_animate %}
	{% set section_text_classes = settings.announcement_size == 'big' ? 'h1-huge' : settings.announcement_size == 'medium' ? 'h2-huge' : 'h1' %}
	{% set section_repeat_number = settings.announcement_repeat %}
{% endif %}

{% for section_id in [section_id ~ '_01', section_id ~ '_02', section_id ~ '_03'] %}
	{% set section_text = attribute(settings,"#{section_id}_message") %}
	{% if section_text %}
		{% set num_messages = num_messages + 1 %}
	{% endif %}
{% endfor %}

{% if num_messages %}
	{% if not section_animated %}
		<div class="container-fluid text-center">
	{% endif %}
	{% for i in 1..section_repeat_number %}
		{% if section_animated %}
			{% set section_animated_class = loop.index is even ? '-reverse' %}
			<div class="js-home-message-animated{{ section_animated_class }} home-text-animated">
				<span class="js-home-message-text-container{{ section_animated_class }}">
		{% else %}
			<div class="home-text-container">
		{% endif %}
			{% if section_animated %}
				{% if num_messages == 1 %}
					{% set repeat_number = 16 %}
				{% else %}
					{% set repeat_number = num_messages == 2 ? '8' : '5' %}
				{% endif %}
			{% else %}
				{% set repeat_number = 1 %}
			{% endif %}
			{% for i in 1..repeat_number %}
				{% for section_id in [section_id ~ '_01', section_id ~ '_02', section_id ~ '_03'] %}
					{% set section_message = attribute(settings,"#{section_id}_message") %}
					{% set section_link = attribute(settings,"#{section_id}_link") %}
					{% if section_message %}
						<span class="home-text {{ section_text_classes }} mr-4">
							{% if section_link %}
								<a href="{{ section_link }}">
							{% endif %}
							{{ section_message }}
							{% if section_link %}
								</a>
							{% endif %}
						</span>
					{% endif %}
				{% endfor %}
			{% endfor %}
		{% if section_animated %}
				</span>
			</div>
		{% else %}
			</div>
		{% endif %}
	{% endfor %}
	{% if not section_animated %}
		</div>
	{% endif %}
{% endif %}
