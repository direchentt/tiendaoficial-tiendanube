{# Paneles SSR: un bloque por categoría (mismo orden que las pestañas). mark_first_panel solo en el include raíz. #}
{% for category in categories %}
	{% set is_first_panel = mark_first_panel|default(false) and loop.first %}
	<div
		class="js-brand-category-rail-panel{% if is_first_panel %} is-active{% else %} d-none{% endif %}"
		data-rail-panel-url="{{ category.url }}"
		data-brand-rail-panel="1"
	>
		<div class="js-brand-category-rail-track js-product-table d-flex flex-nowrap brand-category-rail__row">
			{% set panel_products = category.products|default([]) %}
			{% if panel_products is not empty %}
				{% for product in panel_products|slice(0, 24) %}
					{% include 'snipplets/grid/item.tpl' with {
						section_columns_desktop: settings.grid_columns_desktop,
						section_columns_mobile: settings.grid_columns_mobile,
						section_slider: false,
						has_filters: false,
						image_priority_high: loop.index < 3
					} %}
				{% endfor %}
			{% else %}
				<div class="col-12 py-4 text-center text-muted small brand-category-rail__panel-fallback" data-rail-panel-empty="1">
					<p class="mb-2">{{ 'Esta categoría no tiene productos directos para render SSR en el carril.' | translate }}</p>
					<p class="mb-0">
						<a href="{{ category.url }}" class="btn btn-sm btn-outline-primary">{{ 'Ver categoría' | translate }}</a>
					</p>
				</div>
			{% endif %}
		</div>
	</div>
	{% if category.subcategories(false) %}
		{% include 'snipplets/brand/brand-category-rail-panels-recurse.tpl' with { categories: category.subcategories(false), mark_first_panel: false } %}
	{% endif %}
{% endfor %}
