{% set description_content = product.description is not empty or settings.show_product_fb_comment_box %}
<div class="pdp-description-stack {% if not description_content %}mt-2 mt-md-0{% endif %} {% if settings.full_width_description %}col-md-auto product-image-column pt-md-3{% endif %} pb-md-3" data-store="product-description-{{ product.id }}">

    {% if product.description is not empty %}
        <details class="pdp-panel" open>
            <summary class="pdp-panel__summary">{{ "Descripción" | translate }}</summary>
            <div class="pdp-panel__body user-content">
                {{ product.description }}
            </div>
        </details>
    {% endif %}

    <details class="pdp-panel">
        <summary class="pdp-panel__summary">{{ "Compartir" | translate }}</summary>
        <div class="pdp-panel__body pdp-panel__body--share">
            {% include 'snipplets/social/social-share.tpl' %}
        </div>
    </details>

    {% if settings.show_product_fb_comment_box %}
        <details class="pdp-panel">
            <summary class="pdp-panel__summary">{{ "Comentarios en el producto" | translate }}</summary>
            <div class="pdp-panel__body">
                <div class="fb-comments section-fb-comments mb-0" data-href="{{ product.social_url }}" data-num-posts="5" data-width="100%"></div>
            </div>
        </details>
    {% endif %}

    <div id="reviewsapp" class="pdp-reviews-slot"></div>
</div>
