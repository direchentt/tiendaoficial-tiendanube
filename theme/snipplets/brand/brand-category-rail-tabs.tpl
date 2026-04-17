{# Pestañas recursivas: mismas URLs que el menú. rail_load_mode: ajax|panels = botón+data-url; link = <a href>. #}
{% for category in categories %}
	<li class="brand-category-rail__tab-item" role="none">
		{% if rail_load_mode|default('ajax') == 'link' %}
			<a
				href="{{ category.url }}"
				class="brand-category-rail__tab brand-category-rail__tab--link{% if mark_first_rail_tab_active|default(false) and loop.first %} brand-category-rail__tab--active{% endif %}"
				role="menuitem"
			>
				<span class="brand-category-rail__tab-name">{{ category.name }}</span>
			</a>
		{% else %}
			<button
				type="button"
				class="brand-category-rail__tab js-brand-category-rail-tab{% if mark_first_rail_tab_active|default(false) and loop.first %} brand-category-rail__tab--active{% endif %}"
				role="menuitem"
				data-url="{{ category.url }}"
			>
				<span class="brand-category-rail__tab-name">{{ category.name }}</span>
			</button>
		{% endif %}
	</li>
	{% if category.subcategories(false) %}
		{% include 'snipplets/brand/brand-category-rail-tabs.tpl' with { categories: category.subcategories(false), mark_first_rail_tab_active: false, rail_load_mode: rail_load_mode|default('ajax') } %}
	{% endif %}
{% endfor %}
