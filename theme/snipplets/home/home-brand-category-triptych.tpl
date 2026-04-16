{% set has_item_1 = ('brand_category_triptych_1.jpg' | has_custom_image) and settings.brand_category_triptych_1_btn1 and settings.brand_category_triptych_1_btn1_url %}
{% set has_item_2 = ('brand_category_triptych_2.jpg' | has_custom_image) and settings.brand_category_triptych_2_btn1 and settings.brand_category_triptych_2_btn1_url %}
{% set has_item_3 = ('brand_category_triptych_3.jpg' | has_custom_image) and settings.brand_category_triptych_3_btn1 and settings.brand_category_triptych_3_btn1_url %}

{% if settings.brand_category_triptych_enable and (has_item_1 or has_item_2 or has_item_3) %}
<section class="brand-category-triptych section-home theme-brand-phase1" data-store="home-brand-category-triptych">
	<div class="swiper-container js-swiper-brand-category-triptych">
	<div class="brand-category-triptych__grid swiper-wrapper">
		{% for idx in 1..3 %}
			{% set has_image = ('brand_category_triptych_' ~ idx ~ '.jpg') | has_custom_image %}
			{% set btn1 = attribute(settings, 'brand_category_triptych_' ~ idx ~ '_btn1')|default('')|trim %}
			{% set btn1_url = attribute(settings, 'brand_category_triptych_' ~ idx ~ '_btn1_url')|default('')|trim %}
			{% set btn2 = attribute(settings, 'brand_category_triptych_' ~ idx ~ '_btn2')|default('')|trim %}
			{% set btn2_url = attribute(settings, 'brand_category_triptych_' ~ idx ~ '_btn2_url')|default('')|trim %}
			{% set kicker = attribute(settings, 'brand_category_triptych_' ~ idx ~ '_kicker')|default('')|trim %}
			{% set title = attribute(settings, 'brand_category_triptych_' ~ idx ~ '_title')|default('')|trim %}
			{% set has_btn1 = btn1 and btn1_url %}
			{% set has_btn2 = btn2 and btn2_url %}
			{% set has_overlay = kicker or title or has_btn1 or has_btn2 %}

			{% if has_image and has_btn1 %}
				<article class="brand-category-triptych__item swiper-slide">
					<div class="brand-category-triptych__media">
						<img
							src="{{ 'images/empty-placeholder.png' | static_url }}"
							data-src="{{ ('brand_category_triptych_' ~ idx ~ '.jpg') | static_url }}"
							alt="{{ title ? title|e : btn1|e }}"
							width="900"
							height="1200"
							class="lazyload img-fluid brand-category-triptych__img"
							data-sizes="auto"
						/>
					</div>
					{% if has_overlay %}
						<div class="brand-split-video__overlay">
							<div class="brand-split-video__overlay-inner">
								{% if kicker %}
									<p class="brand-split-video__kicker">{{ kicker }}</p>
								{% endif %}
								{% if title %}
									<h2 class="brand-split-video__title">{{ title }}</h2>
								{% endif %}
								<div class="brand-split-video__actions">
									<a href="{{ btn1_url }}" class="brand-split-video__btn">{{ btn1 }}</a>
									{% if has_btn2 %}
										<a href="{{ btn2_url }}" class="brand-split-video__btn">{{ btn2 }}</a>
									{% endif %}
								</div>
							</div>
						</div>
					{% endif %}
				</article>
			{% endif %}
		{% endfor %}
	</div>
	</div>
	<div class="js-swiper-brand-category-triptych-pagination swiper-pagination d-md-none"></div>
</section>
{% endif %}
