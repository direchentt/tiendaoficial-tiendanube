{# Only remove this if you want to take away the theme onboarding advices #}
{% set show_help = not has_products %}

{# Here we will add an example as a help, you can delete this after you upload your products #}

{% if show_help %}
	<div id="product-example">
		{% snipplet 'defaults/show_help_product.tpl' %}
	</div>
{% else %}
	{% embed "snipplets/page-header.tpl" %}
		{% block page_header_text %}{{ "Error" | translate }} - {{ "404" | translate }}{% endblock page_header_text %}
	{% endembed %}
	<section id="page-error">
		<div class="container mb-4">
			{% set related_products = sections.primary.products | take(4) | shuffle %}
			<h2 class="font-body font-family-body mb-3 mb-md-2">{{ "No estamos encontrando lo que estás buscando." | translate }}</h2>
			{% if related_products | length > 1 %}
				<div class="my-2">{{ "Quizás te interesen los siguientes productos." | translate }}</div>
			{% endif %}
			{% if related_products | length > 1 %}
				<div class="section-products-related overflow-none mt-4">
					<div class="row row-grid">
						{% for related in related_products %}
							{% include 'snipplets/grid/item.tpl' with {product : related} %}
						{% endfor %}
					</div>
				</div>
			{% endif %}
		</div>
	</section>
{% endif %}