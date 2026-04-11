{% set newsletter_contact_error = contact.type == 'newsletter' and not contact.success %}

{% if settings.news_show %}
    <div class="js-newsletter newsletter mb-4 pb-3 pr-3 pr-md-0">
        {% if settings.news_title %}
            <div class="h4-huge h2-huge-md">{{ settings.news_title }}</div>
        {% endif %}
            
        <form method="post" action="/winnie-pooh" onsubmit="this.setAttribute('action', '');" data-store="newsletter-form">
            <div class="newsletter-form input-append">
                {% embed "snipplets/forms/form-input.tpl" with{input_for: 'email', type_email: true, input_name: 'email', input_id: 'email', input_placeholder: 'Email' | translate, input_group_custom_class: "mb-0", input_custom_class: 'form-control-line', input_aria_label: 'Email' | translate } %}
                {% endembed %}
                <div class="winnie-pooh" style="display: none;">
                    <label for="winnie-pooh-newsletter">{{ "No completar este campo" | translate }}</label>
                    <input id="winnie-pooh-newsletter" type="text" name="winnie-pooh"/>
                </div>
                <input type="hidden" name="name" value="{{ "Sin nombre" | translate }}" />
                <input type="hidden" name="message" value="{{ "Pedido de inscripción a newsletter" | translate }}" />
                <input type="hidden" name="type" value="newsletter" />
                <input type="submit" name="contact" class="btn btn-link form-control-btn form-control-line-btn" value="{{ "Enviar" | translate }}" />
            </div>
        </form>

        {% if contact and contact.type == 'newsletter' %}
            {% if contact.success %}
                <div class="alert alert-success mt-3">{{ "¡Gracias por suscribirte! A partir de ahora vas a recibir nuestras novedades en tu email" | translate }}</div>
            {% else %}
                <div class="alert alert-danger mt-3">{{ "Necesitamos tu email para enviarte nuestras novedades." | translate }}</div>
            {% endif %}
        {% endif %}
    </div>
{% endif %}