{% set selected_option = loop.first or cart.shipping_option == option.name %}
<div class="js-shipping-suboption mt-2 {{suboptions.name}}">

    {% if suboptions.options %}

        {# Read only suboptions inside popup #}

        {% set modal_id_val = (suboptions.name | sanitize) ~ '-pickup-modal-' ~ random() %}

        <div data-toggle="#{{ modal_id_val }}" class="js-modal-open js-open-over-modal btn-link font-small">
            {{ 'Ver direcciones' | translate }}
        </div>

        {% embed "snipplets/modal.tpl" with{modal_id: modal_id_val, modal_class: 'bottom modal-centered-small js-modal-shipping-suboptions', modal_position: 'center', modal_transition: 'slide', modal_header_title: true, modal_footer: false, modal_width: 'centered', modal_zindex_top: true} %}
            {% block modal_head %}
                {{ 'Puntos de retiro' | translate }}
            {% endblock %}
            {% block modal_body %}
                <ul class="pl-2 ml-2 my-2 m-0">
                    {% for option in suboptions.options %}
                        <li class="text-capitalize mb-3">{{ option.name | lower }}</li>
                    {% endfor %}
                </ul>
                <div class="mt-3"><span class="opacity-50">{{ 'Cercanos al CP:'}}</span> <span class="font-weight-bold">{{cart.shipping_zipcode}}</span></div>
                <div class="mt-2 pb-2 font-small">
                    <svg class="icon-inline svg-icon-text"><use xlink:href="#info-circle"/></svg>
                    <i>{{ "Vas a poder elegir estas opciones antes de finalizar tu compra" | translate }}</i>
                </div>
            {% endblock %}
        {% endembed %}

    {% else %}
        <input type="hidden" name="{{suboptions.name}}"/>
        <div>{{ suboptions.no_options_message | translate }}</div>
    {% endif %}
</div>