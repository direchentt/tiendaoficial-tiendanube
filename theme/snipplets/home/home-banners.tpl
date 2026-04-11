{% set has_banner = has_banner | default(false) %}
{% set has_mobile_banners = settings.toggle_banner_mobile and settings.banner_mobile and settings.banner_mobile is not empty %}

{% set has_banner_promotional = has_banner_promotional | default(false) %}
{% set has_mobile_banners_promotional = settings.toggle_banner_promotional_mobile and settings.banner_promotional_mobile and settings.banner_promotional_mobile is not empty %}

{% set has_banner_news = has_banner_news | default(false) %}
{% set has_mobile_banners_news = settings.toggle_banner_news_mobile and settings.banner_news_mobile and settings.banner_news_mobile is not empty %}

{% set has_module = has_module | default(false) %}

{% if has_banner %}
    {% set data_store_name = 'home-banner-categories' %}
    {% set section_without_margins = settings.banner_without_margins ? 'section-home-color p-0' %}
{% elseif has_banner_promotional %}
    {% set data_store_name = 'home-banner-promotional' %}
    {% set section_without_margins = settings.banner_promotional_without_margins ? 'section-home-color p-0' %}
{% elseif has_banner_news %}
    {% set data_store_name = 'home-banner-news' %}
    {% set section_without_margins = settings.banner_news_without_margins ? 'section-home-color p-0' %}
{% else %}
    {% set data_store_name = 'home-image-text-module' %}
{% endif %}

{% if has_banner or has_banner_promotional or has_banner_news or has_module %}
    <section class="section-home section-banners-home position-relative overflow-none {{ section_without_margins }}" data-store="{{ data_store_name }}">
        {% if has_banner %}
            {% include 'snipplets/home/home-banners-grid.tpl' with {'banner': true} %}
            {% if has_mobile_banners %}
                {% include 'snipplets/home/home-banners-grid.tpl' with {'banner': true, mobile: true} %}
            {% endif %}
        {% endif %}
        {% if has_banner_promotional %}
            {% include 'snipplets/home/home-banners-grid.tpl' with {'banner_promotional': true} %}
            {% if has_mobile_banners_promotional %}
                {% include 'snipplets/home/home-banners-grid.tpl' with {'banner_promotional': true, mobile: true} %}
            {% endif %}
        {% endif %}
        {% if has_banner_news %}
            {% include 'snipplets/home/home-banners-grid.tpl' with {'banner_news': true} %}
            {% if has_mobile_banners_news %}
                {% include 'snipplets/home/home-banners-grid.tpl' with {'banner_news': true, mobile: true} %}
            {% endif %}
        {% endif %}
        {% if has_module %}
            {% include 'snipplets/home/home-banners-grid.tpl' with {'module': true} %}
        {% endif %}
    </section>
{% endif %}
