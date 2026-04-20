<div class="pdp-buybox-stack {% if home_main_product %}pt-md-4 mt-md-2 pt-3{% else %}pt-md-3{% endif %}">

    {% if home_main_product %}
        <h2 class="h3-huge h2-huge-md mb-3">{{ product.name }}</h2>
        {% if settings.product_sku and product.sku %}
            <div class="font-small opacity-60 mb-3 pdp-sku-line">
                {{ "SKU" | translate }}: <span class="js-product-sku font-weight-bold">{{ product.sku }}</span>
            </div>
        {% endif %}
    {% else %}
        {% if template == 'product' %}
            <div class="pdp-represent-head">
                <div class="pdp-represent-head-line">
                <section class="pdp-section pdp-section--intro" aria-label="{{ 'Información del producto' | translate }}">
                    <div class="page-header pdp-page-header pb-0">
                        <h1 class="js-product-name pdp-product-title pdp-represent-product-title mt-0 mb-0">{{ product.name }}</h1>
                    </div>
                    {% if settings.product_sku and product.sku %}
                        <div class="font-small opacity-60 mb-2 pdp-sku-line">
                            {{ "SKU" | translate }}: <span class="js-product-sku font-weight-bold">{{ product.sku }}</span>
                        </div>
                    {% endif %}
                </section>
        {% else %}
                <section class="pdp-section pdp-section--intro" aria-label="{{ 'Información del producto' | translate }}">
                    {% embed "snipplets/page-header.tpl" with {container: false, padding: false, breadcrumbs: true, breadcrumbs_custom_class: 'pdp-breadcrumbs mb-2 mb-md-3', page_header_class: 'pdp-page-header', page_header_title_class: 'js-product-name pdp-product-title mt-0 mb-2'} %}
                        {% block page_header_text %}{{ product.name }}{% endblock page_header_text %}
                    {% endembed %}
                    {% if settings.product_sku and product.sku %}
                        <div class="font-small opacity-60 mb-2 pdp-sku-line">
                            {{ "SKU" | translate }}: <span class="js-product-sku font-weight-bold">{{ product.sku }}</span>
                        </div>
                    {% endif %}
                </section>
        {% endif %}
    {% endif %}

    {# Subscription only detection #}
    {% set is_subscription_only_product = product.isSubscribable() and product.isSubscriptionOnly() %}

    {# Product price #}

    <section class="pdp-section pdp-section--price" aria-label="{{ 'Precio' | translate }}">
    <div class="price-container mb-3 pdp-price-card" data-store="product-price-{{ product.id }}">
        {% if not is_subscription_only_product %}
            {# Standard prices for normal products #}
            <div class="js-price-container">
                <span class="d-inline-block mr-1">
                    <div class="js-price-display font-largest" id="price_display" {% if not product.display_price %}style="display:none;"{% endif %} data-product-price="{{ product.price }}"{% if attribute(product.selected_or_first_available_variant, 'price_number') is defined and product.selected_or_first_available_variant.price_number is not null and product.selected_or_first_available_variant.price_number != '' %} content="{{ product.selected_or_first_available_variant.price_number }}"{% endif %}>{% if product.display_price %}{{ product.price | money_nocents }}{% endif %}</div>
                </span>
                <span class="d-inline-block font-big">
                <div id="compare_price_display" class="js-compare-price-display price-compare" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% else %} style="display:block;"{% endif %}>{% if product.compare_at_price and product.display_price %}{{ product.compare_at_price | money_nocents }}{% endif %}</div>
                </span>
                
                {% if not (template == 'product' and not home_main_product) %}
                {{ component('price-discount-disclaimer', {
                  container_classes: 'font-small opacity-60 mt-1 mb-2',
                }) }}
                {% endif %}

                {% if template == 'product' and not home_main_product %}
                {{ component('price-without-taxes', {
                        container_classes: "mt-1 mb-1 pdp-price-without-taxes-subtle js-price-without-taxes-wrap",
                    })
                }}
                {% else %}
                {{ component('price-without-taxes', {
                        container_classes: "mt-1 mb-2 font-small opacity-60",
                    })
                }}
                {% endif %}

                {% if template == 'product' and not home_main_product %}
                {% include 'snipplets/prices/theme-transfer-price-line.tpl' with {
                    visible: settings.payment_discount_price,
                    product: product,
                    wrapper_class: 'mt-2 mb-1 font-small pdp-transfer-price-line',
                    price_class: 'h6 font-weight-semibold font-family-body text-accent mb-0'
                } %}
                {% else %}
                {% include 'snipplets/prices/theme-transfer-price-line.tpl' with {
                    visible: settings.payment_discount_price,
                    product: product,
                    wrapper_class: 'mt-1 mb-3',
                    price_class: 'h5 font-big font-family-body text-accent'
                } %}
                {% endif %}
            </div>
        {% endif %}

        {{ component('subscriptions/subscription-price', {
            location: is_subscription_only_product ? 'product_detail',
            subscription_classes: {
                container: 'mb-3',
                prices_container: 'd-flex flex-wrap align-items-center mb-1',
                price_compare: 'font-big price-compare order-last',
                price_with_subscription: 'font-largest mr-1',
                discount_value: 'text-accent',
                price_without_taxes_container: 'my-2 font-small opacity-60',
            },
        }) }}

        {% set installments_info = product.installments_info_from_any_variant %}
        {% set hasDiscount = product.maxPaymentDiscount.value > 0 %}
        {% set show_payments_info = settings.product_detail_installments and product.show_installments and product.display_price and installments_info %}
        {% set show_pdp_payments_row = product.display_price and (
            show_payments_info
            or installments_info
            or hasDiscount
        ) %}

        {% if not home_main_product %}
            {% if template == 'product' %}
                {% if show_pdp_payments_row %}
                    <div {% if installments_info %}data-toggle="#installments-modal" data-modal-url="modal-fullscreen-payments"{% endif %} class="{% if installments_info %}js-modal-open js-fullscreen-modal-open{% endif %} js-product-payments-container pdp-payments-strip my-3 px-0"{% if not product.display_price %} style="display: none;"{% endif %}>
                        {% if settings.product_detail_installments and product.show_installments and product.display_price %}
                            {{ component('installments', {'location' : 'product_detail', container_classes: { installment: "font-small"}}) }}
                        {% endif %}
                    </div>
                {% endif %}
            {% else %}
                {% if show_payments_info or hasDiscount %}
                    <div {% if installments_info %}data-toggle="#installments-modal" data-modal-url="modal-fullscreen-payments"{% endif %} class="{% if installments_info %}js-modal-open js-fullscreen-modal-open{% endif %} js-product-payments-container pdp-payments-strip my-3 px-0" {% if not product.display_price or not (product.get_max_installments and product.get_max_installments(false)) %}style="display: none;"{% endif %}>
                        {% if show_payments_info %}
                            {{ component('installments', {'location' : 'product_detail', container_classes: { installment: "font-small"}}) }}
                        {% endif %}

                        {% set hideDiscountContainer = not (hasDiscount and product.showMaxPaymentDiscount) %}
                        {% set hideDiscountDisclaimer = not product.showMaxPaymentDiscountNotCombinableDisclaimer %}

                        <div class="js-product-discount-container my-1 font-small" {% if hideDiscountContainer %}style="display: none;"{% endif %}>
                            <span class="text-accent">{{ product.maxPaymentDiscount.value }}% {{'de descuento' | translate }}</span> {{'pagando con' | translate }} {{ product.maxPaymentDiscount.paymentProviderName }}
                            <div class="js-product-discount-disclaimer opacity-60 mt-1" {% if hideDiscountDisclaimer %}style="display: none;"{% endif %}>
                                {{ (product.showMaxPaymentDiscountCombinesWithSomeDiscounts
                                    ? "No acumulable con algunas promociones"
                                    : "No acumulable con otras promociones")
                                | translate }}
                            </div>
                        </div>
                        <a id="btn-installments" class="d-inline-block btn-link mt-1 font-small" href="#" {% if not (product.get_max_installments and product.get_max_installments(false)) %}style="display: none;"{% endif %}>
                            {% if not hasDiscount and not settings.product_detail_installments %}
                                {{ "Ver medios de pago" | translate }}
                            {% else %}
                                {{ "Ver más detalles" | translate }}
                            {% endif %}
                        </a>
                    </div>
                {% endif %}
            {% endif %}
        {% endif %}

        {# Product availability #}

        {% set show_product_quantity = product.available and product.display_price %}

        {# Free shipping minimum message #}
        {% set has_free_shipping = cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price %}
        {% set has_product_free_shipping = product.free_shipping %}

        {% if not product.is_non_shippable and show_product_quantity and (has_free_shipping or has_product_free_shipping) %}
            <div class="js-free-shipping-minimum-message free-shipping-message pt-1 mb-4 font-small">
                <span class="text-accent">{{ "Envío gratis" | translate }}</span>
                <span {% if has_product_free_shipping %}style="display: none;"{% else %}class="js-shipping-minimum-label"{% endif %}>
                    {{ "superando los" | translate }} <span>{{ cart.free_shipping.min_price_free_shipping.min_price }}</span>
                </span>
                {% if not has_product_free_shipping %}
                    <div class="js-free-shipping-discount-not-combinable font-small opacity-60 mt-1">
                        {{ "No acumulable con otras promociones" | translate }}
                    </div>
                {% endif %}
            </div>
        {% endif %}
    </div>
    </section>

        {% if template == 'product' and not home_main_product %}
                </div>
            </div>
        {% endif %}

    {% if template != 'product' %}
        {% include 'snipplets/product/product-pdp-highlights.tpl' %}
    {% endif %}

    {# Promotional text: arriba del formulario o debajo del CTA (setting brand_pdp_promos_below_purchase) #}

    {% if not settings.brand_pdp_promos_below_purchase %}
        {% include 'snipplets/product/product-promos-section.tpl' %}
    {% endif %}

    {# Product form, includes: Variants, CTA and Shipping calculator #}

    {% if not home_main_product %}
    <section class="pdp-section pdp-section--purchase" aria-labelledby="pdp-purchase-heading">
        <h2 id="pdp-purchase-heading" class="pdp-heading-visually-hidden">{{ 'Opciones de compra' | translate }}</h2>
    {% endif %}
     <form id="product_form" class="js-product-form pdp-product-form mt-3 mt-md-4" method="post" action="{{ store.cart_url }}" data-store="product-form-{{ product.id }}" aria-label="{{ 'Formulario del producto' | translate }}: {{ product.name }}">
        <input type="hidden" name="add_to_cart" value="{{product.id}}" />
        {% if template == "product" %}
            {% set show_size_guide = true %}
        {% endif %}
        {% if product.variations %}
            {% include "snipplets/product/product-variants.tpl" with {show_size_guide: show_size_guide} %}
        {% endif %}

        {% if settings.last_product and show_product_quantity %}
            <div class="{% if product.variations %}js-last-product{% endif %} text-accent mb-3"{% if product.selected_or_first_available_variant.stock != 1 %} style="display: none;"{% endif %}>
                {{ settings.last_product_text }}
            </div>
        {% endif %}

        {% set subscription_selector_markup %}
            {{ component('subscriptions/subscription-selector', {
                allow_subscription_only: is_subscription_only_product,
                subscription_only_container: 'p-3',
                subscription_classes: {
                    container: 'radio-button-container col-12 my-4',

                    radio_button: 'radio-button-item card overflow-visible p-3 mb-neg-1',
                    radio_button_label: 'ml-1',
                    radio_button_text: 'row',
                    radio_button_icon: 'radio-button-icons',
                    radio_button_icon_svg: 'icon-inline icon-sm svg-icon-primary',
                    purchase_option_info_container: 'col font-small pr-0',
                    purchase_option_price: 'col-auto text-right font-weight-bold',
                    purchase_option_single_frequency: 'mt-2 pt-1 font-small opacity-80',
                    purchase_option_discount: 'label label-accent label-small ml-1 py-1 px-2',

                    dropdown_container: 'form-group mt-3 mb-0',
                    dropdown_button: 'form-select form-select-small position-relative',
                    dropdown_icon: 'form-select-icon icon-inline icon-xs icon-w-14',
                    dropdown_options: 'form-select-options',
                    dropdown_option: 'form-select-option row no-gutters',
                    dropdown_option_info: 'col pr-4',
                    dropdown_option_price: 'col-auto font-weight-bold',
                    dropdown_option_discount: 'text-accent mt-1 font-weight-bold',

                    cart_alert: 'font-small text-center mt-3',
                    shipping_message: 'pt-3 mb-3',
                    shipping_message_title: 'font-weight-bold mb-2',

                    legal_message: 'font-smallest text-center w-100 mb-2 pb-1 px-3',
                    legal_link: 'font-smallest btn-link btn-link-primary',
                    legal_modal: 'bottom modal-centered-small modal-centered transition-soft',
                    legal_modal_header: 'modal-header row no-gutters align-items-center',
                    legal_modal_title: 'col offset-2 py-3',
                    legal_modal_close_button: 'col-2 pr-3 text-right',
                    legal_modal_close_icon: 'icon-inline icon-lg svg-icon-text',
                    legal_modal_body: 'mb-4',
                    legal_modal_details_title: 'h6 mb-3',
                    legal_modal_details_paragraph: 'font-small pb-4 mb-0',
                    legal_modal_details_link: 'font-small btn-link btn-link-primary'
                },
                dropdown_icon: true,
                dropdown_icon_svg_id: 'chevron-down',

                legal_modal_close_icon_id: 'times',
            }) }}
        {% endset %}

        {% if not home_main_product %}
        <div class="row mb-3 pdp-qty-subscription-row {% if settings.product_stock %}mb-md-2{% endif %} no-gutters align-items-end">
            {% if show_product_quantity %}
                {% include "snipplets/product/product-quantity.tpl" with {home_main_product: false} %}
            {% endif %}
            {{ subscription_selector_markup }}
        </div>
        <div class="row mb-4 {% if settings.product_stock %}mb-md-3{% endif %} product-form-cta-row product-form-cta-row--sticky-mobile mx-0 no-gutters">
        {% else %}
        <div class="row mb-4 {% if settings.product_stock %}mb-md-3{% endif %}">
            {% if show_product_quantity %}
                {% include "snipplets/product/product-quantity.tpl" with {home_main_product: true} %}
            {% endif %}
            {{ subscription_selector_markup }}
        {% endif %}

            {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
            {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

            {% set btn_container_classes = not home_main_product ? 'col-12' : (show_product_quantity and not product.isSubscribable() ? 'col-8 pl-md-0' : 'col-12') %}

            <div class="{{ btn_container_classes }}">

                {# Add to cart CTA #}

                <input type="submit" class="js-addtocart js-prod-submit-form btn-add-to-cart btn btn-primary btn-big btn-block {{ state }}" value="{{ texts[state] | translate }}" aria-label="{{ texts[state] | translate }}: {{ product.name }}" {% if state == 'nostock' %}disabled{% endif %} data-store="product-buy-button" data-component="product.add-to-cart"/>

                {# Fake add to cart CTA visible during add to cart event #}

                {% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: "btn-big"} %}

            </div>

            {% if settings.ajax_cart %}
                <div class="col-12">
                    <div class="js-added-to-cart-product-message font-small my-3" style="display: none;">
                        <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#check"/></svg>
                        <span>
                            {{'Ya agregaste este producto.' | translate }}<a href="#" class="js-modal-open js-open-cart js-fullscreen-modal-open btn-link font-small ml-1" data-toggle="#modal-cart" data-modal-url="modal-fullscreen-cart">{{ 'Ver carrito' | translate }}</a>
                        </span>
                    </div>
                </div>
            {% endif %}

            {# Free shipping visibility message #}

            {% set free_shipping_minimum_label_changes_visibility = has_free_shipping and cart.free_shipping.min_price_free_shipping.min_price_raw > 0 %}

            {% set include_product_free_shipping_min_wording = cart.free_shipping.min_price_free_shipping.min_price_raw > 0 %}

            {% if not product.is_non_shippable and show_product_quantity and has_free_shipping and not has_product_free_shipping %}
                <div class="px-3">

                    {# Free shipping add to cart message #}

                    {% if include_product_free_shipping_min_wording %}

                        {% include "snipplets/shipping/shipping-free-rest.tpl" with {'product_detail': true} %}

                    {% endif %}

                    {# Free shipping achieved message #}

                    <div class="js-product-form-free-shipping-message {% if free_shipping_minimum_label_changes_visibility %}js-free-shipping-message{% endif %} text-accent font-small my-2 pt-1" {% if not cart.free_shipping.cart_has_free_shipping %}style="display: none;"{% endif %}>
                        {{ "¡Genial! Tenés envío gratis" | translate }}
                    </div>
                </div>
            {% endif %}
        </div>

        {% if settings.brand_pdp_promos_below_purchase %}
            {% include 'snipplets/product/product-promos-section.tpl' %}
        {% endif %}

        {% if template == 'product' %}

            {% set show_product_fulfillment = settings.shipping_calculator_product_page and (store.has_shipping or store.branches) and not product.free_shipping and not product.is_non_shippable %}

            {% if not home_main_product %}
                {% include "snipplets/shipping/benefit-bar.tpl" with { context: 'pdp' } %}
                {% include 'snipplets/product/product-pdp-buybox-accordions.tpl' %}
            {% endif %}

            {% include 'snipplets/product/product-pdp-highlights.tpl' %}
        {% endif %}
     </form>
    {% if not home_main_product %}
    </section>
    {% endif %}
</div>

{% if not home_main_product %}
   {# Product payments details #}
    {% include 'snipplets/product/product-payment-details.tpl' %}
{% endif %}
