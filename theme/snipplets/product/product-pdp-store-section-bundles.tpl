{# Carruseles desde secciones de tienda (sections.txt: comp_pdp / alt_pdp). #}
{% if not settings.brand_pdp_store_sections_enable|default(false) %}
{% elseif sections is not defined %}
{% else %}

{% set section_class = 'section-home section-products-related position-relative ' %}
{% set container_class = 'container-fluid position-relative' %}
{% set title_container_class = 'row align-items-end mb-2' %}
{% set title_class = 'h4-huge h2-huge-md mb-2 col' %}
{% set slider_container_class = 'swiper-container' %}
{% set swiper_wrapper_class = 'swiper-wrapper swiper-products-slider flex-nowrap' %}
{% set slider_control_class = 'icon-inline icon-lg svg-icon-text' %}
{% set slider_controls_container_class = 'col-auto swiper-buttons position-relative' %}
{% set slider_control_prev_class = 'swiper-button-prev ' ~ slider_controls_container_class %}
{% set slider_control_next_class = 'swiper-button-next ' ~ slider_controls_container_class %}
{% set control_next_svg_id = 'arrow-long' %}
{% set control_prev_svg_id = 'arrow-long' %}

{% set ch_c = settings.brand_pdp_store_section_complementary_category_handle|default('')|trim|lower %}
{% set cat_ok_c = ch_c == '' %}
{% if not cat_ok_c %}
    {% if category is defined and category.handle is defined and category.handle|lower == ch_c %}
        {% set cat_ok_c = true %}
    {% elseif product.main_category is defined and product.main_category.handle is defined and product.main_category.handle|lower == ch_c %}
        {% set cat_ok_c = true %}
    {% elseif product.category is defined and product.category.handle is defined and product.category.handle|lower == ch_c %}
        {% set cat_ok_c = true %}
    {% endif %}
{% endif %}
{% if not cat_ok_c and ch_c != '' %}
    {% for sc in attribute(product, 'subcategories')|default([]) %}
        {% if sc.handle is defined and sc.handle|lower == ch_c %}
            {% set cat_ok_c = true %}
        {% endif %}
    {% endfor %}
{% endif %}

{% set ch_a = settings.brand_pdp_store_section_alternatives_category_handle|default('')|trim|lower %}
{% set cat_ok_a = ch_a == '' %}
{% if not cat_ok_a %}
    {% if category is defined and category.handle is defined and category.handle|lower == ch_a %}
        {% set cat_ok_a = true %}
    {% elseif product.main_category is defined and product.main_category.handle is defined and product.main_category.handle|lower == ch_a %}
        {% set cat_ok_a = true %}
    {% elseif product.category is defined and product.category.handle is defined and product.category.handle|lower == ch_a %}
        {% set cat_ok_a = true %}
    {% endif %}
{% endif %}
{% if not cat_ok_a and ch_a != '' %}
    {% for sc in attribute(product, 'subcategories')|default([]) %}
        {% if sc.handle is defined and sc.handle|lower == ch_a %}
            {% set cat_ok_a = true %}
        {% endif %}
    {% endfor %}
{% endif %}

{% set sec_comp = attribute(sections, 'comp_pdp') %}
{% set raw_comp = sec_comp and sec_comp.products ? sec_comp.products : [] %}
{% set list_comp = [] %}
{% for p in raw_comp %}
    {% if p.id != product.id and (p.stock is null or p.stock > 0) %}
        {% set list_comp = list_comp|merge([p]) %}
    {% endif %}
{% endfor %}
{% set max_comp = settings.brand_pdp_store_section_complementary_max|default(8) %}
{% set list_comp = list_comp | shuffle | take(max_comp) %}

{% set sec_alt = attribute(sections, 'alt_pdp') %}
{% set raw_alt = sec_alt and sec_alt.products ? sec_alt.products : [] %}
{% set list_alt = [] %}
{% for p in raw_alt %}
    {% if p.id != product.id and (p.stock is null or p.stock > 0) %}
        {% set list_alt = list_alt|merge([p]) %}
    {% endif %}
{% endfor %}
{% set max_alt = settings.brand_pdp_store_section_alternatives_max|default(8) %}
{% set list_alt = list_alt | shuffle | take(max_alt) %}

{% set show_comp = (settings.brand_pdp_store_section_complementary_show|default(true)) and cat_ok_c and (list_comp|length > 0) %}
{% set show_alt = (settings.brand_pdp_store_section_alternatives_show|default(true)) and cat_ok_a and (list_alt|length > 0) %}

{% if show_comp or show_alt %}
<div class="pdp-store-section-bundles theme-brand-phase1 js-product-table" data-store="product-section-bundles" role="region" aria-label="{{ 'Sugerencias de producto' | translate }}">
{% endif %}

{% if show_comp %}
    {{ component(
        'products-section',{
            title: settings.brand_pdp_store_section_complementary_title,
            id: 'pdp-sec-complementary',
            data_component: 'pdp-sec-complementary',
            products_amount: list_comp | length,
            products_array: list_comp,
            product_template_path: 'snipplets/grid/item.tpl',
            product_template_params: {'slide_item': true},
            slider_controls_position: 'with-section-title',
            slider_controls_container: true,
            section_classes: {
                section: 'js-pdp-sec-complementary-products mb-4 ' ~ section_class,
                container: container_class,
                title_container: title_container_class,
                title: title_class,
                slider_container: 'js-swiper-pdp-sec-complementary ' ~ slider_container_class,
                slider_wrapper: swiper_wrapper_class,
                slider_control: slider_control_class,
                slider_control_prev_container: 'js-swiper-pdp-sec-complementary-prev ' ~ slider_control_prev_class,
                slider_control_prev: 'icon-flip-horizontal',
                slider_control_next_container: 'js-swiper-pdp-sec-complementary-next ' ~ slider_control_next_class,
            },
            control_next_svg_id: control_next_svg_id,
            control_prev_svg_id: control_prev_svg_id,
        })
    }}
{% endif %}

{% if show_alt %}
    {{ component(
        'products-section',{
            title: settings.brand_pdp_store_section_alternatives_title,
            id: 'pdp-sec-alternatives',
            data_component: 'pdp-sec-alternatives',
            products_amount: list_alt | length,
            products_array: list_alt,
            product_template_path: 'snipplets/grid/item.tpl',
            product_template_params: {'slide_item': true},
            slider_controls_position: 'with-section-title',
            slider_controls_container: true,
            section_classes: {
                section: 'js-pdp-sec-alternatives-products mb-4 ' ~ section_class,
                container: container_class,
                title_container: title_container_class,
                title: title_class,
                slider_container: 'js-swiper-pdp-sec-alternative ' ~ slider_container_class,
                slider_wrapper: swiper_wrapper_class,
                slider_control: slider_control_class,
                slider_control_prev_container: 'js-swiper-pdp-sec-alternative-prev ' ~ slider_control_prev_class,
                slider_control_prev: 'icon-flip-horizontal',
                slider_control_next_container: 'js-swiper-pdp-sec-alternative-next ' ~ slider_control_next_class,
            },
            control_next_svg_id: control_next_svg_id,
            control_prev_svg_id: control_prev_svg_id,
        })
    }}
{% endif %}

{% if show_comp or show_alt %}
</div>
{% endif %}

{% endif %}
