{% set has_advertising_bar = false %}
{% set num_messages = 0 %}
{% for adbar in ['ad_bar_01', 'ad_bar_02', 'ad_bar_03'] %}
    {% set advertising_text = attribute(settings,"#{adbar}_text") %}
    {% if advertising_text %}
        {% set num_messages = num_messages + 1 %}
    {% endif %}
{% endfor %}
{% set adbar_animated = settings.ad_bar_animate %}
{% set adbar_animated_classes = adbar_animated ? 'section-adbar-animated' %}
{% set adbar_colors_classes = settings.adbar_colors ? 'section-adbar-colors' %}
{% set adbar_messages_classes = num_messages ? 'adbar-with-messages' %}
{% set adbar_animated_container_classes = adbar_animated ? 'js-adbar-animated adbar-animated' : 'js-swiper-adbar swiper-container text-center container-fluid' %}
{% set adbar_animated_text_container_classes = adbar_animated ? 'js-adbar-text-container' : 'swiper-wrapper' %}
{% set adbar_animated_text_classes = adbar_animated ? 'mr-4' : 'swiper-slide slide-container' %}
{% set adbar_no_text_classes = not num_messages ? 'p-0' %}

{% if settings.ad_bar and num_messages %}
    <section class="js-adbar section-adbar {{ adbar_animated_classes }} {{ adbar_colors_classes }} {{ adbar_messages_classes }} {{ adbar_no_text_classes }}">
        {% if num_messages %}
            <div class="{{ adbar_animated_container_classes }}">
                <div class="{{ adbar_animated_text_container_classes }} adbar-text-container align-items-center">

                    {% if adbar_animated %}
                        {% if num_messages == 1 %}
                            {% set repeat_number = 16 %}
                        {% else %}
                            {% set repeat_number = num_messages == 2 ? '8' : '5' %}
                        {% endif %}
                    {% else %}
                        {% set repeat_number = 1 %}
                    {% endif %}
                    {% for i in 1..repeat_number %}
                        {% for adbar in ['ad_bar_01', 'ad_bar_02', 'ad_bar_03'] %}
                            {% set advertising_text = attribute(settings,"#{adbar}_text") %}
                            {% set advertising_url = attribute(settings,"#{adbar}_url") %}
                            {% if advertising_text %}
                                <span class="adbar-message {{ adbar_animated_text_classes }} {% if num_messages > 1 and not adbar_animated %}px-4{% endif %}">
                                    {% if advertising_url %}
                                        <a href="{{ advertising_url }}" {% if not adbar_animated %}class="d-block w-100"{% endif %}>
                                    {% endif %}
                                            {{ advertising_text }}
                                    {% if advertising_url %}
                                        </a>
                                    {% endif %}
                                </span>
                            {% endif %}
                        {% endfor %}
                    {% endfor %}
                </div>
                {% if num_messages > 1 and not adbar_animated %}
                    <div class="js-swiper-adbar-prev swiper-button-absolute swiper-button-prev svg-icon-text">
                        <svg class="icon-inline icon-xs icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
                    </div>
                    <div class="js-swiper-adbar-next swiper-button-absolute swiper-button-next svg-icon-text ml-2">
                        <svg class="icon-inline icon-xs"><use xlink:href="#chevron"/></svg>
                    </div>
                {% endif %}
            </div>
        {% endif %}
    </section>
{% endif %}
