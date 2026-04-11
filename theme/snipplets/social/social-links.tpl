{% for sn in ['instagram', 'facebook', 'youtube', 'tiktok', 'twitter', 'pinterest'] %}
    {% set sn_url = attribute(store,sn) %}
    {% if sn_url %}
        <a class="btn-link text-transform text-capitalize mr-3{% if template == 'password' %} mx-md-3{% endif %}" href="{{ sn_url }}" target="_blank" rel="noopener noreferrer" aria-label="{{ sn }} {{ store.name }}">
            {{ sn }}
        </a>
    {% endif %}
{% endfor %}
