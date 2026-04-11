{# Define conditions to show shipping calculator and store branches on cart #}

{% set show_calculator_on_cart = settings.shipping_calculator_cart_page and store.has_shipping %}
{% set show_cart_fulfillment = settings.shipping_calculator_cart_page and (store.has_shipping or store.branches) %}

{% if show_cart_fulfillment %}
  <div class="js-fulfillment-info js-allows-non-shippable cart-fulfillment-info {% if cart_page %}mb-4{% else %}my-4 pb-2{% endif %}" {% if not cart.has_shippable_products %}style="display: none"{% endif %}>
    <div class="js-visible-on-cart-filled js-has-new-shipping js-shipping-calculator-container">

      {# Saved shipping not available #}

      <div class="js-shipping-method-unavailable alert alert-warning row row mx-0 mb-3" style="display: none;">
        <div class="col-11 text-left pl-1 pr-0">
          <div class="mb-1">{{ 'El medio de envío que habías elegido ya no se encuentra disponible para este carrito. ' | translate }}</div>
          <div>{{ '¡No te preocupes! Podés elegir otro.' | translate}}</div>
        </div>
      </div>

      {# Shipping calculator and branch link #}

      <div id="cart-shipping-container" {% if cart.items_count == 0 %} style="display: none;"{% endif %} data-shipping-url="{{ store.shipping_calculator_url }}">

        {# Used to save shipping #}

        <span id="cart-selected-shipping-method" data-code="{{ cart.shipping_data.code }}" class="hidden">{{ cart.shipping_data.name }}</span>

        {# Shipping Calculator #}

        {% if store.has_shipping %}
          {% include "snipplets/shipping/shipping-calculator.tpl" with { 'product_detail': false} %}
        {% endif %}

        {# Store branches #}

        {% if store.branches %}
          {% include "snipplets/shipping/branches.tpl" with {'product_detail': false} %}
        {% endif %}
      </div>
    </div>
  </div>
{% endif %}