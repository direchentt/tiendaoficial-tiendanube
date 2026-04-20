<div class="container mt-5 mb-4 text-center">
    <h1 style="font-family: var(--font-headings, sans-serif); font-size: 2.5rem; font-weight: 600; letter-spacing: -0.02em; margin-bottom: 0;">
        {{ "Mis datos" | translate }}
    </h1>
    <p style="color: #555; font-size: 1.1rem; margin-top: 5px;">Mantené tu información al día.</p>
</div>

<section class="account-page mb-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div style="background: #fff; padding: 40px; border-radius: 4px; border: 1px solid #eaeaea;">
                    {% embed "snipplets/forms/form.tpl" with{form_id: 'info-form', submit_custom_class: 'btn-primary btn-big btn-block text-uppercase border-radius-0 mt-4', submit_text: 'Guardar cambios' | translate } %}
                        {% block form_body %}

                            {# Name input #}
                            
                            {% embed "snipplets/forms/form-input.tpl" with{type_text: true, input_for: 'name', input_value: result.name | default(customer.name), input_name: 'name', input_id: 'name', input_label_text: 'Nombre Completo' | translate } %}
                                {% block input_form_alert %}
                                    {% if result.errors.name %}
                                        <div class="alert alert-danger font-small mt-2 p-2">{{ 'Necesitamos saber tu nombre para actualizar tu información.' | translate }}</div>
                                    {% endif %}
                                {% endblock input_form_alert %}
                            {% endembed %}

                            {# Email input #}

                            {% embed "snipplets/forms/form-input.tpl" with{type_email: true, input_for: 'email', input_value: result.email | default(customer.email), input_name: 'email', input_id: 'email', input_label_text: 'Email' | translate } %}
                                {% block input_form_alert %}
                                    {% if result.errors.email == 'exists' %}
                                        <div class="alert alert-danger font-small mt-2 p-2">{{ 'Encontramos otra cuenta que ya usa este email. Intentá usando otro.' | translate }}</div>
                                    {% elseif result.errors.email %}
                                        <div class="alert alert-danger font-small mt-2 p-2">{{ 'Necesitamos saber tu email para actualizar tu información.' | translate }}</div>
                                    {% endif %}
                                {% endblock input_form_alert %}
                            {% endembed %}

                            {# Phone input #}

                            {% embed "snipplets/forms/form-input.tpl" with{type_tel: true, input_for: 'phone', input_value: result.phone | default(customer.phone), input_name: 'phone', input_id: 'phone', input_label_text: 'Teléfono (opcional)' | translate } %}
                            {% endembed %}
                        {% endblock %}
                    {% endembed %}
                    <hr style="margin: 30px 0; border-top: 1px solid #eaeaea;">
                    <p class="text-center mb-0">
                        <a href="{{ store.customer_reset_password_url }}" class="btn-link font-small font-weight-bold">{{ "¿Querés cambiar tu contraseña?" | translate }}</a>
                    </p>
                    <p class="text-center mt-3 mb-0">
                        <a href="{{ store.customer_orders_url }}" class="btn-link font-small text-muted">{{ "Volver a mi cuenta" | translate }}</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</section>