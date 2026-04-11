<ul class="list-unstyled{% if header %} font-small{% endif %}">
    {% for language in languages %}
        <li class="text-transform {% if not loop.last %}mb-3{% endif %} {% if not header %}btn-link{% endif %}{% if language.active %} font-weight-bold{% endif %}">
            <a href="{{ language.url }}">
                {{ language.country_name }}
            </a>
        </li>
    {% endfor %}
</ul>
