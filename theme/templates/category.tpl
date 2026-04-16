{% set has_filters_available = products and has_filters_enabled and (filter_categories is not empty or product_filters is not empty) %}

{# Only remove this if you want to take away the theme onboarding advices #}
{% set show_help = not has_products %}

{% if settings.pagination == 'infinite' %}
	{% paginate by 12 %}
{% else %}
	{% paginate by 48 %}
{% endif %}

{% if not show_help %}

{% include 'snipplets/brand/brand-split-video-hero.tpl' %}

{% set category_banner = (category.images is not empty) or ("banner-products.jpg" | has_custom_image) %}
{% set has_category_description_without_banner = not category_banner and category.description %}

{% if category_banner %}
    {% include 'snipplets/category-banner.tpl' %}
{% endif %}

{% if category.description or not category_banner %}
	<div class="container-fluid">
		{% set page_header_padding = category.description ? false : true %}
		{% set page_header_classes = category.description ? 'pt-4 pb-2 pt-md-4 pb-md-2' %}
		{% if category_banner %}
			{% include 'snipplets/breadcrumbs.tpl' with {breadcrumbs_custom_class: 'mt-4'} %}
		{% else %}
			{% embed "snipplets/page-header.tpl" with {container: false, padding: page_header_padding, page_header_class: page_header_classes} %}
			    {% block page_header_text %}{{ category.name }}{% endblock page_header_text %}
			{% endembed %}
		{% endif %}
		{% if category.description %}
			<p class="{% if category_banner %}mt-3 py-md-2{% else %}mb-4 pb-1{% endif %}">{{ category.description }}</p>
		{% endif %}
	</div>
{% endif %}

{% include 'snipplets/grid/filters-modals.tpl' %}

<section class="category-body {% if settings.filters_desktop_modal %}pt-md-2{% endif %}" data-store="category-grid-{{ category.id }}" aria-label="{{ category.name }}: {{ 'Listado de productos' | translate }}">
	<div class="container-fluid mt-3 mb-5">
		<div class="row">
			{% include 'snipplets/grid/filters-sidebar.tpl' %}
			{% include 'snipplets/grid/products-list.tpl' %}
		</div>
	</div>
</section>
{% elseif show_help %}
	{# Category Placeholder #}
	{% include 'snipplets/defaults/show_help_category.tpl' %}
{% endif %}