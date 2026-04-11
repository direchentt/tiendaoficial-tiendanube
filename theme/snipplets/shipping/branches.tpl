<div class="js-accordion-private-container{% if store.branches|length > 1 %} js-toggle-branches{% endif %} {% if product_detail %}js-product-branches-container{% endif %}">
    <div class="font-weight-bold {% if store.branches|length > 1 %}mb-2{% else %}mb-3{% endif %}">
        {% if store.branches|length > 1 %}
            {{ 'Nuestros locales' | translate }}
        {% else %}
            {{ 'Nuestro local' | translate }}
        {% endif %}
    </div>
    {% if store.branches|length > 1 %}
        <a href="#" class="js-accordion-private-toggle btn-link font-small">
            <span class="js-accordion-private-toggle-inactive">
                {{ 'Ver opciones' | translate }}
            </span>
            <span class="js-accordion-private-toggle-active" style="display: none;">
                {{ 'Ocultar opciones' | translate }}
            </span>
        </a>
    {% endif %}
    <div class="js-accordion-private-content mt-2 pt-1"{% if store.branches|length > 1 %} style="display: none;"{% endif %}>
    {% if not product_detail %}
        <div class="radio-buttons-group">
    {% else %}
        <div class="list">
    {% endif %}
            <ul class="radio-button-container list-unstyled">

                {% for branch in store.branches %}
                    <li class="card mb-neg-1 {% if product_detail %}list-item list-item-shipping radio-button{% else %}radio-button-item{% endif %} p-3 {% if loop.last %}mb-0{% endif %}" data-store="branch-item-{{ branch.code }}">

                        {# If cart use radiobutton #}

                        {% if not product_detail %}
                            <label class="js-shipping-radio js-branch-radio radio-button" data-loop="branch-radio-{{loop.index}}">
                        
                                <input 
                                class="js-branch-method {% if cart.shipping_data.code == branch.code %} js-selected-shipping-method {% endif %} shipping-method" 
                                data-price="0" 
                                {% if cart.shipping_data.code == branch.code %}checked{% endif %} type="radio" 
                                value="{{branch.code}}" 
                                data-name="{{ branch.name }} - {{ branch.extra }}"
                                data-code="{{branch.code}}" 
                                data-cost="{{ 'Gratis' | translate }}"
                                name="option" 
                                style="display:none">
                                <div class="shipping-option row-fluid radio-button-content">
                                   <div class="radio-button-icons-container">
                                        <span class="radio-button-icons">
                                            <span class="radio-button-icon unchecked"></span>
                                            <span class="radio-button-icon checked"></span>
                                        </span>
                                    </div>
                        {% endif %}
                                    <div class="{% if product_detail %}list-item-content{% else %}radio-button-label ml-1{% endif %}">
                                        <div class="row">
                                            <div class="col font-small {% if not product_detail %}pr-3{% endif %}">
                                                <div>{{ branch.name }} - {{ branch.extra }}</div>
                                            </div>
                                            <div class="col-auto text-right">
                                                <p class="text-accent mb-0 d-inline-block">{{ 'Gratis' | translate }}</p>
                                            </div>
                                        </div>
                                    </div>
                        {% if not product_detail %}
                                </div>
                            </label>
                        {% endif %}
                    </li>
                {% endfor %}
            </ul>
        </div>
    </div>
</div>