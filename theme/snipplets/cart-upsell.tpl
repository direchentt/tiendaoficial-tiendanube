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
<div class="cart-upsell-module" style="background-color: #111; color: #fff; padding: 12px; border-radius: 8px; margin: 0 15px 15px 15px;">
    <h5 style="text-align: center; font-size: 0.8rem; margin-bottom: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: #eee;">
        {{ settings.brand_pdp_store_section_complementary_title | default('Completá tu rutina:') }}
    </h5>
    
    <div class="cart-upsell-scroll" style="display: flex; overflow-x: auto; scroll-snap-type: x mandatory; gap: 10px; padding-bottom: 5px; scrollbar-width: none;">
        {% for p in cart_upsells|take(6) %}
            <div class="cart-upsell-item" style="flex: 0 0 85%; scroll-snap-align: start; display: flex; align-items: center; justify-content: space-between; background: rgba(255,255,255,0.05); padding: 8px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.1);">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <a href="{{ p.url }}" title="{{ p.name }}" style="flex-shrink: 0;">
                        {{ p.featured_image | product_image_url('small') | img_tag(p.featured_image.alt, {class: 'img-fluid', style: 'width: 45px; height: 45px; object-fit: cover; border-radius: 4px;'}) }}
                    </a>
                    <div style="display: flex; flex-direction: column; line-height: 1.2;">
                        <a href="{{ p.url }}" title="{{ p.name }}" style="color: #fff; font-size: 0.75rem; font-weight: 600; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;">
                            {{ p.name }}
                        </a>
                        <span style="font-size: 0.75rem; color: #aaa; margin-top: 3px; font-weight: 600;">
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
                    <button type="submit" class="js-addtocart js-cart-upsell-btn" aria-label="Agregar" style="background: #fff; color: #000; border: none; padding: 5px 10px; font-size: 0.7rem; font-weight: 700; border-radius: 4px; cursor: pointer; transition: opacity 0.2s;">
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
</div>
{% endif %}
