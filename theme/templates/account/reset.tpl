<style>
	.account-premium-split { display: flex; min-height: 85vh; align-items: stretch; flex-wrap: wrap; margin-top: -15px; }
	.account-media-side { flex: 1 1 45%; position: relative; min-height: 300px; background-color: #111; overflow: hidden; }
	.account-media-side video, .account-media-side .media-bg { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; background-position: center; background-size: cover; }
	.account-form-side { flex: 1 1 55%; display: flex; flex-direction: column; justify-content: center; padding: 8%; background: #ffffff; }
	.premium-form-wrapper { max-width: 480px; width: 100%; margin: 0 auto; }
	.premium-form-title { font-family: var(--font-headings, sans-serif); font-weight: 600; font-size: 2.8rem; color: #111; line-height: 1.1; margin-bottom: 12px; letter-spacing: -0.01em; }
	.premium-form-subtitle { font-family: var(--font-body, sans-serif); font-size: 1.1rem; color: #555; line-height: 1.5; margin-bottom: 45px; }
	@media (max-width: 767px) {
		.account-premium-split { flex-direction: column; min-height: auto; }
		.account-media-side { flex: 0 0 220px; min-height: 220px; }
		.account-form-side { padding: 50px 25px; }
		.premium-form-title { font-size: 2.2rem; }
	}
</style>

<section class="account-premium-split">
	<div class="account-media-side">
		{% if settings.login_split_video_url|trim %}
			<video autoplay muted loop playsinline>
				<source src="{{ settings.login_split_video_url }}" type="video/mp4">
			</video>
		{% elseif "login_split_background.jpg" | has_custom_image %}
			<div class="media-bg" style="background-image: url('{{ "login_split_background.jpg" | static_url | settings_image_url("large") }}');"></div>
		{% else %}
			<div class="media-bg" style="background-image: url('https://d3ugyf2ht6aenh.cloudfront.net/stores/003/996/535/themes/zestful/1-slide-1736630048600-2410298642-a8ceb466139cdedb700f135b34a6aa791736630049.webp');"></div>
		{% endif %}
		<div style="position:absolute;inset:0;background:rgba(0,0,0,0.15);"></div>
	</div>
	
	<div class="account-form-side">
		<div class="premium-form-wrapper">
			<h1 class="premium-form-title">
				Recuperar acceso.
			</h1>
			<p class="premium-form-subtitle">
				Ingresá el email con el que te registraste y te enviaremos un link seguro para que puedas restablecer tu contraseña en segundos.
			</p>

            {% if success %}
                <div class="alert alert-success mt-3 mb-4">{{ '¡Listo! Te enviamos un email a {1}' | translate(email) }}</div>
            {% endif %}

            {% embed "snipplets/forms/form.tpl" with{form_id: 'resetpass-form', submit_custom_class: 'btn-primary btn-big btn-block text-uppercase border-radius-0 mt-2', submit_text: 'Enviar email' | translate } %}
                {% block form_body %}

                    {% embed "snipplets/forms/form-input.tpl" with{type_email: true, input_for: 'email', input_value: email, input_name: 'email', input_id: 'email', input_label_text: 'Tu Email' | translate, input_placeholder: 'ej.: hola@tudominio.com' | translate } %}
                        {% block input_label_text %}{{ 'Tu Email' | translate }}{% endblock input_label_text %}
                        {% block input_form_alert %}
                            {% if failure %}
                                <div class="alert alert-danger font-small mt-2 p-2">{{ 'No encontramos ninguna cuenta registrada con este email. Chequeá que esté bien escrito.' | translate }}</div>
                            {% endif %}
                        {% endblock input_form_alert %}
                    {% endembed %}
                    
                {% endblock %}
            {% endembed %}
            
            <div class="mt-4 text-center">
                <a href="{{ store.customer_login_url }}" class="btn-link font-small">Volver al login</a>
            </div>
		</div>
	</div>
</section>