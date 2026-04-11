{# /*============================================================================
  #Home featured grid
==============================================================================*/

#Properties

#Featured Slider

#}

{% set featured_products = featured_products | default(false) %}
{% set new_products = new_products | default(false) %}
{% set sale_products = sale_products | default(false) %}

{# Check if slider is used #}

{% set has_featured_products_and_slider = featured_products and (settings.featured_products_format_mobile == 'slider' or settings.featured_products_format_desktop == 'slider')  %}
{% set has_new_products_and_slider = new_products and (settings.new_products_format_mobile == 'slider' or settings.new_products_format_desktop == 'slider') %}
{% set has_sale_products_and_slider = sale_products and (settings.sale_products_format_mobile == 'slider' or settings.sale_products_format_desktop == 'slider') %}
{% set use_slider = has_featured_products_and_slider or has_new_products_and_slider or has_sale_products_and_slider %}

{% if featured_products %}
    {% set sections_products = sections.primary.products %}
    {% set section_name = 'primary' %}
    {% set section_columns_desktop = settings.featured_products_desktop %}
    {% set section_columns_mobile = settings.featured_products_mobile %}
    {% set section_slider = settings.featured_products_format_mobile == 'slider' or settings.featured_products_format_desktop == 'slider' %}
    {% set section_slider_both = settings.featured_products_format_mobile == 'slider' and settings.featured_products_format_desktop == 'slider' %}
    {% set section_slider_mobile_only = settings.featured_products_format_mobile == 'slider' and settings.featured_products_format_desktop == 'grid' %}
    {% set section_slider_desktop_only = settings.featured_products_format_desktop == 'slider' and settings.featured_products_format_mobile == 'grid' %}
    {% set section_slider_id = 'featured' %}
    {% set section_title = settings.featured_products_title %}
    {% set section_title_size_mobile = settings.featured_products_title_size_mobile == 'medium' ? 'h4-huge' : 'h3-huge'  %}
    {% set section_title_size_desktop = settings.featured_products_title_size_desktop == 'medium' ? 'h3-huge-md' : 'h2-huge-md' %}
{% endif %}
{% if new_products %}
    {% set sections_products = sections.new.products %}
    {% set section_name = 'new' %}
    {% set section_columns_desktop = settings.new_products_desktop %}
    {% set section_columns_mobile = settings.new_products_mobile %}
    {% set section_slider = settings.new_products_format_mobile == 'slider' or settings.new_products_format_desktop == 'slider' %}
    {% set section_slider_both = settings.new_products_format_mobile == 'slider' and settings.new_products_format_desktop == 'slider' %}
    {% set section_slider_mobile_only = settings.new_products_format_mobile == 'slider' and settings.new_products_format_desktop == 'grid' %}
    {% set section_slider_desktop_only = settings.new_products_format_desktop == 'slider' and settings.new_products_format_mobile == 'grid' %}
    {% set section_slider_id = 'new' %}
    {% set section_title = settings.new_products_title %}
    {% set section_title_size_mobile = settings.new_products_title_size_mobile == 'medium' ? 'h4-huge' : 'h3-huge'  %}
    {% set section_title_size_desktop = settings.new_products_title_size_desktop == 'medium' ? 'h3-huge-md' : 'h2-huge-md' %}
{% endif %}
{% if sale_products %}
    {% set sections_products = sections.sale.products %}
    {% set section_name = 'sale' %}
    {% set section_columns_desktop = settings.sale_products_desktop %}
    {% set section_columns_mobile = settings.sale_products_mobile %}
    {% set section_slider = settings.sale_products_format_mobile == 'slider' or settings.sale_products_format_desktop == 'slider' %}
    {% set section_slider_both = settings.sale_products_format_mobile == 'slider' and settings.sale_products_format_desktop == 'slider' %}
    {% set section_slider_mobile_only = settings.sale_products_format_mobile == 'slider' and settings.sale_products_format_desktop == 'grid' %}
    {% set section_slider_desktop_only = settings.sale_products_format_desktop == 'slider' and settings.sale_products_format_mobile == 'grid' %}
    {% set section_slider_id = 'sale' %}
    {% set section_title = settings.sale_products_title %}
    {% set section_title_size_mobile = settings.sale_products_title_size_mobile == 'medium' ? 'h4-huge' : 'h3-huge'  %}
    {% set section_title_size_desktop = settings.sale_products_title_size_desktop == 'medium' ? 'h3-huge-md' : 'h2-huge-md' %}
{% endif %}

<div class="container-fluid">
    <div class="row">
        <div class="col-md-3">
            {% if use_slider %}
                {% set section_visibility_classes = section_slider_mobile_only ? 'd-block d-md-none' : section_slider_desktop_only ? 'd-none d-md-block' %}
                <div class="js-swiper-{{ section_slider_id }}-pagination swiper-pagination-fraction {{ section_visibility_classes }}"></div>
            {% endif %}
            {% if section_title %}
                {% set section_title_classes = section_slider_mobile_only or section_slider_both ? 'mb-0' : section_slider_desktop_only ? 'mb-3 mb-md-0' : 'mb-3' %}
                <h2 class="section-title {{ section_title_classes }} {{ section_title_size_mobile }} {{ section_title_size_desktop }}">{{ section_title }}</h2>
            {% endif %}
            {% if use_slider %}
                <div class="swiper-buttons position-relative p-0 ml-neg-2 pl-1 {{ section_visibility_classes }}">
                    <div class="js-swiper-{{ section_slider_id }}-prev swiper-button-prev svg-icon-text">
                        <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
                    </div>
                    <div class="js-swiper-{{ section_slider_id }}-next swiper-button-next svg-icon-text">
                        <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
                    </div>
                </div>
            {% endif %}
        </div>
        <div class="col-md-9">
            {% if use_slider %}
                {% set section_slider_classes = section_slider_both ? 'swiper-products-slider flex-nowrap' : section_slider_mobile_only ? 'swiper-mobile-only flex-nowrap flex-md-wrap' : section_slider_desktop_only ? 'swiper-desktop-only flex-wrap flex-md-nowrap ml-md-0' %}
                <div class="js-swiper-{{ section_slider_id }} swiper-container">
                    <div class="swiper-wrapper {{ section_slider_classes }} row row-grid">
            {% else %}
                <div class="row row-grid">
            {% endif %}

            {% for product in sections_products %}
                {% if use_slider %}
                    {% include 'snipplets/grid/item.tpl' with {'slide_item': true, 'section_name': section_name, 'section_columns_desktop': section_columns_desktop, 'section_columns_mobile': section_columns_mobile } %}
                {% else %}
                    {% include 'snipplets/grid/item.tpl' %}
                {% endif %}
            {% endfor %}

            {% if use_slider %}
                    </div>
                </div>
            {% else %}
                </div>
            {% endif %}
        </div>
    </div>
</div>
