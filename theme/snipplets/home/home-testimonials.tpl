{% set has_home_testimonials = false %}
{% set num_testimonials = 0 %}
{% for testimonial in ['testimonial_01', 'testimonial_02', 'testimonial_03', 'testimonial_04'] %}
	{% set testimonial_image = "#{testimonial}.jpg" | has_custom_image %}
	{% set testimonial_name = attribute(settings,"#{testimonial}_name") %}
	{% set testimonial_description = attribute(settings,"#{testimonial}_description") %}
	{% set has_testimonial = testimonial_name or testimonial_description or testimonial_image %}
	{% if has_testimonial %}
		{% set has_home_testimonials = true %}
		{% set num_testimonials = num_testimonials + 1 %}
	{% endif %}
{% endfor %}

{% if has_home_testimonials %}
	<section class="section-home section-testimonials-home overflow-none" data-store="home-testimonials">
		<div class="container-fluid">
			<div class="js-swiper-testimonials swiper-testimonials swiper-container">
				<div class="swiper-buttons position-relative p-0 ml-neg-2">
					<div class="js-swiper-testimonials-prev swiper-button-prev svg-icon-text mb-2">
						<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
					</div>
					<div class="js-swiper-testimonials-next swiper-button-next svg-icon-text mb-2">
						<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
					</div>
				</div>
				<div class="swiper-wrapper">
					{% for testimonial in ['testimonial_01', 'testimonial_02', 'testimonial_03', 'testimonial_04'] %}
						{% set testimonial_image = "#{testimonial}.jpg" | has_custom_image %}
						{% set testimonial_name = attribute(settings,"#{testimonial}_name") %}
						{% set testimonial_description = attribute(settings,"#{testimonial}_description") %}
						{% set has_testimonial = testimonial_name or testimonial_description or testimonial_image %}
						{% if has_testimonial %}
							<div class="swiper-slide p-0">
								<div class="mb-3">{{ loop.index }} / {{ num_testimonials }}</div>
								{% if testimonial_description %}
									<p class="font-huge mb-3">{{ testimonial_description }}</p>
								{% endif %}
								<div class="row justify-content-end mt-3 mb-4">
									{% if testimonial_image %}
										<div class="col position-relative">
											<img class="testimonial-image d-block w-100 lazyautosizes lazyload" src="{{ 'images/empty-placeholder.png' | static_url }}" data-src='{{ "#{testimonial}.jpg" | static_url | settings_image_url("small") }}' {% if testimonial_name %}alt="{{ testimonial_name }}"{% else %}alt="{{ 'Testimonio de' | translate }} {{ store.name }}"{% endif %} />
											<div class="placeholder-fade"></div>
										</div>
									{% endif %}
									<div class="col-auto">
										<div class="testimonial-quote">”</div>
									</div>
								</div>
								{% if testimonial_name %}
									<h3 class="font-family-body font-body mb-2">{{ testimonial_name }}</h3>
								{% endif %}
							</div>
						{% endif %}
					{% endfor %}
				</div>
			</div>
		</div>
	</section>
{% endif %}
