{% set newsletter_contact_error = contact.type == 'newsletter' and not contact.success %}

<section class="section-newsletter-home {% if settings.home_news_colors %}section-newsletter-home-colors{% endif %} position-relative overflow-none" data-store="home-newsletter">
	<div class="container-fluid newsletter-content">
		<div class="row align-items-end">
			<div class="col-md">
				<h2 class="h4-huge h1-huge-md mb-2	mb-md-0">{{ "Newsletter" | translate }}</h2>
				{% if settings.home_news_text %}
					<p class="newsletter-description mb-3">{{ settings.home_news_text }}</p>
				{% endif %}
			</div>
			<div class="col-md-auto">
				<div class="js-newsletter newsletter mt-md-1 mb-md-3 ml-md-auto pb-md-1">
					<form method="post" action="/winnie-pooh" onsubmit="this.setAttribute('action', '');" data-store="home-newsletter-form">
						<div class="input-append">
							{% embed "snipplets/forms/form-input.tpl" with{input_for: 'email', type_email: true, input_name: 'email', input_id: 'email', input_placeholder: 'Email' | translate, input_custom_class: 'form-control-line font-md-big', input_group_custom_class: "mb-0",  input_aria_label: 'Email' | translate } %}
							{% endembed %}
							<div class="winnie-pooh" style="display: none;">
								<label for="winnie-pooh-newsletter">{{ "No completar este campo" | translate }}</label>
								<input id="winnie-pooh-newsletter" type="text" name="winnie-pooh"/>
							</div>
							<input type="hidden" name="name" value="{{ 'Sin nombre' | translate }}" />
							<input type="hidden" name="message" value="{{ 'Pedido de inscripción a newsletter' | translate }}" />
							<input type="hidden" name="type" value="newsletter" />
							<input type="submit" name="contact" class="btn btn-link form-control-btn form-control-line-btn font-md-big" value="{{ 'Enviar' | translate }}" />
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
			</div>
		</div>
	</div>
	{% if "home_news_image.jpg" | has_custom_image %}
        <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "home_news_image.jpg" | static_url | settings_image_url('large') }} 480w, {{ "home_news_image.jpg" | static_url | settings_image_url('huge') }} 640w, {{ "home_news_image.jpg" | static_url | settings_image_url('original') }} 1024w, {{ "home_news_image.jpg" | static_url | settings_image_url('1080p') }} 1920w' class='lazyload background-home-image {% if "home_news_image_mobile.jpg" | has_custom_image %}d-none d-md-block{% endif %}'/>
    {% endif %}
    {% if "home_news_image_mobile.jpg" | has_custom_image %}
        <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "home_news_image_mobile.jpg" | static_url | settings_image_url('large') }} 480w, {{ "home_news_image_mobile.jpg" | static_url | settings_image_url('huge') }} 640w, {{ "home_news_image_mobile.jpg" | static_url | settings_image_url('original') }} 1024w' class="lazyload background-home-image {% if "home_news_image.jpg" | has_custom_image %}d-block d-md-none{% endif %}"/>
    {% endif %}
</section>
