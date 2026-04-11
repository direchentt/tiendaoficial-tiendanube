{% set description_content = product.description is not empty or settings.show_product_fb_comment_box %}
<div class="{% if not description_content %}mt-2 mt-md-0{% endif %} {% if settings.full_width_description %}col-md-auto product-image-column pt-md-3{% endif %} pb-md-3" data-store="product-description-{{ product.id }}">

    {# Product description #}

    {% if product.description is not empty %}
        <div class="font-small mb-3">{{ "Descripción" | translate }}</div>
        <div class="user-content mb-4">
            {{ product.description }}
        </div>
    {% endif %}

    {% if settings.show_product_fb_comment_box %}
        <div class="fb-comments section-fb-comments mb-3" data-href="{{ product.social_url }}" data-num-posts="5" data-width="100%"></div>
    {% endif %}
    <div id="reviewsapp"></div>
    
    {% include 'snipplets/social/social-share.tpl' %}

</div>
