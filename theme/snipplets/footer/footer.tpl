{% set has_social_network = store.facebook or store.twitter or store.pinterest or store.instagram or store.tiktok or store.youtube %}
{% set has_footer_contact_info = (store.whatsapp or store.phone or store.email or store.address or store.blog) and settings.footer_contact_show %}          

{% set has_footer_menu = settings.footer_menu and settings.footer_menu_show %}
{% set has_footer_menu_secondary = settings.footer_menu_secondary and settings.footer_menu_secondary_show %}
{% set has_footer_about = settings.footer_about_show and (settings.footer_about_title or settings.footer_about_description) %}
{% set has_payment_logos = settings.payments %}
{% set has_shipping_logos = settings.shipping %}
{% set has_shipping_payment_logos = has_payment_logos or has_shipping_logos %}
{% set has_languages = languages | length > 1 and settings.languages_footer %}
{% set show_footer_logo = "footer_logo.jpg" | has_custom_image %}
{% set has_seal_logos = store.afip or ebit or settings.custom_seal_code or ("seal_img.jpg" | has_custom_image) %}
{% set show_right_md_col_logo = show_footer_logo and not settings.news_show %}
{% set has_right_md_col_content = (settings.news_show or has_footer_contact_info or has_shipping_payment_logos or has_languages or has_social_network) or show_right_md_col_logo %}
{% set vertical_spacing_classes = 'mb-4 pb-2 mb-md-5 pb-md-0' %}
{% set password_page = template == 'password' %}

