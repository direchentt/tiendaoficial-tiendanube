{% set banner = banner | default(false) %}
{% set banner_promotional = banner_promotional | default(false) %}
{% set banner_news = banner_news | default(false) %}
{% set module = module | default(false) %}

{% if banner %}
    {% set has_banners = settings.banner and settings.banner is not empty %}
    {% set has_mobile_banners = settings.toggle_banner_mobile and settings.banner_mobile and settings.banner_mobile is not empty %}
    {% set section_banner = mobile ? settings.banner_mobile : settings.banner %}
    {% set section_title = settings.banner_title %}
    {% set section_slider = settings.banner_format_mobile == 'slider' or settings.banner_format_desktop == 'slider' %}
    {% set section_slider_both = settings.banner_format_mobile == 'slider' and settings.banner_format_desktop == 'slider' %}
    {% set section_slider_mobile_only = settings.banner_format_mobile == 'slider' and settings.banner_format_desktop == 'grid' %}
    {% set section_slider_desktop_only = settings.banner_format_desktop == 'slider' and settings.banner_format_mobile == 'grid' %}
    {% set section_id = mobile ? 'banners-mobile' : 'banners' %}
    {% set section_first = settings.home_order_position_1 == 'categories' %}
    {% set section_columns_desktop_4 = settings.banner_columns_desktop == 4 %}
    {% set section_columns_desktop_3 = settings.banner_columns_desktop == 3 %}
    {% set section_columns_desktop_2 = settings.banner_columns_desktop == 2 %}
    {% set section_columns_desktop_1 = settings.banner_columns_desktop == 1 %}
    {% set section_same_size = settings.banner_same_size %}
    {% set section_align_text = settings.banner_align %}
    {% set section_title_size_mobile = settings.banner_title_size_mobile == 'small' ? 'h4-huge' : settings.banner_title_size_mobile == 'medium' ? 'h2-huge' : 'h1-huge'  %}
    {% set section_title_size_desktop = settings.banner_title_size_desktop == 'small' ? 'h3-huge-md' : settings.banner_title_size_desktop == 'medium' ? 'h1-huge-md' : 'h2-extra-huge-md' %}
    {% set section_without_margins = settings.banner_without_margins %}
    {% set section_text_outside = settings.banner_text_outside %}
{% endif %}
{% if banner_promotional %}
    {% set has_banners = settings.banner_promotional and settings.banner_promotional is not empty %}
    {% set has_mobile_banners = settings.toggle_banner_promotional_mobile and settings.banner_promotional_mobile and settings.banner_promotional_mobile is not empty %}
    {% set section_banner = mobile ? settings.banner_promotional_mobile : settings.banner_promotional %}
    {% set section_title = settings.banner_promotional_title %}
    {% set section_slider = settings.banner_promotional_format_mobile == 'slider' or settings.banner_promotional_format_desktop == 'slider' %}
    {% set section_slider_both = settings.banner_promotional_format_mobile == 'slider' and settings.banner_promotional_format_desktop == 'slider' %}
    {% set section_slider_mobile_only = settings.banner_promotional_format_mobile == 'slider' and settings.banner_promotional_format_desktop == 'grid' %}
    {% set section_slider_desktop_only = settings.banner_promotional_format_desktop == 'slider' and settings.banner_promotional_format_mobile == 'grid' %}
    {% set section_id = mobile ? 'banners-promotional-mobile' : 'banners-promotional' %}
    {% set section_first = settings.home_order_position_1 == 'promotional' %}
    {% set section_columns_desktop_4 = settings.banner_promotional_columns_desktop == 4 %}
    {% set section_columns_desktop_3 = settings.banner_promotional_columns_desktop == 3 %}
    {% set section_columns_desktop_2 = settings.banner_promotional_columns_desktop == 2 %}
    {% set section_columns_desktop_1 = settings.banner_promotional_columns_desktop == 1 %}
    {% set section_same_size = settings.banner_promotional_same_size %}
    {% set section_align_text = settings.banner_promotional_align %}
    {% set section_title_size_mobile = settings.banner_promotional_title_size_mobile == 'small' ? 'h4-huge' : settings.banner_promotional_title_size_mobile == 'medium' ? 'h2-huge' : 'h1-huge' %}
    {% set section_title_size_desktop = settings.banner_promotional_title_size_desktop == 'small' ? 'h3-huge-md' : settings.banner_promotional_title_size_desktop == 'medium' ? 'h1-huge-md' : 'h2-extra-huge-md' %}
    {% set section_without_margins = settings.banner_promotional_without_margins %}
    {% set section_text_outside = settings.banner_promotional_text_outside %}
{% endif %}
{% if banner_news %}
    {% set has_banners = settings.banner_news and settings.banner_news is not empty %}
    {% set has_mobile_banners = settings.toggle_banner_news_mobile and settings.banner_news_mobile and settings.banner_news_mobile is not empty %}
    {% set section_banner = mobile ? settings.banner_news_mobile : settings.banner_news %}
    {% set section_title = settings.banner_news_title %}
    {% set section_slider = settings.banner_news_format_mobile == 'slider' or settings.banner_news_format_desktop == 'slider' %}
    {% set section_slider_both = settings.banner_news_format_mobile == 'slider' and settings.banner_news_format_desktop == 'slider' %}
    {% set section_slider_mobile_only = settings.banner_news_format_mobile == 'slider' and settings.banner_news_format_desktop == 'grid' %}
    {% set section_slider_desktop_only = settings.banner_news_format_desktop == 'slider' and settings.banner_news_format_mobile == 'grid' %}
    {% set section_id = mobile ? 'banners-news-mobile' : 'banners-news' %}
    {% set section_first = settings.home_order_position_1 == 'news_banners' %}
    {% set section_columns_desktop_4 = settings.banner_news_columns_desktop == 4 %}
    {% set section_columns_desktop_3 = settings.banner_news_columns_desktop == 3 %}
    {% set section_columns_desktop_2 = settings.banner_news_columns_desktop == 2 %}
    {% set section_columns_desktop_1 = settings.banner_news_columns_desktop == 1 %}
    {% set section_same_size = settings.banner_news_same_size %}
    {% set section_align_text = settings.banner_news_align %}
    {% set section_title_size_mobile = settings.banner_news_title_size_mobile == 'small' ? 'h4-huge' : settings.banner_news_title_size_mobile == 'medium' ? 'h2-huge' : 'h1-huge' %}
    {% set section_title_size_desktop = settings.banner_news_title_size_desktop == 'small' ? 'h3-huge-md' : settings.banner_news_title_size_desktop == 'medium' ? 'h1-huge-md' : 'h2-extra-huge-md'  %}
    {% set section_without_margins = settings.banner_news_without_margins %}
    {% set section_text_outside = settings.banner_news_text_outside %}
{% endif %}
{% if module %}
    {% set section_banner = settings.module %}
    {% set section_slider = settings.module_slider %}
    {% set section_id = 'modules' %}
    {% set section_same_size = settings.module_same_size %}
    {% set section_text_outside = true %}
    {% set section_title_size_mobile = settings.module_title_size_mobile == 'small' ? 'h4-huge' : 'h2-huge'  %}
    {% set section_title_size_desktop = settings.module_title_size_desktop == 'small' ? 'h3-huge-md' : 'h1-huge-md' %}
    {% set section_first = settings.home_order_position_1 == 'modules' %}
{% endif %}

