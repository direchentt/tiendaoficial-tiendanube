{% if settings.main_categories and settings.slider_categories and settings.slider_categories is not empty %}
    {% set categories_slider = settings.main_categories_format == 'slider' %}
    {% set categories_animated = settings.main_categories_format == 'animate' %}
    {% set categories_container_classes = categories_slider ? 'swiper-slide w-auto' : 'd-inline-block' %}
    {% set categories_lazy_class = categories_slider ? 'swiper-lazy' : 'lazyload' %}
    <section class="section-home section-categories-home{% if settings.main_categories_colors or has_categories_background_image or has_categories_mobile_background_image %} section-home-color{% endif %} position-relative overflow-none" data-store="home-categories-featured" data-transition="fade-in">
        <div class="container-fluid pr-0">
            {% if categories_slider %}
                <div class="swiper-buttons py-0">
                    <div class="js-swiper-categories-prev swiper-button-prev svg-icon-text d-none d-md-block">
                        <svg class="icon-inline icon-lg icon-flip-horizontal svg-icon-text"><use xlink:href="#arrow-long"/></svg>
                    </div>
                    <div class="js-swiper-categories-next swiper-button-next svg-icon-text d-none d-md-block">
                        <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#arrow-long"/></svg>
                    </div>
                </div>
                <div class="js-swiper-categories swiper-container w-auto mt-md-3">
                    <div class="swiper-wrapper">
            {% else %}
                <div class="js-home-message-animated home-text-animated">
                    <span class="js-home-message-text-container">
            {% endif %}
            {% if categories_animated %}
                {% set repeat_number = 16 %}
            {% else %}
                {% set repeat_number = 1 %}
            {% endif %}
            {% for i in 1..repeat_number %}
                {% for slide in settings.slider_categories %}
                    <div class="{{ categories_container_classes }} mr-4">
                        {% if slide.link %}
                            <a href="{{ slide.link | setting_url }}" class="js-home-category" aria-label="{{ 'Categoría' | translate }} {{ loop.index }}">
                        {% endif %}
                            <div class="home-category h3-huge h2-huge-md">
                                <div class="home-category-image">
                                    <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ slide.image | static_url | settings_image_url('medium') }}" class="{{ categories_lazy_class }}" alt="{{ 'Categoría' | translate }} {{ loop.index }}">
                                    <div class="placeholder-fade"></div>
                                </div>
                        {% if slide.link %}
                                    {% set category_handle = slide.link | trim('/') | split('/') | last %}
                                    {% include 'snipplets/home/home-categories-name.tpl' %}
                                </div>
                            </a>
                        {% else %}
                            </div>
                        {% endif %}
                    </div>
                {% endfor %}
            {% endfor %}
                </div>
            </div>
        </div>
    </section>
{% endif %}
