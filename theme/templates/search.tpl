{% set has_filters_available = products and has_filters_enabled and product_filters is not empty %}

{% if settings.pagination == 'infinite' %}
	{% paginate by 12 %}
{% else %}
	{% paginate by 48 %}
{% endif %}

<div class="container-fluid">
	{% embed "snipplets/page-header.tpl" with { breadcrumbs: false, container: false} %}
		{% block page_header_text %}
			{% if products %}
				{{ 'Resultados de búsqueda' | translate }}
			{% else %}
				{{ "No encontramos nada para" | translate }}<span class="ml-2">"{{ query }}"</span>
			{% endif %}
		{% endblock page_header_text %}
	{% endembed %}
	{% if products %}
		<h2 class="font-body font-family-body mb-4 pb-2 font-weight-normal">
			{{ "Mostrando los resultados para" | translate }}<span class="ml-2 font-weight-bold">"{{ query }}"</span>
		</h2>
	{% endif %}
</div>

{% include 'snipplets/grid/filters-modals.tpl' %}

<section class="category-body {% if settings.filters_desktop_modal %}pt-md-2{% endif %} overflow-none" aria-label="{{ 'Resultados de búsqueda' | translate }}{% if query %}: {{ query }}{% endif %}">
  <div class="container-fluid {% if products %}mt-3{% endif %} mb-5">
		{% if products or has_applied_filters %}
			<div class="row">
		{% endif %}
			{% include 'snipplets/grid/filters-sidebar.tpl' %}
			{% include 'snipplets/grid/products-list.tpl' %}
		{% if products or has_applied_filters %}
			</div>
		{% endif %}
	</div>
</section>