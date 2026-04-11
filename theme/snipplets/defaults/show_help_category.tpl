{% include "snipplets/svg/empty-placeholders.tpl" %}

<section class="mb-md-3">
	{% embed "snipplets/page-header.tpl" with {breadcrumbs: false, container_fluid: true} %}
		{% block page_header_text %}{{ category.name }}{% endblock page_header_text %}
	{% endembed %}
</section>
<section class="category-body" data-store="category-grid">
	<div class="container-fluid mt-3 mb-5">
		<div class="row row-grid">
			{% include 'snipplets/defaults/help_item.tpl' with {'help_item_1': true} %}
			{% include 'snipplets/defaults/help_item.tpl' with {'help_item_2': true} %}
			{% include 'snipplets/defaults/help_item.tpl' with {'help_item_3': true} %}
			{% include 'snipplets/defaults/help_item.tpl' with {'help_item_4': true} %}
			{% include 'snipplets/defaults/help_item.tpl' with {'help_item_5': true} %}
			{% include 'snipplets/defaults/help_item.tpl' with {'help_item_6': true} %}
			{% include 'snipplets/defaults/help_item.tpl' with {'help_item_7': true} %}
			{% include 'snipplets/defaults/help_item.tpl' with {'help_item_8': true} %}
			{% include 'snipplets/defaults/help_item.tpl' with {'help_item_1': true} %}
			{% include 'snipplets/defaults/help_item.tpl' with {'help_item_2': true} %}
		</div>
	</div>
</section>