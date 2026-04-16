{# Check if store has free shipping without regions or categories #}

{% set has_free_shipping = cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price %}
{% set has_free_shipping_bar = has_free_shipping and cart.free_shipping.min_price_free_shipping.min_price_raw > 0 %}

{# Price without taxes classes #}
{% set price_without_taxes_container_classes = "row no-gutters font-small opacity-60 mt-1" %}
{% set price_without_taxes_label_classes = "col-auto" %}
{% set price_without_taxes_price_classes = "col text-right" %}

{% if has_free_shipping_bar %}
  
  {# includes free shipping progress bar: only if store has free shipping with a minimum #}
  
  {% if cart_page %}
    <div class="d-block d-md-none">
  {% endif %}
      {% include "snipplets/shipping/shipping-free-rest.tpl" %}
  {% if cart_page %}
    </div>
  {% endif %}

{% endif %}

{# IMPORTANT Do not remove this hidden subtotal, it is used by JS to calculate cart total #}
<div class="js-subtotal-price subtotal-price hidden" data-priceraw="{{ cart.total }}"></div>

{# Used to assign currency to total #}
<div id="store-curr" class="hidden">{{ cart.currency }}</div>

{# Define conditions to show shipping calculator and store branches on cart #}

{% set show_calculator_on_cart = settings.shipping_calculator_cart_page and store.has_shipping %}
{% set show_cart_fulfillment = settings.shipping_calculator_cart_page and (store.has_shipping or store.branches) %}

{# Cart subtotals for cart popup #}

{% if not cart_page %}

  {# Cart popup subtotal #}

  <div class="mb-3">
    <div class="js-visible-on-cart-filled row font-weight-normal" {% if cart.items_count == 0 %}style="display:none;"{% endif %} data-store="cart-subtotal">
      <span {% if not cart_page %}class="col-7"{% endif %}>
        <span class="font-weight-bold">{{ "Subtotal" | translate }}</span>
        
        <small class="js-subtotal-shipping-wording" {% if not (cart.has_shippable_products or show_calculator_on_cart) %}style="display: none"{% endif %}>{{ " (sin envío)" | translate }}</small>
        :
      </span>
      <span class="js-ajax-cart-total js-cart-subtotal font-weight-bold {% if not cart_page %}col{% endif %} text-right" data-priceraw="{{ cart.subtotal }}" data-component="cart.subtotal" data-component-value={{ cart.subtotal }}>{{ cart.subtotal | money_nocents }}</span>
    </div>

    {{ component('price-without-taxes', {
        location: 'cart',
        container_classes: price_without_taxes_container_classes,
        text_classes: {
          label: price_without_taxes_label_classes,
          price: price_without_taxes_price_classes,
        },
      })
    }}
  </div>

  {# Cart popup promos #}

  <div class="js-total-promotions text-accent">
    <span class="js-promo-discount" style="display:none;"> {{ "Descuento" | translate }}</span>
    <span class="js-promo-in" style="display:none;">{{ "en" | translate }}</span>
    <span class="js-promo-all" style="display:none;">{{ "todos los productos" | translate }}</span>
    <span class="js-promo-buying" style="display:none;"> {{ "comprando" | translate }}</span>
    <span class="js-promo-units-or-more" style="display:none;"> {{ "o más" | translate }}</span>
    {% for promotion in cart.promotional_discount.promotions_applied %}
      {% if not promotion.is_subscription_promotion %}
        {% if(promotion.scope_value_id) %}
          {% set id = promotion.scope_value_id %}
        {% else %}
          {% set id = 'all' %}
        {% endif %}
          <span class="js-total-promotions-detail-row row mb-3" id="{{ id }}">
            <span class="col pr-3">
              {% if promotion.discount_script_type != "custom" %}
                {% if promotion.discount_script_type == "NAtX%off" %}
                  {{ promotion.selected_threshold.discount_decimal_percentage * 100 }}% OFF
                {% elseif promotion.isBuyXPayY %}
                  {{ promotion.buy }}x{{ promotion.pay }}
                {% elseif promotion.isCrossSelling %}
                  {{ "Descuento" | translate }}
                {% else %}
                  {{ promotion.discount_script_type }}
                {% endif %}

                {{ "en" | translate }} {% if id == 'all' %}{{ "todos los productos" | translate }}{% else %}{{ promotion.scope_value_name }}{% endif %}

                {% if promotion.discount_script_type == "NAtX%off" %}
                  <span>{{ "Comprando {1} o más" | translate(promotion.selected_threshold.quantity) }}</span>
                {% endif %}
              {% else %}
                {{ promotion.scope_value_name }}
              {% endif %}
              :
            </span>
            <span class="col-auto text-right">-{{ promotion.total_discount_amount_short }}</span>
          </span>
      {% endif %}
    {% endfor %}
  </div>
{% endif %}

{% if cart_page %}

  {# Cart page subtotal #}

  <div id="cart-sticky-summary" class="position-sticky-md cart-page-totals">
    {% if has_free_shipping_bar %}
      {# includes free shipping progress bar: only if store has free shipping with a minimum #}
    
      <div class="d-none d-md-block">
        {% include "snipplets/shipping/shipping-free-rest.tpl" %}
      </div>
    {% endif %}

    <div class="mb-3">
      <div class="js-visible-on-cart-filled row no-gutters" {% if cart.items_count == 0 %}style="display:none;"{% endif %} data-store="cart-subtotal">
        <span class="col-auto pl-md-0">
          {{ "Subtotal" | translate }}:
        </span>
        <span class="js-ajax-cart-total js-cart-subtotal col text-right pr-md-0" data-priceraw="{{ cart.subtotal }}">{{ cart.subtotal | money_nocents }}</span>
      </div>

      {{ component('price-without-taxes', {
          location: 'cart',
          container_classes: price_without_taxes_container_classes,
          text_classes: {
            label: price_without_taxes_label_classes,
            price: price_without_taxes_price_classes,
          },
        })
      }}

    </div>

    {# Cart page promos #}

    <div class="js-total-promotions text-accent">
      <span class="js-promo-discount" style="display:none;">{{ "Descuento" | translate }}</span>
      <span class="js-promo-in" style="display:none;">{{ "en" | translate }}</span>
      <span class="js-promo-all" style="display:none;">{{ "todos los productos" | translate }}</span>
      <span class="js-promo-buying" style="display:none;"> {{ "comprando" | translate }}</span>
      <span class="js-promo-units-or-more" style="display:none;"> {{ "o más" | translate }}</span>
      {% for promotion in cart.promotional_discount.promotions_applied %}
        {% if not promotion.is_subscription_promotion %}
          {% if(promotion.scope_value_id) %}
            {% set id = promotion.scope_value_id %}
          {% else %}
            {% set id = 'all' %}
          {% endif %}
            <span class="js-total-promotions-detail-row row no-gutters mb-3" id="{{ id }}">
              <span class="col pr-3">
                {% if promotion.discount_script_type != "custom" %}
                  {% if promotion.discount_script_type == "NAtX%off" %}
                    {{ promotion.selected_threshold.discount_decimal_percentage * 100 }}% OFF
                  {% elseif promotion.isBuyXPayY %}
                    {{ promotion.buy }}x{{ promotion.pay }}
                  {% elseif promotion.isCrossSelling %}
                    {{ "Descuento" | translate }}
                  {% else %}
                    {{ promotion.discount_script_type }}
                  {% endif %}

                  {{ "en" | translate }} {% if id == 'all' %}{{ "todos los productos" | translate }}{% else %}{{ promotion.scope_value_name }}{% endif %}

                  {% if promotion.discount_script_type == "NAtX%off" %}
                    <span>{{ "Comprando {1} o más" | translate(promotion.selected_threshold.quantity) }}</span>
                  {% endif %}
                {% else %}
                  {{ promotion.scope_value_name }}
                {% endif %}
                :
              </span>
              <span class="col-auto text-right pr-md-0">-{{ promotion.total_discount_amount_short }}</span>
            </span>
        {% endif %}
      {% endfor %}
    </div>

    {# Cart page shipping costs #}

    {% if show_calculator_on_cart %}
      <div id="shipping-cost-container" class="js-fulfillment-info js-visible-on-cart-filled js-shipping-cost-table mb-3 row no-gutters" {% if cart.items_count == 0 or (not cart.has_shippable_products) %}style="display:none;"{% endif %}>
        <span class="col-auto pl-md-0">{{ 'Envío:' | translate }}</span>
        <span id="shipping-cost" class="col text-right opacity-40 pr-md-0">
          {{ "Calculalo para verlo" | translate }}
        </span>
        <span class="js-calculating-shipping-cost col text-right opacity-40 pr-md-0" style="display: none">
          {{ "Calculando" | translate }}...
        </span>
        <span class="js-shipping-cost-empty col text-right opacity-40 pr-md-0" style="display: none">
          {{ "Calculalo para verlo" | translate }}
        </span>
      </div>
    {% endif %}
{% else %}

  {# Cart fulfillment #}

  {% include "snipplets/shipping/cart-fulfillment.tpl" %}
{% endif %}
  
    {# Cart page and popup total #}

    <div class="js-cart-total-container js-visible-on-cart-filled" {% if cart.items_count == 0 %}style="display:none;"{% endif %} data-store="cart-total">
      <div class="row {% if cart_page %}no-gutters{% endif %} mb-3 h4 font-large font-family-body">
        <span class="col-auto {% if cart_page %}pl-md-0{% endif %}">{{ "Total" | translate }}:</span>
        <span class="js-cart-total {% if cart.free_shipping.cart_has_free_shipping %}js-free-shipping-achieved{% endif %} {% if cart.shipping_data.selected %}js-cart-saved-shipping{% endif %} col text-right {% if cart_page %}pr-md-0{% endif %}" data-component="cart.total" data-component-value={{ cart.total }}>{{ cart.total | money_nocents }}</span>
        <span class="col-12 {% if cart_page %}pr-md-0{% endif %}">
          {{ component('payment-discount-price', {
              visibility_condition: settings.payment_discount_price,
              location: 'cart',
              container_classes: 'font-small font-weight-normal mt-1 text-right',
            }) 
          }}
          {% if not settings.payment_discount_price %}
            {{ component('installments', {'location': 'cart', 'short_wording' : true, container_classes: { installment: "font-small font-weight-normal mt-1 text-right"}}) }}
          {% endif %}
        </span>
      </div>

      {# IMPORTANT Do not remove this hidden total, it is used by JS to calculate cart total #}
      <div class='total-price hidden'>
        {{ "Total" | translate }}: {{ cart.total | money_nocents }}
      </div>
    </div>

    <div class="js-visible-on-cart-filled" {% if cart.items_count == 0 %}style="display:none;"{% endif %}>

      {# Cart page and popup CTA Module #}
      
      {% set has_validation_messages = cart.checkout_enabled_validation_messages | length > 0 %}
      {% set should_show_checkout_button = cart.checkout_enabled and not has_validation_messages %}

      {% if cart_page %}

        {# Cart page CTA and minimum alert: Always render button to ensure it exists in DOM, control visibility via CSS/JS #}

        <input id="go-to-checkout" class="btn btn-primary btn-big btn-block mb-3" {{ not should_show_checkout_button ? 'style="display:none"' }} type="submit" name="go_to_checkout" value="{{ 'Iniciar Compra' | translate }}"/>

        {# Cart alert messages #}
        {{ component(
          'checkout-enabled-validation-messages', {
            alert_classes: 'alert alert-warning w-100 mb-2 text-center',
            cart_minimum_value: settings.cart_minimum_value
          })
        }}

      {% else %}

        {# Cart popup CTA and minimum alert #}

        <div class="js-ajax-cart-submit mb-3" {{ not should_show_checkout_button ? 'style="display:none"' }} id="ajax-cart-submit-div" >
          <input class="btn btn-primary btn-big btn-block" type="submit" name="go_to_checkout" value="{{ 'Iniciar Compra' | translate }}" data-component="cart.checkout-button"/>
        </div>

        {# Cart alert messages #}
        {{ component(
          'checkout-enabled-validation-messages', {
            alert_classes: 'alert alert-warning w-100 mb-2 text-center',
            cart_minimum_value: settings.cart_minimum_value
          })
        }}

      {% endif %}

      {# Cart panel continue buying link #}

      {% if settings.continue_buying %}
        <div class="text-center w-100 {% if not cart_page %}mb-md-2{% endif %} pb-3">
          <a href="{% if cart_page %}{{ store.products_url }}{% else %}#{% endif %}" class="{% if not cart_page %}js-modal-close js-fullscreen-modal-close{% endif %} btn-link font-small">{{ 'Ver más productos' | translate }}</a>
        </div>
      {% endif %}
    </div>
{% if cart_page %}
  {# End of sticky module #}
  </div>
{% endif %}
