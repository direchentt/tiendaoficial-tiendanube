{% if product_detail %}
	{% set cart_zipcode = false %}
{% else %}
	{% set cart_zipcode = cart.shipping_zipcode %}
{% endif %}

<div data-store="shipping-calculator">
	<div class="js-shipping-calculator-head shipping-calculator-head position-relative transition-soft {% if cart_zipcode %}with-zip{% else %}with-form{% endif %}">
		<div class="js-shipping-calculator-with-zipcode {% if cart_zipcode %}js-cart-saved-zipcode transition-up-active{% endif %} mt-1 w-100 transition-up position-absolute">
			<div class="font-small">
				<span>
					<span>{{ "Entregas para el CP:" | translate }}</span>
					<strong class="js-shipping-calculator-current-zip">{{ cart_zipcode }}</strong>
				</span>
				<a class="js-shipping-calculator-change-zipcode btn btn-link font-small ml-2" href="#">{{ "Cambiar CP" | translate }}</a>
			</div>
		</div>

		<div class="js-shipping-calculator-form shipping-calculator-form transition-up position-absolute w-100">

			{# Shipping calculator input #}

			{% embed "snipplets/forms/form-input.tpl" with{type_tel: true, input_value: cart_zipcode, input_name: 'zipcode', input_custom_class: 'js-shipping-input d-block form-control-line', input_placeholder: "Tu código postal" | translate, input_aria_label: 'Tu código postal' | translate, input_label: false, input_append_content: true, input_group_custom_class: 'mb-3'} %}
				{% block input_prepend_content %}
					<div class="font-weight-bold mb-1">						
						{{ "Medios de envío" | translate }}
					</div>
					<div class="position-relative">
				{% endblock input_prepend_content %}
				{% block input_append_content %}
							<div class="js-calculate-shipping btn form-control-btn form-control-line-btn mt-2 pt-1" aria-label="{{ 'Calcular envío' | translate }}">	
								<span class="js-calculate-shipping-wording d-inline-block">
									{{ 'Calcular' | translate }}
								</span>
								<span class="loading ml-1" style="display: none;">
									<svg class="icon-inline icon-spin icon-md ml-2"><use xlink:href="#spinner-third"/></svg>
								</span>
							</div>
					</div>
				{% endblock input_append_content %}
				{% block input_form_alert %}
				{% set zipcode_help_countries = ['BR', 'AR', 'MX'] %}
				{% if store.country in zipcode_help_countries %}
					{% set zipcode_help_ar = 'https://www.correoargentino.com.ar/formularios/cpa' %}
					{% set zipcode_help_br = 'http://www.buscacep.correios.com.br/sistemas/buscacep/' %}
					{% set zipcode_help_mx = 'https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/Descarga.aspx' %}
					<a class="btn-link font-small my-2 d-inline-block {% if product_detail %} js-shipping-zipcode-help {% endif %}" href="{% if store.country == 'AR' %}{{ zipcode_help_ar }}{% elseif store.country == 'BR' %}{{ zipcode_help_br }}{% elseif store.country == 'MX' %}{{ zipcode_help_mx }}{% endif %}" target="_blank" rel="noopener noreferrer">{{ "No sé mi código postal" | translate }}</a>
				{% endif %}
				<div class="js-ship-calculator-error invalid-zipcode alert alert-danger mt-1" style="display: none;">
					
					{# Specific error message considering if store has multiple languages #}

					{% for language in languages %}
						{% if language.active %}
							{% if languages | length > 1 %}
								{% set wrong_zipcode_wording = ' para ' | translate ~ language.country_name ~ '. Podés intentar con otro o' | translate %}
							{% else %}
								{% set wrong_zipcode_wording = '. ¿Está bien escrito?' | translate %}
							{% endif %}
							{{ "No encontramos este código postal{1}" | translate(wrong_zipcode_wording) }}

							{% if languages | length > 1 %}
								<a href="#" data-toggle="#{% if product_detail %}product{% else %}cart{% endif %}-shipping-country" class="js-modal-open js-open-over-modal btn-link">
									{{ 'cambiar tu país de entrega' | translate }}
								</a>
							{% endif %}
						{% endif %}
					{% endfor %}
				</div>
				<div class="js-ship-calculator-error js-ship-calculator-common-error alert alert-danger" style="display: none;">{{ "Ocurrió un error al calcular el envío. Por favor intentá de nuevo en unos segundos." | translate }}</div>
				<div class="js-ship-calculator-error js-ship-calculator-external-error alert alert-danger" style="display: none;">{{ "El calculo falló por un problema con el medio de envío. Por favor intentá de nuevo en unos segundos." | translate }}</div>
				{% endblock input_form_alert %}
				{% block input_add_on %}
					{% if shipping_calculator_variant %}
						<input type="hidden" name="variant_id" id="shipping-variant-id" value="{{ shipping_calculator_variant.id }}">
					{% endif %}
				{% endblock input_add_on %}
			{% endembed %}
		</div>
	</div>
	<div class="js-shipping-calculator-spinner pt-3 pb-4" style="display: none;">
		{% include "snipplets/placeholders/shipping-placeholder.tpl"%}
	</div>
	<div class="js-shipping-calculator-response transition-soft {% if product_detail %}list {% else %} radio-buttons-group{% endif %}" style="display: none;"></div>
</div>

{# Shipping country modal #}

{% if languages | length > 1 %}

	{% if product_detail %}
		{% set country_modal_id = 'product-shipping-country' %}
	{% else %}
		{% set country_modal_id = 'cart-shipping-country' %}
	{% endif %}

	{% embed "snipplets/modal.tpl" with{modal_id: country_modal_id, modal_class: 'bottom modal-centered-small js-modal-shipping-country', modal_position: 'center', modal_position_desktop: 'bottom', modal_transition: 'slide', modal_header_title: true, modal_footer: true, modal_width: 'centered', modal_zindex_top: true, modal_mobile_full_screen: false} %}
		{% block modal_head %}
			{{ 'País de entrega' | translate }}
		{% endblock %}
		{% block modal_body %}
			{% embed "snipplets/forms/form-select.tpl" with{select_label: true, select_label_name: 'País donde entregaremos tu compra' | translate, select_aria_label: 'País donde entregaremos tu compra' | translate, select_custom_class: 'js-country-select' } %}
				{% block select_options %}
					{% for language in languages %}
						<option value="{{ language.country }}" data-country-url="{{ language.url }}" {% if language.active %}selected{% endif %}>{{ language.country_name }}</option>
					{% endfor %}
				{% endblock select_options%}
			{% endembed %}
		{% endblock %}
		{% block modal_foot %}
			<a href="#" class="js-save-shipping-country btn btn-primary d-inline-block">{{ 'Aplicar' | translate }}</a>
		{% endblock %}
	{% endembed %}
{% endif %}
