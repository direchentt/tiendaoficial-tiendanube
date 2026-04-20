<div class="container mt-5 mb-4 text-center">
    <h1 style="font-family: var(--font-headings, sans-serif); font-size: 2.5rem; font-weight: 600; letter-spacing: -0.02em; margin-bottom: 0;">
        {{ "Dirección" | translate }}
    </h1>
    <p style="color: #555; font-size: 1.1rem; margin-top: 5px;">Agregá o modificá los datos para tus entregas.</p>
</div>

<section class="account-page mb-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <div style="background: #fff; padding: 40px; border-radius: 4px; border: 1px solid #eaeaea;">
                
                {% embed "snipplets/forms/form.tpl" with{form_id: 'address-form', submit_custom_class: 'btn-primary btn-big btn-block text-uppercase border-radius-0 mt-4', submit_text: 'Guardar dirección' | translate } %}
                    {% block form_body %}

                        {# Name input #}
                        {% embed "snipplets/forms/form-input.tpl" with{type_text: true, input_for: 'name', input_value: result.name | default(address.name), input_name: 'name', input_id: 'name', input_label_text: 'Nombre (alias)' | translate, input_placeholder: 'ej.: Trabajo' | translate } %}
                            {% block input_form_alert %}
                                {% if result.errors.name %}
                                    <div class="alert alert-danger font-small mt-2 p-2">{{ 'Ingresá un alias para reconocer esta dirección en el futuro.' | translate }}</div>
                                {% endif %}
                            {% endblock input_form_alert %}
                        {% endembed %}

                        {# Address input #}
                        {% if current_language.country == 'BR' %}
                            {% set address_placeholder = 'ej.: Av. Pueyrredón' | translate %}
                        {% else %}
                            {% set address_placeholder = 'ej.: Av. Pueyrredón 1234, CABA' | translate %}
                        {% endif %}
                        
                        {% embed "snipplets/forms/form-input.tpl" with{type_text: true, input_for: 'address', input_value: result.address | default(address.address), input_name: 'address', input_id: 'address', input_label_text: 'Dirección' | translate, input_placeholder: address_placeholder } %}
                            {% block input_form_alert %}
                                {% if result.errors.address %}
                                    <div class="alert alert-danger font-small mt-2 p-2">{{ 'Necesitamos una dirección para enviar tus pedidos.' | translate }}</div>
                                {% endif %}
                            {% endblock input_form_alert %}
                        {% endembed %}

                        {% if current_language.country == 'BR' %}
                            <div class="row">
                                <div class="col-sm-6">
                                    {# Address number #}
                                    {% embed "snipplets/forms/form-input.tpl" with{type_number: true, input_for: 'number', input_value: result.number | default(address.number), input_name: 'number', input_id: 'number', input_label_text: 'Número' | translate, input_placeholder: 'ej.: 1234' | translate } %}
                                        {% block input_form_alert %}
                                            {% if result.errors.number %}
                                                <div class="alert alert-danger font-small mt-2 p-2">{{ 'Necesitamos saber tu número para actualizar tu información.' | translate }}</div>
                                            {% endif %}
                                        {% endblock input_form_alert %}
                                    {% endembed %}
                                </div>
                                <div class="col-sm-6">
                                    {# Address Floor #}
                                    {% embed "snipplets/forms/form-input.tpl" with{type_number: true, input_for: 'floor', input_value: result.floor | default(address.floor), input_name: 'floor', input_id: 'floor', input_label_text: 'Piso' | translate } %}
                                        {% block input_form_alert %}
                                            {% if result.errors.floor %}
                                                <div class="alert alert-danger font-small mt-2 p-2">{{ 'Necesitamos saber tu piso.' | translate }}</div>
                                            {% endif %}
                                        {% endblock input_form_alert %}
                                    {% endembed %}
                                </div>
                                <div class="col-12">
                                    {# Address Locality #}
                                    {% embed "snipplets/forms/form-input.tpl" with{type_text: true, input_for: 'locality', input_value: result.locality | default(address.locality), input_name: 'locality', input_id: 'locality', input_label_text: 'Localidad' | translate, input_placeholder: 'ej.: CABA' | translate } %}
                                        {% block input_form_alert %}
                                            {% if result.errors.locality %}
                                                <div class="alert alert-danger font-small mt-2 p-2">{{ 'Necesitamos saber tu localidad.' | translate }}</div>
                                            {% endif %}
                                        {% endblock input_form_alert %}
                                    {% endembed %}
                                </div>
                            </div>
                        {% endif %}

                        <div class="row">
                            <div class="col-sm-6">
                               {# Address Zipcode #}
                                {% embed "snipplets/forms/form-input.tpl" with{type_tel: true, input_for: 'zipcode', input_value: result.zipcode | default(address.zipcode), input_name: 'zipcode', input_id: 'zipcode', input_label_text: 'Código Postal' | translate, input_placeholder: 'ej.: 1429' | translate } %}
                                    {% block input_form_alert %}
                                        {% if result.errors.zipcode %}
                                            <div class="alert alert-danger font-small mt-2 p-2">{{ 'Por favor, ingresá tu código postal.' | translate }}</div>
                                        {% endif %}
                                    {% endblock input_form_alert %}
                                {% endembed %}
                            </div>
                            <div class="col-sm-6">
                               {# Address City #}
                                {% embed "snipplets/forms/form-input.tpl" with{type_text: true, input_for: 'city', input_value: result.city | default(address.city), input_name: 'city', input_id: 'city', input_label_text: 'Ciudad' | translate, input_placeholder: 'ej.: CABA' | translate } %}
                                    {% block input_form_alert %}
                                        {% if result.errors.city %}
                                            <div class="alert alert-danger font-small mt-2 p-2">{{ 'Por favor, ingresá tu ciudad.' | translate }}</div>
                                        {% endif %}
                                    {% endblock input_form_alert %}
                                {% endembed %}
                            </div>
                        </div>

                        {# Address Province #}
                        {% embed "snipplets/forms/form-input.tpl" with{type_text: true, input_for: 'province', input_value: result.province | default(address.province), input_name: 'province', input_id: 'province', input_label_text: 'Provincia' | translate, input_placeholder: 'ej.: Buenos Aires' | translate } %}
                            {% block input_form_alert %}
                                {% if result.errors.province %}
                                    <div class="alert alert-danger font-small mt-2 p-2">{{ 'Necesitamos saber tu provincia.' | translate }}</div>
                                {% endif %}
                            {% endblock input_form_alert %}
                        {% endembed %}
 

                        {# Address Country #}
                        {% embed "snipplets/forms/form-select.tpl" with{select_for: 'country', select_name: 'country', select_id: 'country', select_label_name: 'País' | translate } %}
                            {% block select_options %}{{ country_options }}{% endblock select_options %}
                            {% block input_form_alert %}
                                {% if result.errors.country %}
                                    <div class="alert alert-danger font-small mt-2 p-2">{{ 'Necesitamos saber tu país.' | translate }}</div>
                                {% endif %}
                            {% endblock input_form_alert %}
                        {% endembed %}


                        {# Phone input #}
                        {% embed "snipplets/forms/form-input.tpl" with{type_tel: true, input_for: 'phone', input_value: result.phone | default(address.phone), input_name: 'phone', input_id: 'phone', input_label_text: 'Teléfono de contacto' | translate, input_placeholder: 'ej.: 1123445567' | translate } %}
                            {% block input_form_alert %}
                                {% if result.errors.phone %}
                                    <div class="alert alert-danger font-small mt-2 p-2">{{ 'Necesitamos un teléfono de contacto.' | translate }}</div>
                                {% endif %}
                            {% endblock input_form_alert %}
                        {% endembed %}
                        
                    {% endblock %}
                {% endembed %}
                
                <hr style="margin: 30px 0; border-top: 1px solid #eaeaea;">
                <div class="text-center">
                    <a href="{{ store.customer_addresses_url }}" class="btn-link font-small text-muted">{{ "Cancelar y volver a mis direcciones" | translate }}</a>
                </div>
                
                </div>
            </div>
        </div>
    </div>
</section>