{% include 'snipplets/brand/brand-promo-split.tpl' %}
{% include 'snipplets/brand/brand-split-video-hero.tpl' %}
<article id="single-product" class="js-has-new-shipping js-product-detail js-product-container js-shipping-calculator-container pb-4 pt-3 pt-md-4 pb-md-3 pdp-app pdp-app--enhanced pdp-app--visual pdp-app--represent" data-variants="{{ product.variants_object | json_encode }}" data-store="product-detail">
    <div class="container-fluid">
        <div class="row align-items-start pdp-app-layout">
            <div class="col-md-auto product-image-column pb-4 pdp-app-gallery">
                <div class="pdp-gallery-shell" role="region" aria-label="{{ 'Imágenes del producto' | translate }}">
                    {% include 'snipplets/product/product-image.tpl' %}
                </div>
            </div>
            <div class="col-md-auto product-info-column pdp-app-buybox" data-store="product-info-{{ product.id }}">
                {% include 'snipplets/product/product-form.tpl' %}
            </div>

            {% if settings.brand_pdp_related_position|default('below_page') == 'after_buybox' %}
                <div class="col-12 pdp-related-region--after-buybox mt-md-4">
                    {% include 'snipplets/product/product-related.tpl' %}
                    {% include 'snipplets/product/product-pdp-store-section-bundles.tpl' %}
                </div>
            {% endif %}

        </div>
    </div>
</article>

{% include 'snipplets/product/product-pdp-thumbs-bridge.tpl' %}

{% set product_end_video_url = settings.brand_split_video_1_url|default('')|trim %}
{% if product_end_video_url is empty %}
    {% set product_end_video_url = attribute(settings, 'brand_split_video_1_url_es')|default('')|trim %}
{% endif %}
{% if product_end_video_url is empty %}
    {% set product_end_video_url = attribute(settings, 'brand_split_video_1_url_pt')|default('')|trim %}
{% endif %}
{% if product_end_video_url is empty %}
    {% set product_end_video_url = attribute(settings, 'brand_split_video_1_url_en')|default('')|trim %}
{% endif %}
{% if product_end_video_url is empty %}
    {% set product_end_video_url = attribute(settings, 'brand_split_video_1_url_es_mx')|default('')|trim %}
{% endif %}

{% if product_end_video_url %}
    <section class="theme-brand-phase1 brand-split-video-hero" data-store="product-end-video" aria-label="{{ 'Video' | translate }}">
        {% include 'snipplets/brand/brand-video-block.tpl' with {
            block_raw_url: product_end_video_url,
            block_kicker: settings.brand_split_video_1_kicker,
            block_title: settings.brand_split_video_1_title,
            block_btn1: settings.brand_split_video_1_btn1,
            block_btn1_url: settings.brand_split_video_1_btn1_url,
            block_btn2: settings.brand_split_video_1_btn2,
            block_btn2_url: settings.brand_split_video_1_btn2_url,
            block_autoplay: settings.brand_split_video_autoplay,
            block_muted: settings.brand_split_video_muted,
            block_video_class: 'js-brand-split-video-file'
        } %}
    </section>
{% endif %}

{# Carril categorias AJAX: debajo del video de ficha, antes de relacionados y del footer. #}
{% include 'snipplets/brand/brand-category-rail.tpl' with { rail_context: 'product' } %}

{% include 'snipplets/home/home-brand-routine-showcase.tpl' %}
{% include 'snipplets/home/home-brand-shoppable-stories.tpl' %}

{% if settings.brand_pdp_related_position|default('below_page') != 'after_buybox' %}
    {% include 'snipplets/product/product-related.tpl' %}
    {% include 'snipplets/product/product-pdp-store-section-bundles.tpl' %}
{% endif %}
