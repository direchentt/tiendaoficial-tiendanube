{# Banner + grilla 2×2: settings del tema + sección `promo_split_pool` (Productos > Secciones).
   Banner: imagen subida TN o URL (imagen https o video: archivo .mp4/.webm, YouTube, Vimeo, TikTok). URL tiene prioridad si está definida y es válida. #}
{% set ps_pool = (sections.promo_split_pool is defined and sections.promo_split_pool.products) ? sections.promo_split_pool.products : [] %}
{% set ps_media_url = settings.brand_promo_split_media_url | default('') | trim %}
{% set ps_lower = ps_media_url | lower %}
{% set ps_video_file =
	ps_media_url != ''
		and (
			('.mp4' in ps_lower)
			or ('.webm' in ps_lower)
			or ('.m4v' in ps_lower)
			or ('.mov' in ps_lower)
			or ('.ogv' in ps_lower)
		)
%}
{% set ps_video_embed =
	ps_media_url != ''
		and (
			('youtube.com' in ps_lower)
			or ('youtu.be' in ps_lower)
			or ('vimeo.com' in ps_lower)
			or ('player.vimeo.com' in ps_lower)
			or ('tiktok.com' in ps_lower)
		)
%}
{% set ps_is_video = ps_video_file or ps_video_embed %}
{% set ps_https = ps_media_url|slice(0, 8) == 'https://' or ps_media_url|slice(0, 7) == 'http://' %}
{% set ps_use_image_url = ps_media_url != '' and not ps_is_video and ps_https %}
{% set ps_upload_ok = 'brand_promo_split_banner.jpg' | has_custom_image %}
{# URL válida tiene prioridad al renderizar; si la URL no sirve pero hay imagen subida, se usa el upload. #}
{% set ps_url_works = ps_media_url != '' and (ps_is_video or ps_use_image_url) %}
{% set ps_banner_media_ok = ps_url_works or ps_upload_ok %}
{% set ps_ready = settings.brand_promo_split_enable and ps_pool is not empty and ps_banner_media_ok %}

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
		{% set ps_products = ps_pool | take(4) %}
		{% if ps_products is not empty %}
			<section class="section-home theme-brand-phase1 brand-promo-split mb-4 mb-md-5 js-product-table" data-store="brand-promo-split" aria-label="{{ 'Colección destacada' | translate }}">
				<div class="container-fluid brand-promo-split__wrap">
					<div class="row no-gutters align-items-start brand-promo-split__row">
						<div class="col-12 col-lg-6 brand-promo-split__col brand-promo-split__col--banner">
							<div class="brand-promo-split__banner-inner">
								{% if ps_url_works and ps_is_video %}
									{% include 'snipplets/brand/brand-video-media.tpl' with {
										video_raw_url: ps_media_url,
										video_autoplay: true,
										video_muted: true,
										video_class: 'brand-promo-split__banner-video-el',
										video_preload: 'metadata'
									} %}
								{% elseif ps_use_image_url %}
									<img
										class="brand-promo-split__banner-img"
										src="{{ ps_media_url | e('html_attr') }}"
										alt="{{ 'Colección destacada' | translate }}"
										loading="lazy"
										decoding="async"
										referrerpolicy="no-referrer-when-downgrade"
									/>
								{% elseif ps_upload_ok %}
									<img
										class="brand-promo-split__banner-img"
										src="{{ 'brand_promo_split_banner.jpg' | static_url | settings_image_url('large') }}"
										alt="{{ 'Colección destacada' | translate }}"
										loading="lazy"
										width="900"
										height="1200"
										decoding="async"
									/>
								{% endif %}
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
