{# Pool: primary + new + sale. Guards: sections defined, sec_obj truthy, 2 images, dedupe by id, json only plain fields. #}
{% if settings.brand_routine_showcase_enable | default(false) and sections is defined %}
	{% set routine_pool = [] %}
	{% for section_key in ['primary', 'new', 'sale'] %}
		{% set sec_obj = attribute(sections, section_key) %}
		{% if sec_obj and sec_obj.products is defined and sec_obj.products %}
			{% for p in sec_obj.products %}
				{% set routine_pool = routine_pool|merge([p]) %}
			{% endfor %}
		{% endif %}
	{% endfor %}
	{% set routine_pool = routine_pool | shuffle %}
	{% set routine_rows = [] %}
	{% set routine_pick_ids = [] %}
	{% for p in routine_pool %}
		{% if routine_rows|length < 5 and p.id is defined and (p.id not in routine_pick_ids) %}
			{% set ok_two = false %}
			{% set thumb_src = '' %}
			{% set hero_src = '' %}
			{% set hero_large_src = '' %}
			{% if p.images is defined and p.images is iterable and p.images|length >= 2 %}
				{% set img0 = p.images|first %}
				{% set img1 = p.images|slice(1, 1)|first %}
				{% if img0 and img1 %}
					{% set ok_two = true %}
					{% set thumb_src = img0 | product_image_url('large') %}
					{% set hero_src = img1 | product_image_url('large') %}
					{% set hero_large_src = img1 | product_image_url('huge') %}
				{% endif %}
			{% elseif p.featured_image is defined and p.featured_image and p.other_images is defined and p.other_images is not empty %}
				{% set sec_img = p.other_images|first %}
				{% if sec_img %}
					{% set ok_two = true %}
					{% set thumb_src = p.featured_image | product_image_url('large') %}
					{% set hero_src = sec_img | product_image_url('large') %}
					{% set hero_large_src = sec_img | product_image_url('huge') %}
				{% endif %}
			{% endif %}
			{% if ok_two and thumb_src and hero_src %}
				{% set desc_plain = (p.description | default('')) | striptags | trim %}
				{% if desc_plain|length > 220 %}
					{% set desc_plain = desc_plain|slice(0, 217) ~ '...' %}
				{% endif %}
				{% set routine_rows = routine_rows|merge([{
					'name': p.name | default(''),
					'desc': desc_plain,
					'url': p.url | default('#'),
					'thumb': thumb_src,
					'hero': hero_src,
					'heroLarge': hero_large_src
				}]) %}
				{% set routine_pick_ids = routine_pick_ids|merge([p.id]) %}
			{% endif %}
		{% endif %}
	{% endfor %}
	{% if routine_rows|length >= 2 %}
		{% set routine_step_keys = ['BASE', 'COMBINÁ', 'SUMÁ', 'EXTRA', 'CIERRE'] %}
		{% set first_row = routine_rows|first %}
		{# i18n_input en TN puede guardar por idioma (sufijos _es, _pt, etc.); leemos igual que en shoppable stories. #}
		{% set routine_title = (settings.brand_routine_title | default('')) | trim %}
		{% if routine_title == '' %}{% set routine_title = (settings.brand_routine_title_es | default('')) | trim %}{% endif %}
		{% if routine_title == '' %}{% set routine_title = (settings.brand_routine_title_pt | default('')) | trim %}{% endif %}
		{% if routine_title == '' %}{% set routine_title = (settings.brand_routine_title_en | default('')) | trim %}{% endif %}
		{% if routine_title == '' %}{% set routine_title = (settings.brand_routine_title_es_mx | default('')) | trim %}{% endif %}
		{% if routine_title == '' %}
			{% set routine_title = 'Arma tu rutina' | translate %}
		{% endif %}
		{% set routine_intro = (settings.brand_routine_intro | default('')) | trim %}
		{% if routine_intro == '' %}{% set routine_intro = (settings.brand_routine_intro_es | default('')) | trim %}{% endif %}
		{% if routine_intro == '' %}{% set routine_intro = (settings.brand_routine_intro_pt | default('')) | trim %}{% endif %}
		{% if routine_intro == '' %}{% set routine_intro = (settings.brand_routine_intro_en | default('')) | trim %}{% endif %}
		{% if routine_intro == '' %}{% set routine_intro = (settings.brand_routine_intro_es_mx | default('')) | trim %}{% endif %}
		<section
			class="section-home brand-routine-showcase js-brand-routine-showcase theme-brand-phase1{% if settings.brand_home_wide_sections %} mb-5 pb-4{% else %} mb-4 pb-3{% endif %}"
			data-store="home-brand-routine-showcase"
			data-interval="{{ settings.brand_routine_interval | default('6000') }}"
		>
			<div class="container-fluid">
				<div class="brand-routine-card">
					<div class="brand-routine-media">
						<img
							src="{{ first_row.hero }}"
							{% if first_row.heroLarge %}srcset="{{ first_row.heroLarge }} 720w, {{ first_row.hero }} 1200w" sizes="(max-width: 991px) 100vw, 42vw"{% endif %}
							alt="{{ first_row.name }}"
							class="brand-routine-hero"
							data-routine-hero
							width="1200"
							height="1500"
							decoding="async"
							loading="lazy"
						/>
					</div>
					<div class="brand-routine-panel">
						<header class="brand-routine-header">
							<h2 class="brand-routine-title">{{ routine_title }}</h2>
							{% if routine_intro != '' %}
								<p class="brand-routine-intro">{{ routine_intro }}</p>
							{% endif %}
						</header>
						<div class="brand-routine-divider" aria-hidden="true"></div>
						<div class="brand-routine-body">
							<a href="{{ first_row.url }}" class="brand-routine-thumb-wrap js-brand-routine-link" data-routine-link>
								<img
									src="{{ first_row.thumb }}"
									alt="{{ first_row.name }}"
									class="brand-routine-thumb"
									data-routine-thumb
									width="480"
									height="600"
									decoding="async"
									loading="lazy"
								/>
							</a>
							<div class="brand-routine-copy">
								<p class="brand-routine-kicker">
									<span class="brand-routine-kicker-line" aria-hidden="true"></span>
									<span>{{ 'Producto' | translate }}</span>
								</p>
								<h3 class="brand-routine-name js-brand-routine-name" data-routine-name>{{ first_row.name }}</h3>
								<div class="brand-routine-desc js-brand-routine-desc user-content" data-routine-desc>{{ first_row.desc }}</div>
							</div>
						</div>
						<nav class="brand-routine-steps" aria-label="{{ 'Pasos' | translate }}">
							{% for row in routine_rows %}
								{% set sn = loop.index %}
								{% set step_label = (attribute(settings, 'brand_routine_step_' ~ sn ~ '_label') | default('')) | trim %}
								{% if step_label == '' %}{% set step_label = (attribute(settings, 'brand_routine_step_' ~ sn ~ '_label_es') | default('')) | trim %}{% endif %}
								{% if step_label == '' %}{% set step_label = (attribute(settings, 'brand_routine_step_' ~ sn ~ '_label_pt') | default('')) | trim %}{% endif %}
								{% if step_label == '' %}{% set step_label = (attribute(settings, 'brand_routine_step_' ~ sn ~ '_label_en') | default('')) | trim %}{% endif %}
								{% if step_label == '' %}{% set step_label = (attribute(settings, 'brand_routine_step_' ~ sn ~ '_label_es_mx') | default('')) | trim %}{% endif %}
								{% if step_label == '' %}
									{% set step_label = (routine_step_keys[loop.index0] | default('')) | translate %}
								{% endif %}
								<button
									type="button"
									class="brand-routine-step js-brand-routine-step{% if loop.first %} is-active{% endif %}"
									data-routine-index="{{ loop.index0 }}"
									aria-pressed="{{ loop.first ? 'true' : 'false' }}"
								>
									<span class="brand-routine-step-num">{% if loop.index < 10 %}0{% endif %}{{ loop.index }}</span>
									<span class="brand-routine-step-label">{{ step_label }}</span>
								</button>
							{% endfor %}
						</nav>
					</div>
				</div>
			</div>
			<script type="application/json" class="js-brand-routine-data">{{ routine_rows | json_encode | raw }}</script>
		</section>
	{% endif %}
{% endif %}