{% set visibility_classes = 
    has_banners and has_mobile_banners ? (mobile ? 'd-md-none' : 'd-none d-md-block') 
    : not has_banners and has_mobile_banners and not mobile ? 'd-none' 
%}

{% set container_classes = module ? 'container' : 'container-fluid' %}
{% set banner_classes = module ? 'mb-4 mb-md-5 pb-md-3' : section_without_margins ? 'm-0' %}

<div class="{{ container_classes }} position-relative {% if module %}mt-4 pt-3{% else %}px-md-3 {{ visibility_classes }}{% endif %}">
    {% if section_title and not module %}
        <h2 class="section-title text-center h3 mb-4">{{ section_title }}</h2>
    {% endif %}
{% if section_without_margins %}
</div>
<div class="{{ container_classes }} {% if not module %}p-0 overflow-none {{ visibility_classes }}{% endif %}">
{% endif %}

    {% if section_slider %}
        {% set section_slider_classes = section_slider_both ? 'swiper-products-slider flex-nowrap' : section_slider_mobile_only ? 'swiper-mobile-only flex-nowrap flex-md-wrap' : section_slider_desktop_only ? 'swiper-desktop-only flex-wrap flex-md-nowrap ml-md-0' : module and section_slider ? 'swiper-products-slider' %}
        <div class="js-swiper-{{ section_id }} swiper-container {% if module %}d-flex flex-column d-md-block{% endif %}">
            <div class="swiper-wrapper {{ section_slider_classes }} {% if not module %}row {% if section_without_margins %}no-gutters{% else %}row-grid{% endif %}{% endif %}">
    {% elseif not module %}
        <div class="row {% if section_without_margins %}no-gutters{% else %}px-2{% endif %}">
    {% endif %}

    {% for slide in section_banner %}

        {% set has_banner_text = slide.title or slide.description or slide.button %}

        {% if not module or (module and section_slider) %}
            <div class="{% if section_slider %}swiper-slide {% endif %}col-grid {% if section_columns_desktop_4 %}col-md-3{% elseif section_columns_desktop_3 %}col-md-4{% elseif section_columns_desktop_2 %}col-md-6{% elseif section_columns_desktop_1 %}col-md-12{% endif %}">
        {% endif %}
                <div class="textbanner {{ banner_classes }}">
                    {% if slide.link %}
                        <a href="{{ slide.link | setting_url }}" class="textbanner-link" aria-label="{{ 'Carrusel' | translate }} {{ loop.index }}">
                    {% endif %}
                    {% if module %}
                        <div class="row no-gutters align-items-center">
                    {% endif %}
                            <div class="textbanner-image{% if not section_same_size %} p-0{% endif %} {% if module %} col-md-6{% if section_same_size %} textbanner-image-md{% endif %}{% else %}{% if has_banner_text and not section_text_outside %} overlay{% endif %}{% endif %} overflow-none">
                                
                                {% set apply_lazy_load = 
                                    not section_first 
                                    or not (
                                        loop.first and (
                                            (has_banners and not has_mobile_banners) or 
                                            (has_mobile_banners and mobile) or module
                                        )
                                    ) 
                                %}

                                {% if apply_lazy_load %}
                                    {% set slide_src = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==' %}
                                {% else %}
                                    {% set slide_src = slide.image | static_url | settings_image_url('large') %}
                                {% endif %}
                                
                                <img 
                                    {% if not apply_lazy_load %}fetchpriority="high"{% endif %}
                                    {% if slide.width and slide.height %} width="{{ slide.width }}" height="{{ slide.height }}" {% endif %} 
                                    {% if apply_lazy_load %}data-{% endif %}src="{{ slide_src }}"
                                    {% if apply_lazy_load %}
                                    data-sizes="auto" 
                                    data-expand="-10"
                                    {% endif %} 
                                    {% if apply_lazy_load %}data-{% endif %}srcset="{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w" 
                                    class="textbanner-image-effect {% if section_same_size %}textbanner-image-background{% else %}img-fluid d-block w-100{% endif %} {% if apply_lazy_load %}lazyautosizes lazyload fade-in{% endif %}" 
                                    {% if slide.title %}alt="{{ banner_title }}"{% else %}alt="{{ 'Banner de' | translate }} {{ store.name }}"{% endif %} 
                                />
                                {% if apply_lazy_load %}
                                    <div class="placeholder-fade placeholder-banner"></div>
                                {% endif %}
                            {% if section_text_outside %}
                                </div>
                            {% endif %}
                            {% if has_banner_text %}
                                <div class="textbanner-text text-{{ section_align_text }} {% if module %} col-md-6 px-3 px-md-5 py-md-5 text-center {% if not section_slider and loop.index is even %}order-md-first{% endif %}{% endif %} {% if not module %}{% if not section_text_outside %}over-image{% elseif section_text_outside and not section_without_margins %}px-1 py-3{% endif %} {% if not section_text_outside and slide.color == 'light' %}over-image-invert{% endif %}{% endif %}">
                                    {% if section_columns_desktop_1 and not module %}
                                        <div class="w-md-50 d-md-inline-block">
                                    {% endif %}
                                    {% if section_banner | length > 1 and not module %}
                                        <div class="mb-1 mb-md-2">{{ loop.index }} / {{ loop.length }}</div>
                                    {% endif %}
                                    {% if slide.title %}
                                        <h3 class="{{ section_title_size_mobile }} {{ section_title_size_desktop }} mb-2">{{ slide.title }}</h3>
                                    {% endif %}
                                    {% if slide.description %}
                                        <div class="textbanner-paragraph{% if slide.button and slide.link %} mb-2{% endif %}">{{ slide.description }}</div>
                                    {% endif %}
                                    {% if slide.button and slide.link %}
                                        <div class="btn btn-link d-inline-block mt-1 mt-md-2 mb-2">{{ slide.button }}</div>
                                    {% endif %}
                                    {% if section_columns_desktop_1 and not module %}
                                        </div>
                                    {% endif %}
                                </div>
                            {% endif %}
                    {% if not section_text_outside or module %}
                        </div>
                    {% endif %}
                    {% if slide.link %}
                        </a>
                    {% endif %}
                </div>
        {% if not module or (module and section_slider) %}
            </div>
        {% endif %}
    {% endfor %}
    {% if section_slider %}
            </div>
            {% if (section_banner and section_banner is not empty and (not module and section_slider) or (module and section_slider)) %}
                {% set section_button_classes = section_slider_mobile_only ? 'd-block d-md-none' : section_slider_desktop_only ? 'd-none d-md-block' %}
                <div class="swiper-buttons {{ section_button_classes }} {% if module %}d-flex justify-content-end position-relative position-absolute-md order-first p-0{% endif %}">
                    <div class="js-swiper-{{ section_id }}-prev swiper-button-prev {% if not module %}svg-icon-invert{% endif %}">
                        <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
                    </div>
                    <div class="js-swiper-{{ section_id }}-next swiper-button-next {% if not module %}svg-icon-invert{% endif %}">
                        <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
                    </div>
                </div>
            {% endif %}
        </div>
    {% elseif not module %}
        </div>
    {% endif %}
</div>
