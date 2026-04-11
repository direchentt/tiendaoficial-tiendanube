{% set logo_size_thumbnail = settings.logo_size == 'big' ? 'huge' : 'large' %}
{% set logo_size_class = settings.logo_size == 'small' ? 'logo-img-small' : settings.logo_size == 'big' ? 'logo-img-big' %}

{{ component('logos/logo', {
    logo_size: logo_size_thumbnail,
    logo_img_classes: 'transition-soft ' ~ logo_size_class, 
    logo_text_classes: 'h3 m-0'}) 
}}

{% if settings.head_transparent and settings.head_transparent_contrast_options and "logo-transparent.jpg" | has_custom_image %}
    {{ component('logos/logo-transparent-header', {
        logo_size: logo_size_thumbnail,
        logo_img_name: 'logo-transparent.jpg', 
        logo_img_classes: 'transition-soft '  ~ logo_size_class}) 
    }}
{% endif %}