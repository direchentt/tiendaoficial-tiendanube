<div class="container mt-5 mb-4 text-center">
    <h1 style="font-family: var(--font-headings, sans-serif); font-size: 2.5rem; font-weight: 600; letter-spacing: -0.02em; margin-bottom: 0;">
        {{ "Mis direcciones" | translate }}
    </h1>
    <p style="color: #555; font-size: 1.1rem; margin-top: 5px;">Tus puntos de entrega guardados.</p>
</div>

<section class="account-page mb-5">
    <div class="container">
        <div class="row justify-content-center">      
            <div class="col-md-10 col-lg-8">
                <div class="row">
                    {% for address in customer.addresses %}
                        <div class="col-md-6 mb-4">
                            <div style="background: #fff; padding: 25px; border-radius: 4px; border: 1px solid #eaeaea; height: 100%;">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h4 style="margin:0; font-family:var(--font-headings); font-weight:600; font-size:1.1rem;">
                                        {% if loop.first %}{{ 'Principal' | translate }}{% else %}{{ address.name | default('Otra dirección') }}{% endif %}
                                    </h4>
                                    <a href="{{ store.customer_address_url(address) }}" class="font-small font-weight-bold text-uppercase" style="color:#111; letter-spacing:0.05em;">{{ 'Editar' | translate }}</a>
                                </div>
                                <p class="font-small" style="color:#555; line-height:1.6; margin-bottom: 0;">
                                    {{ address | format_address }}
                                </p>
                            </div>
                        </div>
                    {% else %}
                        <div class="col-12 text-center" style="padding: 5% 20px;">
                            <p class="mb-4 text-muted">{{ 'Aún no tenés direcciones guardadas.' | translate }}</p>
                        </div>
                    {% endfor %}
                </div>
                
                <div class="text-center mt-3 border-top pt-4" style="border-color: #eaeaea !important;">
                    <a href="{{ store.customer_new_address_url }}" class="btn btn-primary btn-big text-uppercase border-radius-0 px-4" style="letter-spacing:0.05em;">{{ 'Agregar nueva dirección' | translate }}</a>
                    <div class="mt-4">
                        <a href="{{ store.customer_orders_url }}" class="btn-link font-small text-muted">{{ "Volver a mi cuenta" | translate }}</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>