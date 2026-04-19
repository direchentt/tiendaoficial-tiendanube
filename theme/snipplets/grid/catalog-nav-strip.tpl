{# Una sola fila centrada: migas + titulo opcional + densidad de grilla (solo categoria/busqueda con productos). #}
{% if products and (template == 'category' or template == 'search') %}
	{% set _nav_ctx = template == 'search' ? 'search' : 'category' %}
	<div class="catalog-nav-strip">
		<div class="catalog-nav-strip__inner">
			{% if show_nav_breadcrumbs | default(true) %}
				{% include 'snipplets/breadcrumbs.tpl' with { breadcrumbs_custom_class: nav_breadcrumbs_class | default('mb-0') } %}
			{% endif %}
			{% if nav_category_title is defined and nav_category_title != '' %}
				<h1 class="catalog-nav-strip__title mb-0 text-center">{{ nav_category_title }}</h1>
			{% endif %}
			{% include 'snipplets/grid/user-product-grid-toolbar.tpl' with {
				grid_toolbar_for: _nav_ctx,
				toolbar_modifier: 'user-product-grid-toolbar--nav-strip'
			} %}
		</div>
	</div>
{% endif %}
