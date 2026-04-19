{# Shoppable Stories: video + producto por slide. Carrusel Swiper. story_slides solo guarda escalares (evita merge con entidad producto en algunos motores TN). #}
{% if settings.brand_shoppable_stories_enable | default(false) and sections is defined %}
	{% set shoppable_pool = [] %}
	{# En PDP el producto actual no suele estar en sections: lo sumamos para que matchee brand_shoppable_slide_*_product_id. #}
	{% if product is defined and product and product.id is defined %}
		{% set shoppable_pool = shoppable_pool|merge([product]) %}
	{% endif %}
	{% for section_key in ['primary', 'new', 'sale', 'products', 'novelties'] %}
		{% set sec_obj = attribute(sections, section_key) %}
		{% if sec_obj and sec_obj.products is defined and sec_obj.products %}
			{% for p in sec_obj.products %}
				{% set shoppable_pool = shoppable_pool|merge([p]) %}
			{% endfor %}
		{% endif %}
	{% endfor %}
	{% set story_slides = [] %}
	{% for i in 1..6 %}
		{% set vurl = attribute(settings, 'brand_shoppable_slide_' ~ i ~ '_video_url') | default('') | trim %}
		{% if vurl is empty %}
			{% set vurl = attribute(settings, 'brand_shoppable_slide_' ~ i ~ '_video_url_es') | default('') | trim %}
		{% endif %}
		{% if vurl is empty %}
			{% set vurl = attribute(settings, 'brand_shoppable_slide_' ~ i ~ '_video_url_pt') | default('') | trim %}
		{% endif %}
		{% if vurl is empty %}
			{% set vurl = attribute(settings, 'brand_shoppable_slide_' ~ i ~ '_video_url_en') | default('') | trim %}
		{% endif %}
		{% if vurl is empty %}
			{% set vurl = attribute(settings, 'brand_shoppable_slide_' ~ i ~ '_video_url_es_mx') | default('') | trim %}
		{% endif %}
		{% set pid_raw = attribute(settings, 'brand_shoppable_slide_' ~ i ~ '_product_id') | default('') | trim %}
		{% if vurl %}
			{% set slide_product = null %}
			{% if pid_raw %}
				{% for p in shoppable_pool %}
					{% if slide_product is null and (p.id is defined) and ((p.id ~ '') == (pid_raw ~ '')) %}
						{% set slide_product = p %}
					{% endif %}
				{% endfor %}
			{% endif %}
			{% set story_slides = story_slides|merge([{ video: vurl, product_id: pid_raw, matched_product: slide_product }]) %}
		{% endif %}
	{% endfor %}
	{% if story_slides|length > 0 %}
		{% set st_title = (settings.brand_shoppable_stories_title | default('')) | trim %}
		{% if st_title == '' %}
			{% set st_title = 'Mira nuestros productos en accion' | translate %}
		{% endif %}
		{% set st_autoplay = settings.brand_shoppable_stories_autoplay | default(1) %}
		{% set st_muted = settings.brand_shoppable_stories_muted | default(1) %}
		{% set st_layout = settings.brand_shoppable_stories_layout | default('classic') %}
		{% if st_layout != 'mobile_two_full' %}
			{% set st_layout = 'classic' %}
		{% endif %}
		{% set st_autoplay_on = st_autoplay == 1 or st_autoplay == true %}
		{% set st_muted_on = st_muted == 1 or st_muted == true %}
		<section
			class="section-home brand-shoppable-stories js-brand-shoppable-stories-root theme-brand-phase1 brand-shoppable-stories--layout-{{ st_layout }}{% if settings.brand_home_wide_sections %} mb-5 pb-4{% else %} mb-4 pb-3{% endif %}"
			data-store="home-brand-shoppable-stories"
			data-shoppable-layout="{{ st_layout }}"
			data-story-aria-mute="{{ 'Silenciar video' | translate | e('html_attr') }}"
			data-story-aria-unmute="{{ 'Activar audio del video' | translate | e('html_attr') }}"
			aria-label="{{ 'Carrusel de videos con productos' | translate }}"
		>
			<div class="container-fluid">
				<header class="brand-shoppable-stories__head text-center text-md-left mb-3 mb-md-4">
					<h2 class="section-title brand-shoppable-stories__title h3-huge h2-huge-md mb-0">{{ st_title }}</h2>
				</header>
				<div class="brand-shoppable-stories__wrap position-relative">
					<div
						class="brand-shoppable-stories__swiper-shell{% if st_layout == 'mobile_two_full' %} brand-shoppable-stories__swiper-shell--bleed-xs{% endif %}"
					>
					<div id="swiper-brand-shoppable-stories" class="swiper-container js-swiper-brand-shoppable-stories">
						<div class="swiper-wrapper">
							{% for slide in story_slides %}
								{% set sp = slide.matched_product %}
								{% set st_thumb = null %}
								{% if sp %}
									{% if sp.images is defined and sp.images is not empty %}
										{% set st_thumb = sp.images | first %}
									{% elseif sp.featured_image is defined and sp.featured_image %}
										{% set st_thumb = sp.featured_image %}
									{% endif %}
								{% endif %}
								{% set thumb_url = 'images/empty-placeholder.png' | static_url %}
								{% if st_thumb %}
									{% set thumb_url = st_thumb | product_image_url('large') %}
								{% endif %}
								{# Mismo archivo en varios slides: el navegador suele atar el buffer a un solo <video>; query única por slide. #}
								{% set video_src = slide.video %}
								{% set video_src_lower = video_src|lower %}
								{% if video_src and (('.mp4' in video_src_lower) or ('.webm' in video_src_lower) or ('.m4v' in video_src_lower) or ('.mov' in video_src_lower)) %}
									{% if '?' in video_src %}
										{% set video_src = video_src ~ '&ss=' ~ loop.index %}
									{% else %}
										{% set video_src = video_src ~ '?ss=' ~ loop.index %}
									{% endif %}
								{% endif %}
								<div class="swiper-slide" data-brand-story-slide>
									<div class="brand-shoppable-stories__slide-card{% if not sp %} brand-shoppable-stories__slide-card--video-only{% endif %}">
										<div class="brand-shoppable-stories__media">
											<div class="brand-shoppable-stories__media-inner">
												{# Sin poster del producto en el video: en desktop varios slides visibles quedan pausados y el poster se veia como foto gigante hasta hacer click. #}
												{% include 'snipplets/brand/brand-video-media.tpl' with {
													video_raw_url: video_src,
													video_autoplay: false,
													video_muted: st_muted_on,
													video_class: 'js-brand-shoppable-story-native brand-shoppable-stories__native-video',
													video_preload: 'auto'
												} %}
											</div>
										</div>
										{% if sp %}
											<div class="brand-shoppable-stories__shop brand-shoppable-stories__shop--overlay">
												<a href="{{ sp.url }}" class="brand-shoppable-stories__thumb-link">
													<img
														src="{{ thumb_url }}"
														alt="{{ sp.name }}"
														width="96"
														height="96"
														class="brand-shoppable-stories__thumb"
														decoding="async"
														loading="lazy"
													/>
												</a>
												<div class="brand-shoppable-stories__shop-body">
													<p class="brand-shoppable-stories__shop-name mb-1">{{ sp.name }}</p>
													{% if sp.display_price is defined and sp.display_price %}
														<p class="brand-shoppable-stories__shop-price mb-2">{{ sp.price | money_nocents }}</p>
													{% else %}
														<p class="brand-shoppable-stories__shop-price mb-2 d-none" hidden></p>
													{% endif %}
													<a href="{{ sp.url }}" class="btn btn-sm brand-shoppable-stories__shop-cta">{{ 'Comprar' | translate }}</a>
												</div>
											</div>
										{% else %}
											<div class="brand-shoppable-stories__shop brand-shoppable-stories__shop--floating">
												<a href="{{ slide.video }}" class="btn btn-sm brand-shoppable-stories__ext-link" target="_blank" rel="noopener noreferrer">{{ 'Ver video' | translate }}</a>
											</div>
										{% endif %}
									</div>
								</div>
							{% endfor %}
						</div>
					</div>
					</div>
					<button
						type="button"
						class="brand-shoppable-stories__mute js-brand-story-mute{% if st_muted_on %} is-muted{% else %} is-unmuted{% endif %}"
						aria-pressed="{% if st_muted_on %}true{% else %}false{% endif %}"
						{% if st_muted_on %}
							aria-label="{{ 'Activar audio del video' | translate }}"
						{% else %}
							aria-label="{{ 'Silenciar video' | translate }}"
						{% endif %}
					>
						<span class="brand-shoppable-stories__mute-visual" aria-hidden="true">
							<svg class="brand-shoppable-stories__mute-svg brand-shoppable-stories__mute-svg--on" width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M11 5L6 9H4v6h2l5 4V5z" fill="currentColor"/><path d="M16.5 7.5l-1.4 1.4M19.1 4.9l-1.4 1.4M19.1 19.1l-1.4-1.4M16.5 16.5l-1.4-1.4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>
							<svg class="brand-shoppable-stories__mute-svg brand-shoppable-stories__mute-svg--off" width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M11 5L6 9H4v6h2l5 4V5z" fill="currentColor"/><path d="M15.5 9.5c1.5 1.2 2.3 2.8 2.3 4.5s-.8 3.3-2.3 4.5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>
						</span>
					</button>
				</div>
				<div class="js-swiper-brand-shoppable-stories-pagination brand-shoppable-stories__pagination swiper-pagination swiper-pagination-bullets mt-3" aria-hidden="true"></div>
			</div>
		</section>
	{% endif %}
{% endif %}