<footer class="js-footer js-hide-footer-while-scrolling footer container-fluid {% if settings.footer_colors %}footer-colors{% endif %} display-when-content-ready" data-store="footer">
	<div class="row{% if password_page %} justify-content-center text-md-center{% endif %}">

		{# Foot Nav #}

		{% if has_footer_menu and not password_page %}
			<div class="{% if has_right_md_col_content %}col-md-6{% else %}col-md-12{% endif %} {{ vertical_spacing_classes }} pb-md-0 pr-md-5">
				{% include "snipplets/navigation/navigation-foot.tpl" %}
			</div>
		{% endif %}

		{% if has_right_md_col_content %}
			<div class="{% if password_page %}col-md-12{% else %}col-md-6 {{ vertical_spacing_classes }} pr-0 {% if has_footer_menu %}pl-md-5 pr-md-3{% else %}pr-md-5{% endif %}{% endif %}">
				<div class="js-footer-col-sticky col-sticky-md">
					{% if show_right_md_col_logo %}
						<div class="{{ vertical_spacing_classes }}">
							<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ 'footer_logo.jpg' | static_url('original') }}" alt="{{ store.name }}" title="{{ store.name }}" class="img-fluid lazyload">
						</div>
					{% endif %}
					{% if settings.news_show and not password_page %}
						{% include 'snipplets/newsletter.tpl' %}
					{% endif %}
					{% if has_social_network %}
						<div class="list-horizontal mb-4 pb-md-3 {% if not has_footer_contact_info %}pb-3{% else %}pb-1{% endif %}">
							{% include "snipplets/social/social-links.tpl" %}
						</div>
					{% endif %}

					<div class="divider d-md-none mb-4 pb-1 mr-3 mr-md-0"></div>

					{# Contact info #}
					
					{% if has_footer_contact_info and not password_page %}
						<div class="mb-4 pb-3 pr-3 pr-md-0">
							{% include "snipplets/contact-links.tpl" with {footer: true} %}
						</div>
					{% endif %}

					{# Language selector #}

					{% if has_languages and not password_page %}
						<div class="mb-4">
							<a href="#" data-toggle="#languages" class="js-modal-open btn-link text-transform">
								{{ "Idiomas y monedas" | translate }}
							</a>
							{% embed "snipplets/modal.tpl" with{modal_id: 'languages', modal_class: 'bottom modal-centered-small', modal_position: 'center', modal_transition: 'slide', modal_header_title: true, modal_footer: false, modal_width: 'centered', modal_zindex_top: true} %}
								{% block modal_head %}
									{{ 'Idiomas y monedas' | translate }}
								{% endblock %}
								{% block modal_body %}
									{% include "snipplets/navigation/navigation-lang.tpl" %}
								{% endblock %}
							{% endembed %}
						</div>
					{% endif %}

					{% if has_shipping_payment_logos %}

						<div class="footer-payments-shipping-logos pr-3 pr-md-0">

							{# Logos Payments and Shipping #}

							{% if has_payment_logos %}
								{{ component('payment-shipping-logos', {'type' : 'payments', logo_img_classes : 'card-img card-img-small mr-1'}) }}
							{% endif %}

							{% if has_shipping_logos %}
								{{ component('payment-shipping-logos', {'type' : 'shipping', logo_img_classes : 'card-img card-img-small mr-1'}) }}
							{% endif %}
						</div>
					{% endif %}
				</div>
			</div>
		{% endif %}
	{% if has_footer_menu %}
	</div>
	{% else %}
	<div class="col-md-6 pl-md-5">
	{% endif %}
		{% if show_footer_logo and not show_right_md_col_logo %}
			<div class="{{ vertical_spacing_classes }}">
				<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ 'footer_logo.jpg' | static_url('original') }}" alt="{{ store.name }}" title="{{ store.name }}" class="img-fluid lazyload">
			</div>
		{% endif %}
		{# Foot Nav Secondary #}
		{% if has_footer_menu_secondary %}
			<div class="{{ vertical_spacing_classes }}">
				{% include "snipplets/navigation/navigation-foot-secondary.tpl" %}
			</div>
		{% endif %}
	{% if not has_footer_menu %}
	</div>
	{% endif %}
	
	{# AFIP - EBIT - Custom Seal #}
	{% if has_seal_logos %}
		<div class="text-left text-md-center {{ vertical_spacing_classes }}">

			{% if store.afip or ebit %}
				{% if store.afip %}
					<span class="footer-logo afip seal-afip mr-3 mb-3">
						{{ store.afip | raw }}
					</span>
				{% endif %}
				{% if ebit %}
					<span class="footer-logo ebit seal-ebit mr-3 mb-3">
						{{ ebit }}
					</span>
				{% endif %}
			{% endif %}
			{% if "seal_img.jpg" | has_custom_image or settings.custom_seal_code %}
				{% if "seal_img.jpg" | has_custom_image %}
					<span class="footer-logo custom-seal mr-3 mb-3">
						{% if settings.seal_url != '' %}
							<a href="{{ settings.seal_url | setting_url }}" target="_blank" rel="noopener noreferrer">
						{% endif %}
							<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ "seal_img.jpg" | static_url }}" class="custom-seal-img lazyload" alt="{{ 'Sello de' | translate }} {{ store.name }}"/>
						{% if settings.seal_url != '' %}
							</a>
						{% endif %}
					</span>
				{% endif %}
				{% if settings.custom_seal_code %}
					<span class="custom-seal custom-seal-code mr-3 mb-3">
						{{ settings.custom_seal_code | raw }}
					</span>
				{% endif %}
			{% endif %}
		</div>
	{% endif %}
	
	<div class="text-left text-md-center">
		{#
			La leyenda que aparece debajo de esta linea de código debe mantenerse
			con las mismas palabras y con su apropiado link a Tienda Nube;
			como especifican nuestros términos de uso: http://www.tiendanube.com/terminos-de-uso .
			Si quieres puedes modificar el estilo y posición de la leyenda para que se adapte a
			tu sitio. Pero debe mantenerse visible para los visitantes y con el link funcional.
			Os créditos que aparece debaixo da linha de código deverá ser mantida com as mesmas
			palavras e com seu link para Nuvem Shop; como especificam nossos Termos de Uso:
			http://www.nuvemshop.com.br/termos-de-uso. Se você quiser poderá alterar o estilo
			e a posição dos créditos para que ele se adque ao seu site. Porém você precisa
			manter visivél e com um link funcionando.
			#}

			{{ new_powered_by_link }}

			<div class="my-3 my-md-2 font-small">
				{{ "Copyright {1} - {2}. Todos los derechos reservados." | translate( (store.business_name ? store.business_name : store.name) ~ (store.business_id ? ' - ' ~ store.business_id : ''), "now" | date('Y') ) }}
			</div>

			{{ component('claim-info', {
				container_classes: 'font-small',
				divider_classes: "mx-1",
				text_classes: {text_consumer_defense: 'd-inline-block mb-1'},
				link_classes: {
					link_consumer_defense: "btn-link font-small",
					link_order_cancellation: "btn-link font-small",
				},
			}) 
		}}
	</div>
</footer>