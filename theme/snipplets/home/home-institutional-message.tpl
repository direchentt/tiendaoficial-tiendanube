{% if settings.institutional_message or settings.institutional_text %}
	{% set institutional_color_classes = settings.institutional_colors ? 'section-institutional-home-colors section-home-color' %}
	{% set institutional_text_classes = settings.institutional_size == 'huge' ? 'h1-extra-huge-md' : settings.institutional_size == 'big' ? 'h2-extra-huge-md' : settings.institutional_size == 'medium' ? 'h1-huge-md' : 'h2-huge-md' %}
	{% set institutional_animated = settings.institutional_animate %}
	{% set institutional_title = settings.institutional_message %}
	{% set institutional_text = settings.institutional_text %}
	{% set institutional_button_and_link = settings.institutional_button and settings.institutional_link %}
	{% set institutional_above_classes = settings.institutional_above ? 'home-institutional-background py-3' %}
	<section class="section-home overflow-none {{ institutional_color_classes }}" data-store="home-institutional-message">
		<div class="container-fluid">
			<div class="row position-relative">
				<div class="{% if institutional_animated and institutional_title %}js-home-message-animated home-text-animated home-text-animated-not-paused mb-3{% else %}col-12{% endif %}">
					{% if institutional_title %}
						{% if institutional_animated %}
							<span class="js-home-message-text-container">
								{% for i in 1..16 %}
									<span class="home-text {{ institutional_text_classes }} h3-huge mr-4">
										{{ institutional_title }}
									</span>
								{% endfor %}
							</span>
						{% else %}
							<h2 class="{{ institutional_text_classes }} h3-huge mb-3">{{ institutional_title }}</h2>
						{% endif %}
					{% endif %}
				</div>
				{% if institutional_text or institutional_button_and_link %}
					<div class="col-md-3 {{ institutional_above_classes }}">
						{% if institutional_text %}
							<p class="mb-3">{{ institutional_text }}</p>
						{% endif %}
						{% if institutional_button_and_link %}
							<a href="{{ settings.institutional_link }}" class="btn btn-link d-inline-block">{{ settings.institutional_button }}</a>
						{% endif %}
					</div>
				{% endif %}
			</div>
		</div>
	</section>
{% endif %}
