{% if products and pages.is_last %}
	<div class="last-page" style="display:none;"></div>
{% endif %}
{% for product in products %}
    {% set image_priority_high_value = false %}
    {% if loop.index in [1, 2] %}
        {% set image_priority_high_value = true %}
    {% endif %}
    {% include 'snipplets/grid/item.tpl' with {image_priority_high: image_priority_high_value} %}
{% endfor %}