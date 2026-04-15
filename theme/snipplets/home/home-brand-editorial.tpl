{% set brand_ed_has_image = 'brand_editorial_image.jpg' | has_custom_image %}
{% set brand_ed_has_copy = settings.brand_editorial_kicker or settings.brand_editorial_title or settings.brand_editorial_text %}
{% set brand_ed_has_cta = settings.brand_editorial_btn and settings.brand_editorial_url %}
{% set brand_ed_img_alt = settings.brand_editorial_title is not empty ? settings.brand_editorial_title|e : (settings.brand_editorial_kicker is not empty ? settings.brand_editorial_kicker|e : ('Franja editorial marca' | translate)) %}
{% if brand_ed_has_image or brand_ed_has_copy or brand_ed_has_cta %}
<section class="section-home section-brand-editorial" data-store="home-brand-editorial">
	<div class="container-fluid">
		<div class="row no-gutters align-items-stretch section-brand-editorial__row">
			{% if brand_ed_has_image %}
			<div class="col-12 col-md-6 section-brand-editorial__media">
				<figure class="section-brand-editorial__figure mb-0">
					<img
						src="{{ 'images/empty-placeholder.png' | static_url }}"
						data-src="{{ 'images/brand_editorial_image.jpg' | static_url }}"
						alt="{{ brand_ed_img_alt }}"
						width="1200"
						height="1600"
						class="lazyload img-fluid section-brand-editorial__img"
						data-sizes="auto"
					/>
				</figure>
			</div>
			{% endif %}
			<div class="col-12 {% if brand_ed_has_image %}col-md-6{% endif %} section-brand-editorial__content d-flex flex-column justify-content-center">
				<div class="section-brand-editorial__inner">
					{% if settings.brand_editorial_kicker %}
						<p class="section-brand-editorial__kicker mb-2">{{ settings.brand_editorial_kicker }}</p>
					{% endif %}
					{% if settings.brand_editorial_title %}
						<h2 class="section-brand-editorial__title mb-3">{{ settings.brand_editorial_title }}</h2>
					{% endif %}
					{% if settings.brand_editorial_text %}
						<div class="section-brand-editorial__text mb-3">{{ settings.brand_editorial_text }}</div>
					{% endif %}
					{% if brand_ed_has_cta %}
						<a href="{{ settings.brand_editorial_url }}" class="btn btn-primary section-brand-editorial__btn">{{ settings.brand_editorial_btn }}</a>
					{% endif %}
				</div>
			</div>
		</div>
	</div>
</section>
{% endif %}
