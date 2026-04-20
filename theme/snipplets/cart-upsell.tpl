{% set sec_comp = attribute(sections, 'comp_pdp') %}
{% set raw_comp = sec_comp and sec_comp.products ? sec_comp.products : [] %}
{% set cart_upsells = [] %}

{% for p in raw_comp %}
    {# Evitamos sugerir productos que ya esten en el carrito #}
    {% set in_cart = false %}
    {% for item in cart.items %}
        {% if item.product.id == p.id %}
            {% set in_cart = true %}
        {% endif %}
    {% endfor %}
    {% if not in_cart and (p.stock is null or p.stock > 0) %}
        {% set cart_upsells = cart_upsells|merge([p]) %}
    {% endif %}
{% endfor %}

{% if cart_upsells|length > 0 %}
{% set pad = is_pdp ? '20px 18px' : '18px 15px' %}
{% set img_size = is_pdp ? '75px' : '60px' %}
{% set title_size = is_pdp ? '0.90rem' : '0.85rem' %}
{% set price_size = is_pdp ? '0.90rem' : '0.85rem' %}
{% set btn_pad = is_pdp ? '9px 18px' : '7px 14px' %}

<div class="cart-upsell-module" style="background: rgba(30, 30, 30, 0.45); backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); border: 1px solid rgba(255, 255, 255, 0.15); color: #fff; padding: {{ pad }}; border-radius: 12px; margin: 0 15px 20px 15px; box-shadow: 0 8px 32px rgba(0,0,0,0.2);">
    <h5 style="text-align: center; font-size: 0.9rem; margin-bottom: 15px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: #eee;">
        {{ settings.brand_pdp_store_section_complementary_title | default('Completá tu rutina:') }}
    </h5>
    
    <div class="cart-upsell-scroll" style="display: flex; overflow-x: auto; scroll-snap-type: x mandatory; gap: 12px; padding-bottom: 5px; scrollbar-width: none;">
        {% for p in cart_upsells|take(6) %}
            <div class="cart-upsell-item" style="flex: 0 0 {% if is_pdp %}95%{% else %}90%{% endif %}; scroll-snap-align: start; display: flex; align-items: center; justify-content: space-between; background: rgba(255,255,255,0.08); padding: 10px 12px; border-radius: 10px; border: 1px solid rgba(255,255,255,0.05); box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <a href="{{ p.url }}" title="{{ p.name }}" style="flex-shrink: 0;">
                        {{ p.featured_image | product_image_url('small') | img_tag(p.featured_image.alt, {class: 'img-fluid', style: 'width: '~img_size~'; height: '~img_size~'; object-fit: cover; border-radius: 6px;'}) }}
                    </a>
                    <div style="display: flex; flex-direction: column; line-height: 1.3;">
                        <a href="{{ p.url }}" title="{{ p.name }}" style="color: #fff; font-size: {{ title_size }}; font-weight: 700; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;">
                            {{ p.name }}
                        </a>
                        <span style="font-size: {{ price_size }}; color: #bbb; margin-top: 4px; font-weight: 600;">
                            {% if p.display_price %}
                                {{ p.price | money }}
                            {% endif %}
                        </span>
                    </div>
                </div>
                
                <form method="post" action="{{ store.cart_url }}" class="js-product-form" style="margin: 0; flex-shrink: 0;" data-store="product-form-{{ p.id }}">
                    <input type="hidden" name="add_to_cart" value="{{ p.id }}">
                    {% if p.variants %}
                        <input type="hidden" name="variant_id" value="{{ p.variants[0].id }}">
                    {% endif %}
                    <button type="submit" class="js-addtocart js-cart-upsell-btn" aria-label="Agregar" style="background: #fff; color: #111; border: none; padding: {{ btn_pad }}; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; border-radius: 6px; cursor: pointer; transition: opacity 0.2s; box-shadow: 0 2px 5px rgba(255,255,255,0.2);">
                        Agregar
                    </button>
                    <div class="js-addtocart-success" style="display: none; color: #22c55e; font-size: 0.7rem; font-weight: 700;">¡Listo!</div>
                </form>
            </div>
        {% endfor %}
    </div>
    
    <style>
        .cart-upsell-scroll::-webkit-scrollbar { display: none; }
        .cart-upsell-btn:hover { opacity: 0.8; }
        .js-addtocart.js-addtocart-adding { opacity: 0.5; pointer-events: none; }
    </style>
    
    <script>
      if (!window.upsellIntervalStarted) {
          window.upsellIntervalStarted = true;
          setInterval(function() {
              var containers = document.querySelectorAll('.cart-upsell-scroll');
              containers.forEach(function(container) {
                  // Solo scrollear si el mouse no está encima
                  if (container.matches(':hover')) return;
                  
                  var maxScroll = container.scrollWidth - container.clientWidth;
                  if (maxScroll <= 10) return; // no hay productos para scrollear
                  
                  if (typeof container.dataset.scrollDir === 'undefined') container.dataset.scrollDir = 1;
                  var dir = parseInt(container.dataset.scrollDir);
                  
                  if (container.scrollLeft >= maxScroll - 10) dir = -1;
                  else if (container.scrollLeft <= 10) dir = 1;
                  
                  container.dataset.scrollDir = dir;
                  var scrollAmt = (container.clientWidth * 0.85) * dir;
                  container.scrollBy({ left: scrollAmt, behavior: 'smooth' });
              });
          }, 5000);
      }
    </script>
</div>
{% endif %}
