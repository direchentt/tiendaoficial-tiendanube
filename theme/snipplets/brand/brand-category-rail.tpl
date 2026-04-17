{% set rail_ctx = rail_context|default('home') %}
{% set rail_load_mode = settings.brand_category_rail_load_mode|default('ajax') %}
{% set rail_block_title = settings.brand_category_rail_title ? settings.brand_category_rail_title : ('Novedades' | translate) %}
{# Primera categoría: productos SSR solo en modos ajax/link (un solo track). #}
{% set rail_first_cat = categories|default([])|first %}
{% set rail_ssr_products = [] %}
{% if rail_load_mode != 'panels' and rail_first_cat %}
	{% set rail_ssr_products = rail_first_cat.products|default([])|slice(0, 24) %}
{% endif %}
{% if not settings.brand_category_rail_enable %}
{% elseif rail_ctx == 'product' and not settings.brand_category_rail_show_on_product %}
{% elseif (categories|default([])) is empty %}
	<section class="theme-brand-phase1 brand-category-rail brand-category-rail--empty js-brand-category-rail" data-brand-category-rail-context="{{ rail_ctx }}" data-store="brand-category-rail-empty">
		<div class="container-fluid py-3">
			<p class="mb-0 text-muted small">{{ 'No hay categorías para mostrar. Configurá el menú de categorías en tu administrador.' | translate }}</p>
		</div>
	</section>
{% else %}
	<section
		class="theme-brand-phase1 brand-category-rail js-brand-category-rail"
		data-brand-category-rail-context="{{ rail_ctx }}"
		data-store="brand-category-rail"
		data-rail-load-mode="{{ rail_load_mode }}"
		data-product-item-slider="{{ settings.product_item_slider ? '1' : '0' }}"
		{% if rail_load_mode != 'panels' and rail_ssr_products is not empty %}data-rail-ssr-preload="1"{% endif %}
		aria-label="{{ rail_block_title | e('html_attr') }}"
	>
		<div class="container-fluid brand-category-rail__inner py-4">
			<div class="brand-category-rail__head row align-items-center no-gutters mb-3">
				<div class="col">
					<h2 class="brand-category-rail__title mb-0">{{ rail_block_title }}</h2>
				</div>
				<div class="col-auto">
					<button type="button" class="brand-category-rail__persp btn btn-link p-0 text-body js-brand-category-rail-perspective" aria-pressed="false" aria-label="{{ 'Ver otra perspectiva' | translate }}">
						<span class="brand-category-rail__persp-track" aria-hidden="true"></span>
						<span class="brand-category-rail__persp-label small">{{ 'Ver otra perspectiva' | translate }}</span>
					</button>
				</div>
			</div>
			<nav class="brand-category-rail__nav mb-3" aria-label="{{ 'Categorías' | translate }}">
				<ul class="brand-category-rail__tabs list-unstyled mb-0 js-brand-category-rail-tabs" role="menubar">
					{% include 'snipplets/brand/brand-category-rail-tabs.tpl' with { categories: categories|default([]), mark_first_rail_tab_active: true, rail_load_mode: rail_load_mode } %}
					<li class="brand-category-rail__tab-item" role="none">
						{% if rail_load_mode == 'link' %}
							<a href="{{ store.products_url }}" class="brand-category-rail__tab brand-category-rail__tab--link" role="menuitem">
								<span class="brand-category-rail__tab-name">{{ 'Ver todo' | translate }}</span>
							</a>
						{% else %}
							<button type="button" class="brand-category-rail__tab js-brand-category-rail-tab" role="menuitem" data-url="{{ store.products_url }}">
								<span class="brand-category-rail__tab-name">{{ 'Ver todo' | translate }}</span>
							</button>
						{% endif %}
					</li>
				</ul>
			</nav>
			<div class="brand-category-rail__status small text-muted mb-2 js-brand-category-rail-status d-none" role="status" aria-live="polite"></div>
			<div class="brand-category-rail__viewport position-relative">
				<div class="brand-category-rail__loading js-brand-category-rail-loading position-absolute w-100 h-100 d-none align-items-center justify-content-center" aria-hidden="true">
					<span class="spinner-border spinner-border-sm text-body" role="presentation"></span>
				</div>
				{% if rail_load_mode == 'panels' %}
					<div class="js-brand-category-rail-panel-stack w-100">
						{% include 'snipplets/brand/brand-category-rail-panels-recurse.tpl' with { categories: categories|default([]), mark_first_panel: true } %}
						<div class="js-brand-category-rail-panel d-none" data-rail-panel-url="{{ store.products_url }}" data-brand-rail-panel="1">
							<div class="js-brand-category-rail-track d-flex flex-nowrap brand-category-rail__row">
								<div class="col-12 py-4 text-center">
									<a href="{{ store.products_url }}" class="btn btn-outline-primary">{{ 'Ver catálogo completo' | translate }}</a>
								</div>
							</div>
						</div>
					</div>
				{% else %}
					<div class="brand-category-rail__track js-brand-category-rail-track d-flex flex-nowrap brand-category-rail__row">
						{% if rail_ssr_products is not empty %}
							{% for product in rail_ssr_products %}
								{% include 'snipplets/grid/item.tpl' with {
									section_columns_desktop: settings.grid_columns_desktop,
									section_columns_mobile: settings.grid_columns_mobile,
									section_slider: false,
									has_filters: false,
									image_priority_high: loop.index < 3
								} %}
							{% endfor %}
						{% endif %}
					</div>
				{% endif %}
			</div>
			<div class="brand-category-rail__dots-row mt-2">
				<div
					class="brand-category-rail__dots js-brand-category-rail-dots d-none"
					role="group"
					aria-label="{{ 'Paginación del carril de productos' | translate }}"
				></div>
			</div>
		</div>
	</section>
{% endif %}
