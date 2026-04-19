{# /*============================================================================
  #Item grid
==============================================================================*/

#Properties

#Slide Item

#}

{% set slide_item = slide_item | default(false) %}

{% if template == 'home'%}
    {% set columns_desktop = section_columns_desktop %}
    {% set columns_mobile = section_columns_mobile %}
    {% set section_slider = section_slider %}
{% else %}
    {% set columns_desktop = settings.grid_columns_desktop %}
    {% set columns_mobile = settings.grid_columns_mobile %}
    {% if template == 'product'%}
        {% set section_slider = true %}
    {% endif %}
{% endif %}

{# Item image slider — opción nativa del panel: "Mostrar las fotos en un carrusel para cada producto" (product_item_slider).
   Se aplica en todo sitio donde se incluye esta tarjeta (home, categoría, búsqueda, relacionados, carril, 404, carrito sugerido, etc.) si hay más de una imagen. #}
{# En listados a veces `other_images` viene vacío aunque haya más de una imagen; usamos también `product.images`. #}
{% set product_has_extra_images = (product.other_images is not empty)
    or ((product.images|default([]))|length > 1) %}

{% set show_image_slider =
    settings.product_item_slider
    and not reduced_item
    and product_has_extra_images
%}

{% set slider_controls_container_class = 'item-slider-controls-container svg-icon-text d-flex align-items-center justify-content-center' %}
{% set control_next_svg_id = 'arrow-long' %}
{% set control_prev_svg_id = 'arrow-long' %}

{# Botón "ver otra foto": con carrusel por ítem dispara el siguiente slide; sin carrusel alterna imagen secundaria. #}
{% set buy_label_custom = settings.product_list_buy_label | default('') | trim %}
{% set show_list_flip_btn = product_has_extra_images and not reduced_item and not slide_item %}
{# Compra rápida activa + producto con variantes: "+" y barra inline en home, categoría y carruseles (sin exigir "CTA tipo plus" en el panel). #}
{% set show_qs_floating = settings.quick_shop
    and not product.isSubscribable()
    and product.available
    and product.display_price
    and product.variations
    and not reduced_item
%}
{% set show_flip_floating = show_list_flip_btn and not settings.quick_shop %}
{% set show_secondary_image = settings.product_hover or (show_list_flip_btn and not show_image_slider) %}
{% set show_floating_photo_wrap = show_flip_floating or show_qs_floating %}

{# Subscription only detection #}
{% set is_subscription_only = product.isSubscriptionOnly() %}

{% set columns_mobile_class = columns_mobile == 1 ? 'col-12' : columns_mobile == 2 ? 'col-6' : columns_mobile == 3 ? 'col-4' : loop.index % 5 == 1 ? 'col-12' : 'col-6' %}
{% set columns_desktop_class = columns_desktop == 2 ? 'col-md-6' : columns_desktop == 3 ? 'col-md-4' : columns_desktop == 4 ? 'col-md-3' : columns_desktop == 5 ? 'col-grid-md-5' : 'col-md-3' %}

    <div class="js-item-product{% if slide_item %} js-item-slide swiper-slide{% endif %} {{ columns_mobile_class }} {{ columns_desktop_class }} item-product {% if reduced_item %}item-product-reduced{% endif %} col-grid" data-product-type="list" data-product-id="{{ product.id }}" data-store="product-item-{{ product.id }}" data-component="product-list-item" data-component-value="{{ product.id }}"{% if buy_label_custom != '' %} data-list-buy-label-cart="{{ buy_label_custom | e('html_attr') }}"{% endif %}{% if settings.payment_discount_price and not reduced_item and product.maxPaymentDiscount is defined and product.maxPaymentDiscount.value > 0 %}
	{% set _transfer_suffix = product.maxPaymentDiscount.paymentProviderName
		? ('pagando con' | translate) ~ ' ' ~ product.maxPaymentDiscount.paymentProviderName
		: ('con transferencia' | translate) %}
 data-transfer-pct="{{ product.maxPaymentDiscount.value }}" data-transfer-suffix="{{ _transfer_suffix | e('html_attr') }}"{% endif %}>
        <div class="item {% if reduced_item %}mb-0{% endif %}">
            {% if (settings.quick_shop or settings.product_color_variants or (settings.product_listing_variant_images | default(false))) and not reduced_item %}
                <div class="js-product-container js-quickshop-container{% if product.variations %} js-quickshop-has-variants{% endif %} position-relative" data-variants="{{ product.variants_object | json_encode }}" data-quickshop-id="quick{{ product.id }}">
            {% endif %}
            {% set product_url_with_selected_variant = has_filters ?  ( product.url | add_param('variant', product.selected_or_first_available_variant.id)) : product.url  %}

            {# Set how much viewport space the images will take to load correct image #}

            {% if columns_mobile == 2 %}
                {% set mobile_image_viewport_space = '50' %}
            {% elseif columns_mobile == 3 %}
                {% set mobile_image_viewport_space = '33' %}
            {% else %}
                {% set mobile_image_viewport_space = '100' %}
            {% endif %}

            {% if columns_desktop == 5 %}
                {% set desktop_image_viewport_space = '20' %}
            {% elseif columns_desktop == 4 %}
                {% set desktop_image_viewport_space = '25' %}
            {% elseif columns_desktop == 3 %}
                {% set desktop_image_viewport_space = '33' %}
            {% else %}
                {% set desktop_image_viewport_space = '50' %}
            {% endif %}

            {% set image_classes = 'js-item-image lazyautosizes ' ~ (not image_priority_high ? 'lazyload') ~ ' fade-in img-absolute img-absolute-centered' %}
            {% set data_expand = show_image_slider ? '50' : '-10' %}

            {% set label_custom_class = settings.brand_labels_minimal ? 'labels--brand-minimal' : '' %}
            {% set floating_elements %}
                {% if not reduced_item %}
                    {% include 'snipplets/labels.tpl' %}
                {% endif %}
            {% endset %}

            {% if show_qs_floating %}
            <div class="js-item-media-stack position-relative">
            {% endif %}
            {% if show_floating_photo_wrap %}
            <div class="position-relative js-item-flip-photo-root{% if show_flip_floating and not show_image_slider %} js-item-image-flip-wrap{% endif %}">
            {% endif %}
            {{ component(
                'product-item-image', {
                    image_lazy: true,
                    image_lazy_js: true,
                    image_thumbs: ['small', 'medium', 'large', 'huge', 'original'],
                    image_data_expand: data_expand,
                    image_secondary_data_sizes: 'auto',
                    image_sizes: '(max-width: 768px)' ~ mobile_image_viewport_space ~ 'vw, (min-width: 769px)' ~ desktop_image_viewport_space ~ 'vw',
                    secondary_image: show_secondary_image,
                    slider: show_image_slider,
                    placeholder: true,
                    image_priority_high: image_priority_high,
                    custom_content: floating_elements,
                    slider_pagination_container: true,
                    product_item_image_classes: {
                        image_container: 'item-image' ~ (show_image_slider ? ' item-image-slider'),
                        image_padding_container: 'js-item-image-padding position-relative d-block',
                        image: image_classes,
                        image_featured: 'item-image-featured',
                        image_secondary: 'item-image-secondary',
                        slider_container: 'swiper-container position-absolute h-100 w-100',
                        slider_wrapper: 'swiper-wrapper',
                        slider_slide: 'swiper-slide item-image-slide',
                        slider_control_pagination_container: 'item-slider-pagination-container',
                        slider_control_pagination: 'swiper-pagination item-slider-pagination',
                        slider_control: 'icon-inline icon-lg',
                        slider_control_prev_container: 'swiper-button-prev ' ~ slider_controls_container_class,
                        slider_control_prev: 'icon-flip-horizontal',
                        slider_control_next_container: 'swiper-button-next ' ~ slider_controls_container_class,
                        more_images_message: 'item-more-images-message',
                        placeholder: 'placeholder-fade',
                    },
                    control_next_svg_id: control_next_svg_id,
                    control_prev_svg_id: control_prev_svg_id,
                })
            }}
            {% if show_flip_floating %}
                <button type="button" class="js-item-img-flip btn item-img-flip-btn p-0" aria-label="{{ 'Ver otra perspectiva' | translate }}" aria-pressed="false" title="{{ 'Ver otra perspectiva' | translate }}">
                    <span class="item-img-flip-btn__inner" aria-hidden="true">
                        <svg class="icon-inline" width="14" height="14"><use xlink:href="#plus"/></svg>
                    </span>
                </button>
            {% endif %}
            {% if show_qs_floating %}
                               {# swiper-no-swiping: Swiper no debe tratar el toque como arrastre del carrusel. data-theme-grid-qs-plus: delegación en store.js (sin onclick: CSP). #}
                <button type="button" class="js-item-qs-plus-floating swiper-no-swiping btn item-img-flip-btn p-0" data-theme-grid-qs-plus="1" aria-label="{{ 'Compra rápida' | translate }}" title="{{ 'Compra rápida' | translate }} {{ product.name }}">
                    <span class="item-img-flip-btn__inner" aria-hidden="true">
                        <svg class="icon-inline" width="14" height="14"><use xlink:href="#plus"/></svg>
                    </span>
                </button>
            {% endif %}
            {% if show_floating_photo_wrap %}
            </div>
            {% endif %}
    
            {% if 
                ((settings.quick_shop and not product.isSubscribable()) or settings.product_color_variants or (settings.product_listing_variant_images | default(false)))
                and product.available 
                and product.display_price 
                and product.variations 
                and not reduced_item 
            %}

                {# Hidden product form: modal "Comprar" (LS.fillQuickshop) o barra en tarjeta si hay CTA "+" #}

                <div class="js-item-variants hidden">
                    <form class="js-product-form" method="post" action="{{ store.cart_url }}">
                        <input type="hidden" name="add_to_cart" value="{{product.id}}" />
                        {% if product.variations %}
                            {% include "snipplets/product/product-variants.tpl" with {quickshop: true} %}
                        {% endif %}
                        {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                        {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

                        {# Add to cart CTA #}

                        {% set show_product_quantity = product.available and product.display_price %}

                        <div class="row mt-3">

                            {% if show_product_quantity %}
                                {% include "snipplets/product/product-quantity.tpl" with {quickshop: true} %}
                            {% endif %}

                            <div class="{% if show_product_quantity %}col-8 pl-0{% else %}col-12{% endif %}">

                                <input type="submit" class="js-addtocart js-prod-submit-form btn-add-to-cart btn btn-primary btn-big w-100 {{ state }}" value="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} />

                                {# Fake add to cart CTA visible during add to cart event #}

                                {% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: "btn-big"} %}
                            </div>
                        </div>
                    </form>
                </div>

            {% endif %}
            {% if show_qs_floating %}
            </div>
            {% endif %}
            {% set show_labels = not product.has_stock or product.compare_at_price or product.hasVisiblePromotionLabel %}
            <div class="item-description pt-3" data-store="product-item-info-{{ product.id }}">
                <a href="{{ product_url_with_selected_variant }}" title="{{ product.name }}" aria-label="{{ product.name }}" class="item-link">
                    {% if settings.product_color_variants and not (settings.product_listing_variant_images | default(false)) and not reduced_item %}
                        {% include 'snipplets/grid/item-colors.tpl' %}
                    {% endif %}
                    {% if (settings.product_listing_variant_images | default(false)) and not reduced_item %}
                        {% include 'snipplets/grid/item-variant-thumbs.tpl' %}
                    {% endif %}
                    <div class="js-item-name item-name mb-2 font-weight-bold" data-store="product-item-name-{{ product.id }}">{{ product.name }}</div>
                    {% if product.display_price %}
                        {% if is_subscription_only %}
                            {# Subscription only products: use subscription-price component with product_list location #}
                            {{ component('subscriptions/subscription-price', {
                                location: 'product_list',
                                subscription_classes: {
                                    container: 'item-price-container' ~ (settings.quick_shop and not show_qs_floating ? ' mb-3' : ''),
                                    price_compare: 'price-compare',
                                    price_with_subscription: 'item-price',
                                },
                            }) }}
                        {% else %}
                            {# Normal products: original price display #}
                            <div class="item-price-container {% if settings.quick_shop and not show_qs_floating %}mb-3{% endif %}" data-store="product-item-price-{{ product.id }}">
                                <span class="js-price-display item-price" data-product-price="{{ product.price }}">
                                    {{ product.price | money_nocents }}
                                </span>
                                {% if not reduced_item %}
                                    <span class="js-compare-price-display price-compare" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% else %}style="display:inline-block;"{% endif %}>
                                        {{ product.compare_at_price | money_nocents }}
                                    </span>
                                {% endif %}

                                {% set product_can_show_installments = product.show_installments and product.display_price and product.get_max_installments.installment > 1 and settings.product_installments and not reduced_item %}

                                {% include 'snipplets/prices/theme-transfer-price-line.tpl' with {
                                    visible: settings.payment_discount_price and not reduced_item,
                                    product: product,
                                    wrapper_class: 'font-small mt-1',
                                    price_class: 'text-accent font-weight-semibold'
                                } %}

                                {% if product_can_show_installments %}
                                    {{ component('installments', {'location' : 'product_item' , 'short_wording' : true, container_classes: { installment: "item-installments mt-2"}}) }}
                                {% endif %}
                            </div>
                        {% endif %}

                        {# Subscription message - shown for all subscribable products (outside price conditional) #}
                        {% if not reduced_item %}
                            {{ component('subscriptions/subscription-message', {
                                subscription_classes: {
                                    container: 'font-small mt-2',
                                },
                            }) }}
                        {% endif %}
                    {% endif %}
                </a>
                    {% if product.available and product.display_price and settings.quick_shop and not reduced_item %}
                        {% if settings.quick_shop %}

                            {% set quickshop_button_classes = 'btn btn-link' %}

                            {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                            {% set texts = {'cart': "Comprar", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}
                            {% set list_cta_wording = (state == 'cart' and buy_label_custom != '') ? buy_label_custom : (texts[state] | translate) %}

                            <div class="item-actions d-block{% if show_qs_floating %} item-actions--qs-plus-proxy{% endif %}"{% if show_qs_floating %} aria-hidden="true"{% endif %}>

                                {% if product.isSubscribable() %}

                                    {# Product with subscription will link to the product page #}

                                    {% if is_subscription_only %}
                                        {# Subscription only: convert to clickable link with "Suscribir" text #}
                                        {% set button_text = 'our_components.subscriptions.subscribe' | tt %}
                                        {% set button_title = button_text ~ ' ' ~ product.name %}
                                        <a href="{{ product_url_with_selected_variant }}" class="{{ quickshop_button_classes }}" title="{{ button_title }}" aria-label="{{ button_title }}">
                                            {{ button_text }}
                                        </a>
                                    {% else %}
                                        {# Subscribable (not subscription only): keep original span #}
                                        <span class="{{ quickshop_button_classes }}" title="{{ 'Compra rápida de' | translate }} {{ product.name }}" aria-label="{{ 'Compra rápida de' | translate }} {{ product.name }}">
                                            {{ list_cta_wording }}
                                        </span>
                                    {% endif %}

                                {% else %}
                                
                                    {% if product.variations %}

                                        {# Open quickshop popup if has variants #}

                                        <span data-toggle="#quickshop-modal" class="js-quickshop-modal-open {% if slide_item %}js-quickshop-slide{% endif %} js-modal-open {{ quickshop_button_classes }}" title="{{ 'Compra rápida de' | translate }} {{ product.name }}" aria-label="{{ 'Compra rápida de' | translate }} {{ product.name }}" data-component="product-list-item.add-to-cart" data-component-value="{{product.id}}">
                                            <span class="js-open-quickshop-wording">{{ list_cta_wording }}</span>
                                        </span>
                                    {% else %}
                                        {# If not variants add directly to cart #}
                                        <form class="js-product-form" method="post" action="{{ store.cart_url }}">
                                            <input type="hidden" name="add_to_cart" value="{{product.id}}" />
                                            
                                            <div class="js-item-submit-container item-submit-container position-relative float-left d-inline-block w-100">
                                                <input type="submit" class="js-addtocart js-prod-submit-form js-quickshop-icon-add {{ quickshop_button_classes }} {{ state }}" value="{{ list_cta_wording }}" aria-label="{{ list_cta_wording }}" {% if state == 'nostock' %}disabled{% endif %} data-component="product-list-item.add-to-cart" data-component-value="{{ product.id }}"/>
                                            </div>

                                            {# Fake add to cart CTA visible during add to cart event #}

                                            {% include 'snipplets/placeholders/button-placeholder.tpl' with {direct_add: true, custom_class: 'w-100 text-left'} %}
                                        </form>
                                    {% endif %}
                                {% endif %}
                                
                            </div>
                        {% endif %}
                    {% endif %}
            </div>
            {% if (settings.quick_shop or settings.product_color_variants or (settings.product_listing_variant_images | default(false))) and not reduced_item %}
                </div>{# This closes the quickshop tag #}
            {% endif %}

            {# Structured data to provide information for Google about the product content #}
            {{ component('structured-data', {'item': true}) }}
        </div>
    </div>
