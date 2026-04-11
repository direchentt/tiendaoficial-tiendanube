{# Site Overlay #}
<div class="js-overlay site-overlay" style="display: none;"></div>

{# Header #}

{# Header dynamic classes #}

{% set header_logo_classes = settings.logo_position_mobile == 'center' ? 'head-logo-center' : 'head-logo-left' %}
{% set header_logo_md_classes = settings.logo_position_desktop == 'center' ? 'head-logo-md-center' : 'head-logo-md-left' %}
{% set header_logo_left_nav_below_md_classes = settings.logo_position_desktop == 'left' and settings.search_big_desktop and not settings.hamburger_desktop ? 'head-logo-md-left-nav-below' %}
{% set has_nav_inline_md =  settings.logo_position_desktop == 'left' and not settings.search_big_desktop  and not settings.hamburger_desktop %}
{% set has_languages = languages | length > 1 and settings.languages_header %}
{% set has_logo_centered_nav_below_md = settings.logo_position_desktop == 'center' and not settings.hamburger_desktop %}
{% set header_nav_inline_md_classes = has_nav_inline_md ? 'head-nav-md-inline' %}
{% set header_colors_classes = settings.header_colors ? 'head-colors' %}
{% set header_hamburger_md_classes =  settings.hamburger_desktop ? 'head-md-hamburger' : 'head-md-visible-nav' %}
{% set header_search_big_classes =  settings.search_big_mobile ? 'head-search-big' %}
{% set header_search_big_md_classes =  settings.search_big_desktop ? 'head-md-search-big' %}

{# Logo mobile dynamic classes #}

{% set logo_classes = settings.logo_position_mobile == 'center' ? 'text-center' : 'text-left order-first' %}

{# Logo desktop dynamic classes + utilities desktop order #}

{% set logo_md_classes = settings.logo_position_desktop == 'center' ? 'col-md order-md-1 text-md-center' : 'col-md-auto order-md-first text-md-left' %}
{% set logo_md_padding_class = has_languages ? ' pl-md-5' %}
{% set logo_md_spacing_classes = has_logo_centered_nav_below_md ? 'ml-md-5' ~ logo_md_padding_class : settings.logo_position_desktop == 'left' ? 'pr-md-5' %}

{# Header visibility classes #}

{% set show_inline_desktop_hide_mobile_class = 'd-none d-md-inline-block' %}
{% set show_inline_mobile_hide_desktop_class = 'd-inline-block d-md-none' %}
{% set show_block_desktop_hide_mobile_class = 'd-none d-md-block' %}
{% set show_block_mobile_hide_desktop_class = 'd-block d-md-none' %}

{# Search classes #}

{% set search_icon_visibility_classes = '' %}
{% if settings.search_big_mobile and not settings.search_big_desktop %}
    {% set search_icon_visibility_classes = show_block_desktop_hide_mobile_class %}
{% elseif not settings.search_big_mobile and settings.search_big_desktop %}
    {% set search_icon_visibility_classes = show_block_mobile_hide_desktop_class %}
{% endif %}

{% set has_hamburger_md_logo_centered = settings.logo_position_desktop == 'center' and settings.hamburger_desktop %}
{% set search_col_md_classes = has_nav_inline_md ? 'col-md-auto' : has_hamburger_md_logo_centered ? 'col-md-3 mr-md-3' : has_logo_centered_nav_below_md ? 'col-md-3 mr-md-5' : 'col-md' %}

{# Utilities conditions #}

{% set menu_mobile_col = settings.logo_position_mobile == 'center' and not has_languages ? 'col-3' : 'col-auto' %}
{% set menu_col_classes = settings.logo_position_mobile == 'center' ? 'order-first ' ~ menu_mobile_col : 'col-auto' %}
{% set menu_col_md_classes = settings.logo_position_desktop == 'center' ? 'order-md-first' : 'order-md-last' %}
{% set menu_col_md_spacing_classes = settings.logo_position_desktop == 'center' and settings.search_big_desktop ? 'mr-md-2 pr-md-1' %}
{% set account_col_md_classes = settings.logo_position_desktop == 'center' ? 'order-md-1 col-md-3' : 'col-md-auto' %}
{% set languages_order_classes = settings.logo_position_desktop == 'center' ? 'order-first order-md-2 mr-1 mr-md-0' %}

{# Conditions for transparent head on page load #}

{# Slider and video presence #}

{% if template == 'home' %}
    {% set has_main_slider = settings.slider and settings.slider is not empty %}
    {% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}
    {% set has_slider = has_main_slider or has_mobile_slider %}
    {% set has_slider_above_the_fold = settings.home_order_position_1 == 'slider' and has_slider %}
    {% set has_video_above_the_fold = settings.home_order_position_1 == 'video' and settings.video_embed %}
    {% set is_video_or_slider_above_the_fold = has_slider_above_the_fold or has_video_above_the_fold %}
{% endif %}

{# Transparent head conditions #}

{% set head_transparent_type_on_section = template == 'home' and settings.head_transparent and settings.head_transparent_type == 'slider_and_video' and (has_slider or settings.video_embed) %}
{% set head_transparent_type_always = settings.head_transparent and settings.head_transparent_type == 'all' %}
{% set head_transparent = (head_transparent_type_on_section or head_transparent_type_always) %}
{% set head_transparent_with_media = head_transparent and is_video_or_slider_above_the_fold %}

{% set header_transparent_classes = head_transparent_type_always ? 'js-head-mutator head-transparent' : head_transparent_type_on_section ? 'js-head-mutator head-transparent-on-section' %}
{% set head_transparent_color_class = head_transparent and settings.head_transparent_contrast_options ? 'head-transparent-contrast' %}
{% set head_transparent_logo_class = head_transparent and settings.head_transparent_contrast_options and "logo-transparent.jpg" | has_custom_image ? 'head-transparent-logo' %}

{# Header position type #}

{% set head_position = head_transparent_with_media ? 'position-fixed' : 'position-sticky' %}
{% set header_md_position = settings.head_fix_desktop 
    ? (head_transparent_with_media ? 'position-fixed-md' : 'position-sticky-md')
    : (head_transparent_with_media ? 'position-absolute-md' : 'position-relative-md') %}

<header class="js-head-main head-main {{ header_transparent_classes }} {{ head_transparent_color_class }} {{ head_transparent_logo_class }} {{ header_colors_classes }} {{ head_position }} {{ header_md_position }} {{ header_logo_classes }} {{ header_logo_md_classes }} {{ header_logo_left_nav_below_md_classes }} {{ header_nav_inline_md_classes }} {{ header_hamburger_md_classes }} {{ header_search_big_classes }} {{ header_search_big_md_classes }} transition-soft" data-store="head">
    {# Adversiting bar #}
    {% if settings.ad_bar %}
        {% snipplet "header/header-advertising.tpl" %}
    {% endif %}
    <div class="head-logo-row position-relative transition-soft">
        <div class="container-fluid">
            <div class="{% if not settings.head_fix_desktop %}js-nav-logo-bar{% endif %} row no-gutters align-items-center">

                {# Menu icon #}

                <div class="{{ menu_col_classes }} {{ menu_col_md_classes }} {{ menu_col_md_spacing_classes }} col-md-auto col-utility {% if not settings.hamburger_desktop %}d-md-none{% endif %}">
                    {% include "snipplets/header/header-utilities.tpl" with {use_menu: true} %}
                </div>

                {# Logo #}

                <div class="js-logo-container col {{ logo_classes }} {{ logo_md_classes }} {{ logo_md_spacing_classes }}">
                    {% include "snipplets/header/header-logo.tpl" %}
                </div>

                {# Desktop navigation next to logo #}

                {% if has_nav_inline_md %}
                    {# Desktop nav next logo #}
                    <div class="js-desktop-nav-col desktop-nav-col transition-soft col {{ show_inline_desktop_hide_mobile_class }} align-items-center pr-md-5">
                        {% snipplet "navigation/navigation.tpl" %}
                    </div>
                {% endif %}

                {# Search: Icon or box #}

                <div class="js-utility-col js-search-utility col-auto desktop-utility-col {{ search_col_md_classes }} col-utility {% if settings.search_big_mobile %}{{ show_inline_desktop_hide_mobile_class }}{% elseif settings.logo_position_mobile == 'left' %}order-1{% endif %} order-md-0">
                    {% if settings.search_big_desktop %}
                        <span class="{{ show_block_desktop_hide_mobile_class }}">
                            {% include "snipplets/header/header-search.tpl" %}
                        </span>
                    {% endif %}
                    {% if not settings.search_big_desktop %}
                        <span class="{{ show_inline_desktop_hide_mobile_class }} {% if settings.logo_position_desktop == 'left' %}float-md-right{% endif %}">
                            {% include "snipplets/header/header-utilities.tpl" with {use_search: true} %}
                        </span>
                    {% endif %}
                </div>

                {# Languages #}

                {% if has_languages %}
                    <div class="js-utility-col col-utility desktop-utility-col {{ languages_order_classes }}">
                        {% include "snipplets/header/header-utilities.tpl" with {use_languages: true} %}
                    </div>
                {% endif %}

                {# Account icon #}
                
                <div class="js-utility-col col-utility desktop-utility-col text-right {{ show_inline_desktop_hide_mobile_class }} {{ account_col_md_classes }}">
                    {% include "snipplets/header/header-utilities.tpl" with {use_account: true, login_only: true} %}
                </div>

                {# Cart icon #}

                <div class="js-utility-col col-auto col-utility desktop-utility-col order-last">
                    {% include "snipplets/header/header-utilities.tpl" %}
                </div>

                {# Add to cart notification #}

                {% if settings.ajax_cart %}
                    {% if not settings.head_fix_desktop %}
                        <div class="{{ show_block_mobile_hide_desktop_class }}">
                    {% endif %}
                            {% include "snipplets/notification.tpl" with {add_to_cart: true} %}
                    {% if not settings.head_fix_desktop %}
                        </div>
                    {% endif %}
                {% endif %}

            </div>
        </div>
    </div>   

    {# Mobile search big #}

    {% if settings.search_big_mobile %}
        <div class="js-big-search-mobile pb-3 container-fluid {{ show_block_mobile_hide_desktop_class }}">
            {% include "snipplets/header/header-search.tpl" %}
        </div>
    {% endif %}

    {% if not settings.hamburger_desktop and (settings.logo_position_desktop == 'center' or (settings.logo_position_desktop == 'left' and settings.search_big_desktop)) %}

        {# Desktop navigation below logo #}
        <div class="head-nav d-none d-md-block">
            <div class="container-fluid {% if settings.logo_position_desktop == 'center' %}text-center{% endif %}">
                {% snipplet "navigation/navigation.tpl" %}
            </div>
        </div>
    {% endif %}
 
</header>

{# Follow order notification #}

{% include "snipplets/notification.tpl" with {order_notification: true} %}

{# Show cookie validation message #}

{% include "snipplets/notification.tpl" with {show_cookie_banner: true} %}

{# Add to cart notification for non fixed header #}

{% if settings.ajax_cart and not settings.head_fix_desktop %}
    <div class="{{ show_block_desktop_hide_mobile_class }}">
        {% include "snipplets/notification.tpl" with {add_to_cart: true, add_to_cart_fixed: true} %}
    </div>
{% endif %}

{# Cross selling promotion notification on add to cart #}

{% embed "snipplets/modal.tpl" with {
    modal_id: 'js-cross-selling-modal',
    modal_class: 'bottom modal-bottom-sheet h-auto overflow-none modal-body-scrollable-auto',
    modal_header: true,
    modal_header_class: 'p-2 w-100',
    modal_position: 'bottom',
    modal_transition: 'slide',
    modal_footer: true,
    modal_width: 'centered-md m-0 p-0 modal-full-width modal-md-width-400px'
} %}
    {% block modal_head %}
        {{ '¡Descuento exclusivo!' | translate }}
    {% endblock %}

    {% block modal_body %}
        {# Promotion info and actions #}

        <div class="js-cross-selling-modal-body" style="display: none"></div>
    {% endblock %}
{% endembed %}

{% include "snipplets/header/header-modals.tpl" %}
