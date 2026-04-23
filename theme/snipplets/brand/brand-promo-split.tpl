{# Banner + grilla 2×2: settings del tema + sección nativa `promo_split_pool` (Productos > Secciones). #}
{% set ps_pool = (sections.promo_split_pool is defined and sections.promo_split_pool.products) ? sections.promo_split_pool.products : [] %}
{% set ps_banner_ok = 'brand_promo_split_banner.jpg' | has_custom_image %}
{% set ps_ready = settings.brand_promo_split_enable and ps_pool is not empty and ps_banner_ok %}

{% if ps_ready %}
	{% set ps_here = false %}
	{% if template == 'home' and settings.brand_promo_split_show_home %}
		{% set ps_here = true %}
	{% elseif template == 'category' and settings.brand_promo_split_show_category %}
		{% set ps_here = true %}
	{% elseif template == 'product' and settings.brand_promo_split_show_product %}
		{% set ps_here = true %}
	{% endif %}

	{% if ps_here %}
		{# Orden = el de TN en Productos > Secciones (arrastrá para reordenar); primeros 4. #}
		{% set ps_products = ps_pool | take(4) %}
		{% if ps_products is not empty %}
			<section class="section-home theme-brand-phase1 brand-promo-split mb-4 mb-md-5 js-product-table" data-store="brand-promo-split" aria-label="{{ 'Colección destacada' | translate }}">
				<div class="container-fluid brand-promo-split__wrap">
					<div class="row no-gutters align-items-start brand-promo-split__row">
						<div class="col-12 col-lg-6 brand-promo-split__col brand-promo-split__col--banner">
							<div class="brand-promo-split__banner-inner">
								<img
									class="brand-promo-split__banner-img"
									src="{{ 'brand_promo_split_banner.jpg' | static_url | settings_image_url('large') }}"
									alt="{{ 'Colección destacada' | translate }}"
									loading="lazy"
									width="900"
									height="1200"
									decoding="async"
								/>
							</div>
						</div>
						<div class="col-12 col-lg-6 brand-promo-split__col brand-promo-split__col--grid">
							<div class="row row-grid no-gutters brand-promo-split__grid">
								{% for product in ps_products %}
									{% include 'snipplets/grid/item.tpl' with {
										promo_split_item: true,
										section_columns_desktop: 2,
										section_columns_mobile: 2,
										section_slider: false,
										image_priority_high: loop.first
									} %}
								{% endfor %}
							</div>
						</div>
					</div>
				</div>
			</section>
		{% endif %}
	{% endif %}
{% endif %}
