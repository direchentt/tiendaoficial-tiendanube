{% embed "snipplets/page-header.tpl" %}
    {% block page_header_text %}{{ "Mis direcciones" | translate }}{% endblock page_header_text %}
{% endembed %}

<section class="account-page mb-4">
    <div class="container">
        <div class="row">      
            {% for address in customer.addresses %}

                {# User addresses listed - Main Address #}

                {% if loop.first %}
                    <div class="col-md-4">
                        <h4 class="mb-3">{{ 'Principal' | translate }}</h4>

                {# User addresses listed - Other Addresses #}

                {% elseif loop.index == 2 %}
                    <div class="col-md-8">
                        <h4 class="mb-3">{{ 'Otras direcciones' | translate }}</h4>
                        <div class="row">

                {% endif %}
                        {% if not loop.first %}
                            <div class="col-md-6">
                                <div class="card p-3">
                        {% endif %}
                                    <div class="mb-2">{{ address.name }} {{ 'Editar' | translate | a_tag(store.customer_address_url(address), '', 'btn-link font-small float-right') }}</div>
                                    <p class="font-small mb-2">{{ address | format_address }}</p>
                        {% if not loop.first %}
                                </div>
                            </div>
                        {% endif %}
                {% if not loop.first and loop.last %}
                        </div>
                {% endif %}
                {% if loop.first %} 
                        <a class="btn-link font-small mb-4 pb-2 d-inline-block" href="{{ store.customer_new_address_url }}"> {{ 'Agregar una nueva dirección' | translate }}</a>
                    </div>
                {% elseif loop.last %}
                    </div>
                {% endif %}
            {% endfor %}
        </div>
    </div>
</section>