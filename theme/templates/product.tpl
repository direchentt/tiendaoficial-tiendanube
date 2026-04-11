<article id="single-product" class="js-has-new-shipping js-product-detail js-product-container js-shipping-calculator-container pb-4 pt-md-4 pb-md-3 pdp-app" data-variants="{{ product.variants_object | json_encode }}" data-store="product-detail">
    <div class="container-fluid">
        <div class="row align-items-start pdp-app-layout">
            <div class="col-md-auto product-image-column pb-4 pdp-app-gallery">
                <div class="pdp-gallery-shell">
                    {% include 'snipplets/product/product-image.tpl' %}
                </div>
            </div>
            <div class="col-md-auto product-info-column pdp-app-buybox" data-store="product-info-{{ product.id }}">
                {% include 'snipplets/product/product-form.tpl' %}
                {% if not settings.full_width_description %}
                    {% include 'snipplets/product/product-description.tpl' %}
                {% endif %}
            </div>

            {% if settings.full_width_description %}
                <div class="pdp-app-description-full w-100">
                    {% include 'snipplets/product/product-description.tpl' %}
                </div>
            {% endif %}
        </div>
    </div>
</article>

{# Related products #}
{% include 'snipplets/product/product-related.tpl' %}
