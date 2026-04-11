{% if settings.brands and settings.brands is not empty %}
	{% set brands_slider = settings.brands_format == 'slider' %}
	{% set brands_animated = settings.brands_format == 'animate' %}
	{% set brands_container_classes = brands_slider ? 'swiper-slide slide-container' : brands_animated ? 'home-text d-inline-block mr-4' : 'col-md-1-5 col-4 mb-3' %}
	<section class="section-home section-brands-home {% if settings.brands_colors %}section-home-color section-brands-home-colors{% endif %} overflow-none" data-store="home-brands">
		<div class="container-fluid">
			{% if settings.brands_title %}
				<h2 class="h3-huge h2-huge-md {% if brands_slider %}mb-0{% else %}mb-3{% endif %}">{{ settings.brands_title }}</h2>
			{% endif %}
			{% if brands_slider %}
				<div class="js-swiper-brands swiper-container text-center w-auto">
					<div class="swiper-buttons position-relative p-0 ml-neg-2">
						<div class="js-swiper-brands-prev swiper-button-prev svg-icon-text mb-2">
							<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
						</div>
						<div class="js-swiper-brands-next swiper-button-next svg-icon-text mb-2">
							<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
						</div>
					</div>
					<div class="js-swiper-brands-wrapper swiper-wrapper">
			{% else %}
				<div class="{% if brands_animated %}js-home-message-animated home-text-animated{% else %}row justify-content-center{% endif %}">
					{% if brands_animated %}
						<span class="js-home-message-text-container">
					{% endif %}
			{% endif %}
				{% if brands_animated %}
					{% set repeat_number = 16 %}
				{% else %}
					{% set repeat_number = 1 %}
				{% endif %}
				{% for i in 1..repeat_number %}
					{% for slide in settings.brands %}
						<div class="{{ brands_container_classes }} brand-image-container text-center">
							{% if slide.link %}
								<a href="{{ slide.link | setting_url }}" title="{{ 'Marca {1} de' | translate(loop.index) }} {{ store.name }}" aria-label="{{ 'Marca {1} de' | translate(loop.index) }} {{ store.name }}">
							{% endif %}
								<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ slide.image | static_url | settings_image_url('large') }}" class="lazyload brand-image" alt="{{ 'Marca {1} de' | translate(loop.index) }} {{ store.name }}">
							{% if slide.link %}
								</a>
							{% endif %}
						</div>
					{% endfor %}
				{% endfor %}
				{% if brands_animated %}
					</span>
				{% endif %}
				</div>
			{% if brands_slider %}
				</div>
			{% endif %}
		</div>
	</section>
{% endif %}
