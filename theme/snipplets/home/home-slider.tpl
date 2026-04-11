{% set has_main_slider = settings.slider and settings.slider is not empty %}
{% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}
{% set has_left_text = settings.slider_align == 'left' %}
{% set has_centered_text = settings.slider_align == 'center' %}
{% set has_right_text = settings.slider_align == 'right' %}
{% set slider_title_size_mobile = settings.slider_title_size_mobile == 'small' ? 'h4-huge' : settings.slider_title_size_mobile == 'medium' ? 'h2-huge' : 'h1-huge' %}
{% set slider_title_size_desktop = settings.slider_title_size_desktop == 'small' ? 'h2-huge-md' : settings.slider_title_size_desktop == 'medium' ? 'h1-huge-md' : 'h2-extra-huge-md' %}

{% if not mobile %}
<div class="js-home-main-slider-container {% if not has_main_slider %}hidden{% endif %}">
{% endif %}
	<div class="{% if mobile %}js-home-mobile-slider{% else %}js-home-main-slider{% endif %}-visibility {% if has_main_slider and has_mobile_slider %}{% if mobile %}d-md-none{% else %}d-none d-md-block{% endif %}{% elseif not settings.toggle_slider_mobile and mobile %}hidden{% endif %}">
		<div class="section-slider position-relative{% if settings.brand_slider_editorial %} section-slider--brand-editorial{% endif %}">
			<div class="js-home-slider{% if mobile %}-mobile{% endif %} h-100 swiper-container swiper-container-horizontal">
				<div class="swiper-wrapper">
					{% if mobile %}
						{% set slider = settings.slider_mobile %}
					{% else %}
						{% set slider = settings.slider %}
					{% endif %}
					{% for slide in slider %}
						{% set has_text = slide.title or slide.description or slide.button %}
						<div class="swiper-slide slide-container swiper-{{ slide.color }}">
							{% if slide.link %}
								<a href="{{ slide.link | setting_url }}" aria-label="{{ 'Carrusel' | translate }} {{ loop.index }}">
							{% endif %}
							<div class="slider-slide">

								{% set apply_lazy_load = 
									settings.home_order_position_1 != 'slider' 
									or not (
										loop.first and (
											(has_main_slider and not has_mobile_slider) or 
											(has_mobile_slider and mobile)
										)
									) 
								%}

								{% if apply_lazy_load %}
									{% set slide_src = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==' %}
								{% else %}
									{% set slide_src = slide.image | static_url | settings_image_url('large') %}
								{% endif %}

								<img 
									{% if not apply_lazy_load %}fetchpriority="high"{% endif %}
									{% if slide.width and slide.height %} width="{{ slide.width }}" height="{{ slide.height }}" {% endif %}
									{% if apply_lazy_load %}data-{% endif %}src="{{ slide_src }}"
									{% if apply_lazy_load %}data-{% endif %}srcset="{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w"  
									class="slider-image {% if settings.slider_animation %}slider-image-animation{% endif %} {% if apply_lazy_load %}swiper-lazy fade-in{% endif %}" alt="{{ 'Carrusel' | translate }} {{ loop.index }}"
								/>
								<div class="placeholder-fade"></div>
								{% if has_text %}
									<div class="swiper-text{% if has_centered_text %} swiper-text-centered{% elseif has_right_text %} swiper-text-right{% endif %} swiper-text-{{ slide.color }}">
										{% if slider | length > 1 %}
											<div class="mb-1 mb-md-2">{{ loop.index }} / {{ loop.length }}</div>
										{% endif %}
										{% if slide.title %}
											<h2 class="{{ slider_title_size_mobile }} {{ slider_title_size_desktop }} mb-2 mb-md-3{% if has_left_text %} ml-neg-2{% elseif has_right_text %} mr-neg-1{% endif %}">{{ slide.title }}</h2>
										{% endif %}
										{% if slide.description %}
											<p class="mb-2 mb-md-3">{{ slide.description }}</p>
										{% endif %}
										{% if slide.button and slide.link %}
											<div class="btn btn-link d-inline-block mb-2 mb-md-3">{{ slide.button }}</div>
										{% endif %}
									</div>
								{% endif %}
							</div>
							{% if slide.link %}
								</a>
							{% endif %}
						</div>
					{% endfor %}
				</div>
				<div class="js-swiper-home-arrows swiper-buttons">
					<div class="js-swiper-home-control js-swiper-home-prev{% if mobile %}-mobile{% endif %} swiper-button-prev svg-icon-text">
						<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
					</div>
					<div class="js-swiper-home-control js-swiper-home-next{% if mobile %}-mobile{% endif %} swiper-button-next svg-icon-text">
						<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
					</div>
				</div>
			</div>
		</div>
	</div>
{% if not mobile %}
</div>
{% endif %}