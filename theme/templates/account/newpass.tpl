{% set is_account_activation = action == 'account_activation' %}
<style>
	.account-premium-split { display: flex; min-height: 85vh; align-items: stretch; flex-wrap: wrap; margin-top: -15px; }
	.account-media-side { flex: 1 1 45%; position: relative; min-height: 300px; background-color: #111; overflow: hidden; }
	.account-media-side video, .account-media-side .media-bg { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; background-position: center; background-size: cover; }
	.account-form-side { flex: 1 1 55%; display: flex; flex-direction: column; justify-content: center; padding: 8%; background: #ffffff; }
	.premium-form-wrapper { max-width: 480px; width: 100%; margin: 0 auto; }
	.premium-form-title { font-family: var(--font-headings, sans-serif); font-weight: 600; font-size: 2.8rem; color: #111; line-height: 1.2; margin-bottom: 12px; letter-spacing: -0.01em; }
	.premium-form-subtitle { font-family: var(--font-body, sans-serif); font-size: 1.1rem; color: #555; line-height: 1.5; margin-bottom: 40px; }
	@media (max-width: 767px) {
		.account-premium-split { flex-direction: column; min-height: auto; }
		.account-media-side { flex: 0 0 220px; min-height: 220px; }
		.account-form-side { padding: 50px 25px; }
		.premium-form-title { font-size: 2.2rem; }
	}
</style>

<section class="account-premium-split" style="flex-direction: row-reverse;">
	<div class="account-media-side">
		{% if settings.login_split_video_url|trim %}
			<video autoplay muted loop playsinline>
				<source src="{{ settings.login_split_video_url }}" type="video/mp4">
			</video>
		{% elseif "login_split_background.jpg" | has_custom_image %}
			<div class="media-bg" style="background-image: url('{{ "login_split_background.jpg" | static_url | settings_image_url("large") }}');"></div>
		{% else %}
			<div class="media-bg" style="background-image: url('https://d3ugyf2ht6aenh.cloudfront.net/stores/003/996/535/themes/zestful/1-slide-1736630048600-2410298642-a8ceb466139cdedb700f135b34a6aa791736630049.webp'); transform: scaleX(-1);"></div>
		{% endif %}
		<div style="position:absolute;inset:0;background:rgba(0,0,0,0.15);"></div>
	</div>
	
	<div class="account-form-side">
		<div class="premium-form-wrapper">
			<h1 class="premium-form-title">
				{{ is_account_activation ? 'Vamos a activar tu cuenta.' : 'Elegí tu nueva clave.' }}
			</h1>
			<p class="premium-form-subtitle">
                {% if is_account_activation %}
                    Es el último paso para convertirte en miembro y aprovechar todos los beneficios.
                {% else %}
                    Bienvenido de vuelta. Definí una contraseña segura para retomar el control de tu espacio.
                {% endif %}
			</p>

            {% if link_expired %}
                <div class="alert alert-warning p-4">
                    {% set contact_links = store.whatsapp or store.phone or store.email %}
                    {% if is_account_activation %}
                        <div class="font-weight-bold mb-2">{{ 'El link para activar tu cuenta expiró' | translate }}</div>
                        <p class="mb-3">{{ 'Contactanos para que te enviemos uno nuevo y lo solucionemos rápido.' | translate }}</p>
                        {% if contact_links %}
                            {% include "snipplets/contact-links.tpl" with {phone_and_mail_only: true} %}
                        {% endif %}
                    {% else %}
                        <div class="font-weight-bold mb-2">{{ 'El link expiró' | translate }}</div>
                        <p class="mb-3">{{ 'Podemos enviarte un email nuevo en un click.' | translate }}</p>
                        <a href="{{ store.customer_reset_password_url }}" class="btn btn-secondary btn-block text-uppercase">{{ 'Solicitar de nuevo' | translate }}</a>
                    {% endif %}
                </div>
            {% else %}
                {% if failure %}
                    <div class="alert alert-danger">{{ 'Las contraseñas no coinciden. Por favor, revisalas.' | translate }}</div>
                {% endif %}

                {% embed "snipplets/forms/form.tpl" with{form_id: 'newpass-form', submit_custom_class: 'btn-primary btn-big btn-block text-uppercase border-radius-0 mt-3', submit_text: (customer.password ? 'Confirmar contraseña' : 'Activar cuenta')  | translate } %}
                    {% block form_body %}
                        {% embed "snipplets/forms/form-input.tpl" with{type_password: true, input_for: 'password', input_name: 'password', input_id: 'password', input_label_text: 'Escribí tu nueva contraseña' | translate } %}
                        {% endembed %}
                        {% embed "snipplets/forms/form-input.tpl" with{type_password: true, input_for: 'password_confirm', input_name: 'password_confirm', input_id: 'password_confirm', input_label_text: 'Repetila para confirmarla' | translate } %}
                        {% endembed %}
                    {% endblock %}
                {% endembed %}
            {% endif %}
		</div>
	</div>
</section>