<div class="container mt-5 mb-4 d-flex justify-content-between align-items-center">
    <div>
        <h1 style="font-family: var(--font-headings, sans-serif); font-size: 2.5rem; font-weight: 600; letter-spacing: -0.02em; margin-bottom: 0;">
            {{ 'Orden #{1}' | translate(order.number) }}
        </h1>
        <p style="color: #555; font-size: 1.1rem; margin-top: 5px;">{{ order.date | i18n_date('%d/%m/%Y') }}</p>
    </div>
    <a href="{{ store.customer_orders_url }}" class="btn-link font-small text-uppercase font-weight-bold" style="letter-spacing:0.05em;">{{ "Volver a mis pedidos" | translate }}</a>
</div>

<section class="account-page mb-5">
    <div class="container" data-store="account-order-detail-{{ order.id }}">
    	<div class="row">
            <div class="col-md-4 mb-4 font-small">
                <div style="background: #f8f8f8; padding: 30px; border-radius: 4px;">
                    {% if log_entry %}
                        <h4 style="margin:0 0 10px; font-family:var(--font-headings); font-weight:600; font-size:1.1rem;">{{ 'Estado de envío' | translate }}</h4>
                        <div class="mb-4">{{ log_entry }}</div>
                    {% endif %}
                    
                    <h4 style="margin:0 0 15px; font-family:var(--font-headings); font-weight:600; font-size:1.1rem;">{{ 'Detalles del Pedido' | translate }}</h4>
                    <div style="display:flex; justify-content:space-between; margin-bottom: 10px; border-bottom: 1px solid #eaeaea; padding-bottom:10px;">
                        <span style="color:#666;">{{'Estado' | translate}}</span>
                        <strong>{{ (order.status == 'open'? 'Abierta' : (order.status == 'closed'? 'Cerrada' : 'Cancelada')) | translate }}</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; margin-bottom: 10px; border-bottom: 1px solid #eaeaea; padding-bottom:10px;">
                        <span style="color:#666;">{{'Pago' | translate}}</span>
                        <strong class="{{ order.payment_status }}">{{ (order.payment_status == 'pending'? 'Pendiente' : (order.payment_status == 'authorized'? 'Autorizado' : (order.payment_status == 'paid'? 'Pagado' : (order.payment_status == 'voided'? 'Cancelado' : (order.payment_status == 'refunded'? 'Reintegrado' : 'Abandonado'))))) | translate }} </strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; margin-bottom: 10px; border-bottom: 1px solid #eaeaea; padding-bottom:10px;">
                        <span style="color:#666;">{{'Medio' | translate}}</span>
                        <strong>{{ order.payment_name }}</strong>
                    </div>
                    
                    {% if order.address %}
                        <div style="display:flex; justify-content:space-between; margin-bottom: 10px; border-bottom: 1px solid #eaeaea; padding-bottom:10px;">
                            <span style="color:#666;">{{'Envío' | translate}}</span>
                            <strong>{{ (order.shipping_status == 'fulfilled'? 'Enviado' : 'No enviado') | translate }}</strong>
                        </div>
                        <div class="mt-4"> 
                            <span style="color:#666; font-size: 0.9rem; text-transform:uppercase; letter-spacing:0.05em;">{{ 'Enviado a' | translate }}</span>
                            <span class="d-block mt-2" style="font-size: 1rem; line-height: 1.5; color: #111;">
                                {{ order.address | format_address }}
                            </span>
                        </div>
                    {% endif %}
                </div>
            </div>
            <div class="col-md-8">
                <div class="mb-3 d-none d-md-block" style="border-bottom: 1px solid #eaeaea; padding-bottom: 10px;">
                    <div class="row font-smallest text-uppercase font-weight-bold" style="color: #666; letter-spacing: 0.05em;">
                        <div class="col-6">
                            {{ 'Producto' | translate }}
                        </div>
                        <div class="col-2 text-center">
                            {{ 'Precio' | translate }}
                        </div>
                        <div class="col-2 text-center">
                            {{ 'Cantidad' | translate }}
                        </div>
                        <div class="col-2 text-center">
                            {{ 'Total' | translate }}
                        </div>
                    </div>
                </div>
                <div class="order-detail mb-4">
                    {% for item in order.items %}
                        <div class="order-item py-3" style="border-bottom: 1px solid #fafafa;">
                            <div class="row align-items-center">
                                <div class="col-7 col-md-6">
                                    <div class="row align-items-center">
                                        <div class="col-4 col-md-3 pr-0">
                                            <div class="card-img-square-container" style="border-radius: 4px; overflow:hidden;">
                                                {{ item.featured_image | product_image_url("small") | img_tag(item.featured_image.alt, {class: 'd-block card-img-square'}) }} 
                                            </div>
                                        </div>
                                        <div class="col-8 col-md-9" style="font-size: 1.05rem; font-weight: 500;">
                                            {{ item.name }} <span class="d-inline-block d-md-none text-muted font-small ml-2">x{{ item.quantity }}</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-2 d-none d-md-flex align-self-stretch justify-content-center">
                                    <span class="d-flex align-self-center text-muted font-small">
                                        {{ item.unit_price | money_nocents }}
                                    </span>
                                </div>
                                <div class="col-2 d-none d-md-flex align-self-stretch justify-content-center">
                                    <span class="d-flex align-self-center text-muted font-small">
                                        {{ item.quantity }}
                                    </span>
                                </div>
                                <div class="col-5 col-md-2 d-flex pl-2 pr-0 pt-0 align-self-stretch justify-content-end justify-content-center-md">
                                    <span class="d-flex align-self-center font-weight-bold" style="font-size: 1.1rem;">
                                        {{ item.subtotal | money_nocents }}
                                    </span>
                                </div>
                            </div>
                        </div>
                    {% endfor %}
                </div>
                
                <div class="row justify-content-end mt-4">
                    <div class="col-md-6">
                        <div style="background: #fff; border: 1px solid #eaeaea; padding: 25px; border-radius: 4px;">
                            {% if order.show_shipping_price %}
                                <div class="d-flex justify-content-between mb-3">
                                    <span style="color: #666;">{{ 'Costo de envío ({1})' | translate(order.shipping_name) }}</span>
                                    <span class="font-weight-bold">
                                        {% if order.shipping == 0  %}
                                            {{ 'Gratis' | translate }}
                                        {% else %}
                                            {{ order.shipping | money_nocents }}
                                        {% endif %}
                                    </span>
                                </div>
                            {% else %}
                                <div class="d-flex justify-content-between mb-3">
                                    <span style="color: #666;">{{ 'Costo de envío ({1})' | translate(order.shipping_name) }}</span>
                                    <span class="font-weight-bold">{{ 'A convenir' | translate }}</span>
                                </div>
                            {% endif %}
                            
                            {% if order.discount %}
                                <div class="d-flex justify-content-between mb-3" style="color: var(--text-color-success, #22c55e);">
                                   <span>{{ 'Descuento ({1})' | translate(order.coupon) }}</span>
                                   <span class="font-weight-bold">- {{ order.discount | money_nocents }}</span>
                                </div>
                            {% endif %}
                            
                            {% if order.shipping or order.discount %}
                                <div class="d-flex justify-content-between mb-3">
                                    <span style="color: #666;">{{ 'Subtotal' | translate }}</span>
                                    <span class="font-weight-bold">{{ order.subtotal | money_nocents }}</span>
                                </div>
                            {% endif %}
                            
                            <hr style="margin: 20px 0; border-top: 1px solid #eaeaea;">
                            
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-uppercase font-weight-bold" style="letter-spacing: 0.05em;">{{ 'Total' | translate }}</span>
                                <span style="font-size: 1.8rem; font-weight: 600; color: #111;">{{ order.total | money_nocents }}</span>
                            </div>
                            
                            {% if order.pending %}
                                <a class="btn btn-primary btn-big d-block w-100 mt-4 text-uppercase border-radius-0" style="letter-spacing: 0.05em;" href="{{ order.checkout_url | add_param('ref', 'orders_details') }}" target="_blank" rel="noopener noreferrer">{{ 'Realizar el pago' | translate }}</a>
                            {% endif %}
                        </div>
                    </div>
                </div>
            </div>
    	</div>
    </div>
</section>