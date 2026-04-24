{% embed "snipplets/page-header.tpl" %}
	{% block page_header_text %}{{ page.name | default("Combos") }}{% endblock page_header_text %}
{% endembed %}

{# Página institucional TN con plantilla combo — mismo bloque que categoría /combos/ #}
{% include 'snipplets/brand/hache-bundles-storefront.tpl' with { intro_html: page.content } %}
