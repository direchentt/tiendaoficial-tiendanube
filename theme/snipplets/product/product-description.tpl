{% set description_content = product.description is not empty or settings.show_product_fb_comment_box %}
{% set has_desc = product.description is not empty %}
{% set pid = product.id %}
{% set tab_share_first = not has_desc or settings.brand_pdp_description_closed %}

<div id="pdp-visual-tabs" class="pdp-description-stack pdp-description-stack--tabs {% if not description_content %}mt-2 mt-md-0{% endif %} {% if settings.full_width_description %}col-md-auto product-image-column pt-md-3{% endif %} pb-md-3" data-store="product-description-{{ product.id }}">

    <section class="pdp-section pdp-section--detail pdp-tabs" aria-label="{{ 'Información del producto' | translate }}">

        {% if has_desc %}
        <input type="radio" name="pdp-tab-{{ pid }}" id="pdp-tab-{{ pid }}-desc" class="pdp-tabs__state pdp-tabs__state--desc" autocomplete="off"{% if not tab_share_first %} checked="checked"{% endif %}>
        {% endif %}
        <input type="radio" name="pdp-tab-{{ pid }}" id="pdp-tab-{{ pid }}-share" class="pdp-tabs__state pdp-tabs__state--share" autocomplete="off"{% if tab_share_first %} checked="checked"{% endif %}>
        {% if settings.show_product_fb_comment_box %}
        <input type="radio" name="pdp-tab-{{ pid }}" id="pdp-tab-{{ pid }}-fb" class="pdp-tabs__state pdp-tabs__state--fb" autocomplete="off">
        {% endif %}

        <div class="pdp-tabs__panels">
            <div class="pdp-tabs__nav" role="tablist" aria-orientation="horizontal">
                {% if has_desc %}
                <label class="pdp-tabs__label pdp-tabs__label--desc" for="pdp-tab-{{ pid }}-desc" id="pdp-tablabel-{{ pid }}-desc" role="tab">{{ "Descripción" | translate }}</label>
                {% endif %}
                <label class="pdp-tabs__label pdp-tabs__label--share" for="pdp-tab-{{ pid }}-share" id="pdp-tablabel-{{ pid }}-share" role="tab">{{ "Compartir" | translate }}</label>
                {% if settings.show_product_fb_comment_box %}
                <label class="pdp-tabs__label pdp-tabs__label--fb" for="pdp-tab-{{ pid }}-fb" id="pdp-tablabel-{{ pid }}-fb" role="tab">{{ "Comentarios" | translate }}</label>
                {% endif %}
            </div>

            {% if has_desc %}
            <div class="pdp-tabs__panel pdp-tabs__panel--desc" role="tabpanel" aria-labelledby="pdp-tablabel-{{ pid }}-desc">
                <div class="pdp-tabs__panel-inner user-content">
                    {{ product.description }}
                </div>
            </div>
            {% endif %}
            <div class="pdp-tabs__panel pdp-tabs__panel--share" role="tabpanel" aria-labelledby="pdp-tablabel-{{ pid }}-share">
                <div class="pdp-tabs__panel-inner pdp-panel__body--share">
                    {% include 'snipplets/social/social-share.tpl' %}
                </div>
            </div>
            {% if settings.show_product_fb_comment_box %}
            <div class="pdp-tabs__panel pdp-tabs__panel--fb" role="tabpanel" aria-labelledby="pdp-tablabel-{{ pid }}-fb">
                <div class="pdp-tabs__panel-inner">
                    <div class="fb-comments section-fb-comments mb-0" data-href="{{ product.social_url }}" data-num-posts="5" data-width="100%"></div>
                </div>
            </div>
            {% endif %}
        </div>

        <div id="reviewsapp" class="pdp-reviews-slot"></div>
    </section>
</div>
