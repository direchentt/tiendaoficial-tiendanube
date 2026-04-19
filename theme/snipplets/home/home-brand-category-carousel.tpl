{# 6 tiles: image + label + URL; Swiper 3 per view desktop, dots mobile; drag enabled in JS. #}
{% set carousel_items = [] %}
{% for ci in 1..6 %}
	{% set img_name = 'brand_category_carousel_' ~ ci ~ '.jpg' %}
	{% set has_img = img_name | has_custom_image %}
	{% set lab_key = 'brand_category_carousel_' ~ ci ~ '_label' %}
	{% set url_key = 'brand_category_carousel_' ~ ci ~ '_url' %}
	{% set lab = attribute(settings, lab_key) | default('') | trim %}
	{% if lab is empty %}
		{% set lab = attribute(settings, lab_key ~ '_es') | default('') | trim %}
	{% endif %}
	{% if lab is empty %}
		{% set lab = attribute(settings, lab_key ~ '_pt') | default('') | trim %}
	{% endif %}
	{% if lab is empty %}
		{% set lab = attribute(settings, lab_key ~ '_en') | default('') | trim %}
	{% endif %}
	{% if lab is empty %}
		{% set lab = attribute(settings, lab_key ~ '_es_mx') | default('') | trim %}
	{% endif %}
	{% set href_raw = attribute(settings, url_key) | default('') | trim %}
	{% if href_raw is empty %}
		{% set href_raw = attribute(settings, url_key ~ '_es') | default('') | trim %}
	{% endif %}
	{% if href_raw is empty %}
		{% set href_raw = attribute(settings, url_key ~ '_pt') | default('') | trim %}
	{% endif %}
	{% if href_raw is empty %}
		{% set href_raw = attribute(settings, url_key ~ '_en') | default('') | trim %}
	{% endif %}
	{% if href_raw is empty %}
		{% set href_raw = attribute(settings, url_key ~ '_es_mx') | default('') | trim %}
	{% endif %}
	{% if has_img and lab and href_raw %}
		{% set href_final = href_raw | setting_url %}
		{% set carousel_items = carousel_items|merge([{ index: ci, label: lab, href: href_final, alt: lab }]) %}
	{% endif %}
{% endfor %}

{% if settings.brand_category_carousel_enable | default(false) and carousel_items|length > 0 %}
	<section
		class="brand-category-carousel section-home theme-brand-phase1"
		data-store="home-brand-category-carousel"
		aria-label="{{ 'Carrusel de categorias' | translate }}"
	>
		<div class="brand-category-carousel__wrap position-relative">
			<button
				type="button"
				class="brand-category-carousel__arrow brand-category-carousel__arrow--prev js-swiper-brand-category-carousel-prev d-none d-md-flex"
				aria-controls="swiper-brand-category-carousel"
			>
				<span class="brand-category-carousel__arrow-inner svg-icon-text" aria-hidden="true">
					<svg class="icon-inline icon-lg icon-flip-horizontal" width="24" height="24" focusable="false"><use xlink:href="#arrow-long"/></svg>
				</span>
				<span class="visually-hidden">{{ 'Anterior' | translate }}</span>
			</button>
			<div id="swiper-brand-category-carousel" class="swiper-container js-swiper-brand-category-carousel">
				<div class="swiper-wrapper">
					{% for item in carousel_items %}
						<div class="swiper-slide brand-category-carousel__slide">
							<a href="{{ item.href }}" class="brand-category-carousel__card" aria-label="{{ item.label | e('html_attr') }}">
								<div class="brand-category-carousel__media">
									<img
										src="{{ 'images/empty-placeholder.png' | static_url }}"
										data-src="{{ ('brand_category_carousel_' ~ item.index ~ '.jpg') | static_url }}"
										alt=""
										width="900"
										height="1200"
										class="lazyload brand-category-carousel__img"
										data-sizes="auto"
									/>
								</div>
								<span class="brand-category-carousel__btn brand-category-cta__btn brand-split-video__btn">{{ item.label }}</span>
							</a>
						</div>
					{% endfor %}
				</div>
			</div>
			<button
				type="button"
				class="brand-category-carousel__arrow brand-category-carousel__arrow--next js-swiper-brand-category-carousel-next d-none d-md-flex"
				aria-controls="swiper-brand-category-carousel"
			>
				<span class="brand-category-carousel__arrow-inner svg-icon-text" aria-hidden="true">
					<svg class="icon-inline icon-lg" width="24" height="24" focusable="false"><use xlink:href="#arrow-long"/></svg>
				</span>
				<span class="visually-hidden">{{ 'Siguiente' | translate }}</span>
			</button>
		</div>
		<div class="js-swiper-brand-category-carousel-pagination brand-category-carousel__pagination swiper-pagination swiper-pagination-bullets d-md-none" aria-hidden="true"></div>
	</section>
{% endif %}
