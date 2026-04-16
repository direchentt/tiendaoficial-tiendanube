{# Page title + optional breadcrumbs. Params (all optional): breadcrumbs, container, padding, container_fluid, page_header_class, page_header_title_class #}

{% set show_breadcrumbs = breadcrumbs is defined ? breadcrumbs : true %}
{% set use_container = container is defined ? container : true %}
{% set use_padding = padding is defined ? padding : true %}
{% set use_container_fluid = container_fluid is defined ? container_fluid : false %}

{% if show_breadcrumbs %}
	{% include 'snipplets/breadcrumbs.tpl' with { breadcrumbs_custom_class: breadcrumbs_custom_class | default('') } %}
{% endif %}

<div class="page-header{{ page_header_class is defined ? ' ' ~ page_header_class : '' }}{{ use_padding ? ' pb-3' : '' }}">
	{% if use_container or use_container_fluid %}
		<div class="container-fluid">
	{% endif %}
			<h1 class="{{ page_header_title_class | default('h2-huge') }}">
				{% block page_header_text %}{% endblock %}
			</h1>
	{% if use_container or use_container_fluid %}
		</div>
	{% endif %}
</div>
