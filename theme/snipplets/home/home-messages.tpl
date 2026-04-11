{% set has_welcome = has_welcome | default(false) and (settings.welcome_01_message or settings.welcome_02_message or settings.welcome_03_message) %}
{% set has_announcement = has_announcement | default(false) and (settings.announcement_01_message or settings.announcement_02_message or settings.announcement_03_message) %}

{% if has_welcome %}
    {% set data_store_name = 'home-welcome-message' %}
    {% set section_colors_classes = settings.welcome_colors ? 'section-home-color section-welcome-home-colors' %}
    {% set section_animated_class = settings.welcome_animate ? 'section-home-text-animated' %}
    {% set section_outline_class = settings.welcome_outline ? 'home-text-outline' %}
{% elseif has_announcement %}
    {% set data_store_name = 'home-announcement-message' %}
    {% set section_colors_classes = settings.announcement_colors ? 'section-home-color section-announcement-home-colors' %}
    {% set section_animated_class = settings.announcement_animate ? 'section-home-text-animated' %}
    {% set section_outline_class = settings.announcement_outline ? 'home-text-outline' %}
{% endif %}

{% if has_welcome or has_announcement %}
    <section class="section-home {{ section_colors_classes }} {{ section_animated_class }} {{ section_outline_class }}" data-store="{{ data_store_name }}" data-transition="fade-in">
        {% if has_welcome %}
            {% include 'snipplets/home/home-messages-grid.tpl' with {'welcome': true} %}
        {% endif %}
        {% if has_announcement %}
            {% include 'snipplets/home/home-messages-grid.tpl' with {'announcement': true} %}
        {% endif %}
    </section>
{% endif %}
