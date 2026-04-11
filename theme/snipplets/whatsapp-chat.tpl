{% if store.whatsapp %}
    <a href="{{ store.whatsapp }}" target="_blank" rel="noopener noreferrer" class="{% if header %}btn btn-utility{% else %}js-btn-fixed-bottom btn-whatsapp{% endif %}" aria-label="{{ 'Comunicate por WhatsApp' | translate }}">
        <svg class="icon-inline"><use xlink:href="#whatsapp"/></svg>
    </a>
{% endif %}
