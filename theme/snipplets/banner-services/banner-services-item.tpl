{% set banner_services_width_class = num_banners_services == 1 ? 'mw-md-100 px-3 px-md-0' : num_banners_services == 2 ? 'mw-md-50' : 'mw-md-33' %}
<div class="swiper-slide w-md-auto d-table-cell {{ banner_services_width_class }} p-0{% if loop.last %} mr-md-0{% endif %}">
    {% if banner_services_url %}
        <a href="{{ banner_services_url | setting_url }}">
    {% endif %}
    {% if banner_services_title %}
        <h3 class="h3-huge h2-huge-md d-inline-block align-middle mb-1 mr-3">{{ banner_services_title }}</h3>
    {% endif %}
    {% if banner_services_description %}
        <p class="mb-0 mt-2 service-text d-inline-block align-middle">{{ banner_services_description }}</p>
    {% endif %}
    {% if banner_services_url %}
        </a>
    {% endif %}
</div>
