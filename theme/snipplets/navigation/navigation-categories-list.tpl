{% for category in categories %}
    {# asking for subcategories without images #}
    <li class="js-desktop-nav-item js-item-subitems-desktop nav-item nav-item-desktop">
        <a class="nav-list-link" href="{{ category.url }}">
            {{ category.name }}
        </a>
        {% if category.subcategories(false) %}
            <ul class="list-subitems">
                {% snipplet "navigation/navigation-categories-list.tpl" with categories = category.subcategories %}
            </ul>
        {% endif %}
    </li>
{% endfor %}