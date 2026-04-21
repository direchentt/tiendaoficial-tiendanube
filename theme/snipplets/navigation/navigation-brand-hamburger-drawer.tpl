{# Layout modal menu: featured root links, tabs = nav entries with children, sublists, optional HTML, category pills with image. #}
{% set brand_tabs = [] %}
{% set brand_root_leaf = [] %}
{% for item in navigation %}
	{% if item.subitems %}
		{% set brand_tabs = brand_tabs | merge([item]) %}
	{% else %}
		{% set brand_root_leaf = brand_root_leaf | merge([item]) %}
	{% endif %}
{% endfor %}

{% set pill_pool = [] %}
{% if categories is defined and categories is not empty %}
	{% for c in categories %}
		{% if c.images is not empty %}
			{% set pill_pool = pill_pool | merge([c]) %}
		{% endif %}
		{% if c.subcategories %}
			{% for sc in c.subcategories %}
				{% if sc.images is not empty %}
					{% set pill_pool = pill_pool | merge([sc]) %}
				{% endif %}
				{% if sc.subcategories %}
					{% for ssc in sc.subcategories %}
						{% if ssc.images is not empty %}
							{% set pill_pool = pill_pool | merge([ssc]) %}
						{% endif %}
					{% endfor %}
				{% endif %}
			{% endfor %}
		{% endif %}
	{% endfor %}
{% endif %}

{% set pills_count = settings.brand_hamburger_pills_count | default('4') %}
{% set pills_pool_shuffled = settings.brand_hamburger_pills_shuffle ? (pill_pool | shuffle) : pill_pool %}
{% set pill_show = pills_pool_shuffled | length > 0 ? (pills_pool_shuffled | take(pills_count)) : [] %}

<div class="brand-hamburger-drawer js-brand-hamburger-drawer">
	{# Cierre unificado en header-hamburger-modal-toolbar (X superior). #}

	{% if brand_root_leaf is not empty %}
		<nav class="brand-hamburger-drawer__featured" aria-label="{{ 'Enlaces destacados' | translate }}">
			<ul class="list-unstyled mb-0">
				{% for item in brand_root_leaf %}
					<li class="brand-hamburger-drawer__featured-item">
						<a class="brand-hamburger-drawer__featured-link font-family-body text-uppercase" href="{% if item.url %}{{ item.url | setting_url }}{% else %}#{% endif %}">{{ item.name }}</a>
					</li>
				{% endfor %}
			</ul>
		</nav>
	{% endif %}

	{% if brand_tabs | length > 1 %}
		<div class="brand-hamburger-drawer__tabs" role="tablist" aria-label="{{ 'Categorías' | translate }}">
			{% for tab in brand_tabs %}
				<button type="button" class="brand-hamburger-drawer__tab js-brand-hamburger-tab btn btn-sm {% if loop.first %}is-active{% endif %}" role="tab" aria-selected="{{ loop.first ? 'true' : 'false' }}" data-brand-tab="{{ loop.index0 }}">{{ tab.name }}</button>
			{% endfor %}
		</div>
	{% endif %}

	<div class="brand-hamburger-drawer__panels">
		{% for tab in brand_tabs %}
			<div class="brand-hamburger-drawer__panel js-brand-hamburger-panel {% if loop.first %}is-active{% endif %}" role="tabpanel" data-brand-panel="{{ loop.index0 }}" {% if not loop.first %}hidden{% endif %}>
				{% include 'snipplets/navigation/navigation-brand-hamburger-subitems.tpl' with { items: tab.subitems, depth: 0, branch_uid: loop.index0 } %}
			</div>
		{% endfor %}
	</div>

	{% if settings.brand_hamburger_drawer_middle_html %}
		<div class="brand-hamburger-drawer__middle font-small brand-hamburger-drawer__middle--spaced">
			{{ settings.brand_hamburger_drawer_middle_html | raw }}
		</div>
	{% endif %}

	{% if pill_show is not empty and settings.brand_hamburger_hide_category_pills != 1 %}
		<section class="brand-hamburger-drawer__pills-section" aria-label="{% if settings.brand_hamburger_pills_title %}{{ settings.brand_hamburger_pills_title }}{% else %}{{ 'Los más deseados' | translate }}{% endif %}">
			<h2 class="brand-hamburger-drawer__pills-heading font-family-body text-uppercase">
				{% if settings.brand_hamburger_pills_title %}
					{{ settings.brand_hamburger_pills_title }}
				{% else %}
					{{ 'Los más deseados' | translate }}
				{% endif %}
			</h2>
			<div class="brand-hamburger-drawer__pills-grid">
				{% for cat in pill_show %}
					<a class="brand-hamburger-drawer__pill" href="{{ cat.url }}">
						<span class="brand-hamburger-drawer__pill-thumb">
							<img src="{{ cat.images | first | category_image_url('small') }}" alt="{{ cat.name }}" width="40" height="40" loading="lazy" class="brand-hamburger-drawer__pill-img" />
						</span>
						<span class="brand-hamburger-drawer__pill-label font-small">{{ cat.name }}</span>
					</a>
				{% endfor %}
			</div>
		</section>
	{% endif %}

	{% if settings.brand_hamburger_footer_link_text and settings.brand_hamburger_footer_link_url %}
		<div class="brand-hamburger-drawer__footer mt-4 pt-3">
			<a class="brand-hamburger-drawer__footer-link font-small" href="{{ settings.brand_hamburger_footer_link_url }}">{{ settings.brand_hamburger_footer_link_text }}</a>
		</div>
	{% endif %}
</div>
