{% if settings.brand_split_video_enable %}
	{% set show_here = false %}
	{% set force_show_home = force_show|default(false) %}
	{% if template == 'home' and (force_show_home or settings.brand_split_video_show_home) %}
		{% set show_here = true %}
	{% elseif template == 'category' and settings.brand_split_video_show_category %}
		{% set show_here = true %}
	{% elseif template == 'product' and settings.brand_split_video_show_pdp %}
		{% set show_here = true %}
	{% endif %}

	{# i18n_input: si el idioma activo de la vitrina queda vacio, usar el primer enlace guardado en otro idioma #}
	{% set url1 = settings.brand_split_video_1_url|default('')|trim %}
	{% if url1 is empty %}
		{% set url1 = attribute(settings, 'brand_split_video_1_url_es')|default('')|trim %}
	{% endif %}
	{% if url1 is empty %}
		{% set url1 = attribute(settings, 'brand_split_video_1_url_pt')|default('')|trim %}
	{% endif %}
	{% if url1 is empty %}
		{% set url1 = attribute(settings, 'brand_split_video_1_url_en')|default('')|trim %}
	{% endif %}
	{% if url1 is empty %}
		{% set url1 = attribute(settings, 'brand_split_video_1_url_es_mx')|default('')|trim %}
	{% endif %}
	{% set url2 = settings.brand_split_video_2_url|default('')|trim %}
	{% if url2 is empty %}
		{% set url2 = attribute(settings, 'brand_split_video_2_url_es')|default('')|trim %}
	{% endif %}
	{% if url2 is empty %}
		{% set url2 = attribute(settings, 'brand_split_video_2_url_pt')|default('')|trim %}
	{% endif %}
	{% if url2 is empty %}
		{% set url2 = attribute(settings, 'brand_split_video_2_url_en')|default('')|trim %}
	{% endif %}
	{% if url2 is empty %}
		{% set url2 = attribute(settings, 'brand_split_video_2_url_es_mx')|default('')|trim %}
	{% endif %}
	{% set has_url1 = url1|length > 0 %}
	{% set has_url2 = url2|length > 0 %}
	{% set is_split = has_url1 and has_url2 %}

	{% if show_here and has_url1 %}
		<section class="brand-split-video-hero{% if is_split %} brand-split-video-hero--split{% endif %} theme-brand-phase1" data-store="brand-split-video-hero" aria-label="{{ 'Video' | translate }}">
			<div class="brand-split-video-hero__grid">
				{% include 'snipplets/brand/brand-split-video-cell.tpl' with {
					cell_raw_url: url1,
					cell_kicker: settings.brand_split_video_1_kicker,
					cell_title: settings.brand_split_video_1_title,
					cell_btn1: settings.brand_split_video_1_btn1,
					cell_btn1_url: settings.brand_split_video_1_btn1_url,
					cell_btn2: settings.brand_split_video_1_btn2,
					cell_btn2_url: settings.brand_split_video_1_btn2_url
				} %}
				{% if is_split %}
					{% include 'snipplets/brand/brand-split-video-cell.tpl' with {
						cell_raw_url: url2,
						cell_kicker: settings.brand_split_video_2_kicker,
						cell_title: settings.brand_split_video_2_title,
						cell_btn1: settings.brand_split_video_2_btn1,
						cell_btn1_url: settings.brand_split_video_2_btn1_url,
						cell_btn2: settings.brand_split_video_2_btn2,
						cell_btn2_url: settings.brand_split_video_2_btn2_url
					} %}
				{% endif %}
			</div>
		</section>
	{% endif %}
{% endif %}
