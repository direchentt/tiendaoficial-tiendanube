<div class="js-addtocart js-addtocart-placeholder btn {% if not direct_add %}btn-primary btn-block{% endif %} btn-transition {{ custom_class }} disabled" style="display: none;">
    <div class="d-inline-block">
        <span class="js-addtocart-text">
            {% if direct_add %}
                <div class="d-flex justify-content-center align-items-center btn-link">
                    {{ 'Comprar' | translate }}
                </div>
            {% else %}
                {{ 'Agregar al carrito' | translate }}
            {% endif %}
        </span>
        <span class="js-addtocart-success transition-container">
            {{ '¡Listo!' | translate }}
        </span>
        <div class="js-addtocart-adding js-addtocart-adding-text transition-container{% if direct_add %} btn-link{% endif %}">
            {{ 'Agregando...' | translate }}
        </div>
    </div>
</div>