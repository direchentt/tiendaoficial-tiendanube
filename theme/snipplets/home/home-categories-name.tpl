{% for category in categories %}
    {% if category.handle == category_handle %}
        {% set category_name = category.name %}
        <div class="d-inline-block align-top text-transform">{{ category_name }}</div>
    {% endif %}
    {% include 'snipplets/home/home-categories-name.tpl' with { 'categories' : category.subcategories } %}
{% endfor %}