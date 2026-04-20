<div class="container mt-5 mb-4">
    <h1 style="font-family: var(--font-headings, sans-serif); font-size: 3rem; font-weight: 600; letter-spacing: -0.02em; margin-bottom: 0;">
        Hola, {{ customer.name | split(' ') | first }}.
    </h1>
    <p style="color: #555; font-size: 1.1rem; margin-top: 5px;">Este es tu espacio personal.</p>
    <hr style="margin-top: 30px; margin-bottom: 40px; border-top: 1px solid #eaeaea;">
</div>

<section class="account-page mb-5">
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-5">
                <div style="background: #f8f8f8; padding: 30px; border-radius: 4px;">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4 style="margin:0; font-family:var(--font-headings); font-weight:600; font-size:1.2rem;">{{ 'Tus Datos' | translate }}</h4>
                        <a href="{{ store.customer_info_url }}" class="font-small font-weight-bold text-uppercase" style="color:#111; letter-spacing:0.05em;">{{ 'Editar' | translate }}</a>
                    </div>
                    <p class="font-small" style="color:#555; line-height:1.6; margin-bottom: 30px;">
                        <strong class="d-block" style="color:#111; font-size:1rem; margin-bottom:5px;">{{customer.name}}</strong>
                        {{customer.email}}<br>
                        {% if customer.phone %}{{customer.phone}}<br>{% endif %}
                        {% if customer.cpf_cnpj %}{{ customer.cpf_cnpj | format_id_number(customer.billing_country) }}<br>{% endif %}
                        {% if customer.business_name %}{{ customer.business_name }}<br>{% endif %}
                        {% if customer.trade_name %}{{ customer.trade_name }}<br>{% endif %}
                    </p>

                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4 style="margin:0; font-family:var(--font-headings); font-weight:600; font-size:1.2rem;">{{ 'Dirección' | translate }}</h4>
                        {% if customer.default_address %}
                            <a href="{{ store.customer_address_url(customer.default_address) }}" class="font-small font-weight-bold text-uppercase" style="color:#111; letter-spacing:0.05em;">{{ 'Editar' | translate }}</a>
                        {% endif %}
                    </div>
                    {% if customer.default_address %}
                        <p class="font-small" style="color:#555; line-height:1.6; margin-bottom: 10px;">
                            {{ customer.default_address | format_address_short }}
                        </p>
                        <div class="mb-4">
                            <a href="{{ store.customer_addresses_url }}" class="font-small text-underline" style="color:#555;">{{ 'Ver todas las direcciones' | translate }}</a>
                        </div>
                    {% else %}
                        <p class="font-small mb-4 text-muted">{{ 'Aún no tenés direcciones guardadas.' | translate }}</p>
                        <a href="{{ store.customer_new_address_url }}" class="btn-link font-small font-weight-bold">{{ 'Agregar dirección' | translate }}</a>
                    {% endif %}

                    <div class="mt-5 pt-4" style="border-top:1px solid #eaeaea;">
                        <a href="{{ store.customer_logout_url }}" class="btn btn-secondary btn-block text-uppercase border-radius-0" style="letter-spacing:0.05em;">{{ "Cerrar sesión" | translate }}</a>
                    </div>
                </div>
            </div>

            <div class="col-md-8">
                <h3 style="font-family: var(--font-headings); font-size: 1.8rem; font-weight: 600; margin-bottom: 25px; letter-spacing: -0.01em;">{{ 'Mis Pedidos' | translate }}</h3>
                <div class="row" data-store="account-orders">
                    {% if customer.orders %}
                        {% if customer.ordersCount > 50 %}
                            <div class="col-12 h4 mb-4">
                                {{ 'Últimas 50 órdenes' | translate }}
                            </div>
                        {% endif %}
                        {% for order in customer.orders %}
                            {% set add_checkout_link = order.pending %}
                            <div class="col-12 mb-4" data-store="account-order-item-{{ order.id }}">
                                <div style="border: 1px solid #eaeaea; padding: 25px; border-radius: 4px; background: #fff;">
                                    <div class="row align-items-center mb-3">
                                        <div class="col-sm-6">
                                            <a class="font-weight-bold font-body" style="font-size: 1.2rem; color: #111;" href="{{ store.customer_order_url(order) }}">{{'Orden' | translate}} #{{order.number}}</a>
                                        </div>
                                        <div class="col-sm-6 text-sm-right mt-2 mt-sm-0 text-muted font-small">
                                            {{ order.date | i18n_date('%d/%m/%Y') }}
                                        </div>
                                    </div>
                                    <hr style="border-top: 1px solid #f2f2f2; margin-bottom: 20px;">
                                    
                                    <div class="row">
                                        <div class="col-sm-8 mb-3 mb-sm-0">
                                            <div class="d-flex mb-2 font-small">
                                                <div style="width: 80px; color:#666;">{{'Pago' | translate}}:</div>
                                                <div class="font-weight-bold {{ order.payment_status }}">{{ (order.payment_status == 'pending'? 'Pendiente' : (order.payment_status == 'authorized'? 'Autorizado' : (order.payment_status == 'paid'? 'Pagado' : (order.payment_status == 'voided'? 'Cancelado' : (order.payment_status == 'refunded'? 'Reintegrado' : 'Abandonado'))))) | translate }}</div>
                                            </div>
                                            <div class="d-flex mb-3 font-small">
                                                <div style="width: 80px; color:#666;">{{'Envío' | translate}}:</div>
                                                <div class="font-weight-bold">{{ (order.shipping_status == 'fulfilled'? 'Enviado' : 'No enviado') | translate }}</div>
                                            </div>
                                            <div style="font-size: 1.4rem; font-weight: 600; color: #111; margin-bottom: 10px;">
                                                {{ order.total | money_nocents }}
                                            </div>
                                            <a class="btn-link font-small font-weight-bold text-uppercase" style="letter-spacing:0.05em;" href="{{ store.customer_order_url(order) }}">{{'Ver detalle' | translate}}</a>
                                        </div>

                                        <div class="col-sm-4 text-sm-right">
                                            {% if add_checkout_link %}
                                                <a class="btn btn-primary text-uppercase border-radius-0 mt-2 w-100" href="{{ order.checkout_url | add_param('ref', 'orders_list') }}" target="_blank" rel="noopener noreferrer">{{'Pagar' | translate}}</a>
                                            {% elseif order.order_status_url != null %}
                                                <a class="btn btn-secondary text-uppercase border-radius-0 mt-2 w-100" href="{{ order.order_status_url | add_param('ref', 'orders_list') }}" target="_blank" rel="noopener noreferrer">{% if 'Correios' in order.shipping_name %}{{'Entrega' | translate}}{% else %}{{'Seguimiento' | translate}}{% endif %}</a>
                                            {% endif %}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        {% endfor %}
                    {% else %}
                    <div class="col-12 text-center" style="padding: 10% 20px;">
                        <svg class="icon-inline mb-4" style="width: 48px; height: 48px; opacity: 0.1;"><use xlink:href="#brand-utility-cart"/></svg>
                        <h3 style="font-family: var(--font-headings); font-weight: 600; font-size: 1.5rem; letter-spacing: -0.01em; margin-bottom: 10px;">{{ 'Aún no tenés pedidos.' | translate }}</h3>
                        <p class="mb-4" style="color: #666; font-size: 1.05rem;">Todavía no sumaste ninguna nueva historia a tu colección.<br>Descubrí lo que tenemos para vos.</p>
                        <a href="{{ store.url }}" class="btn btn-primary btn-big text-uppercase border-radius-0 px-5" style="letter-spacing:0.05em;">{{ 'Explorar la colección' | translate }}</a>
                    </div>
                    {% endif %}
                </div>
            </div>
        </div>
    </div>
</section>
