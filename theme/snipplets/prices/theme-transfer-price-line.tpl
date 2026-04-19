{# Precio con descuento por medio de pago: montos enteros (| money_nocents) sin depender del componente TN que a veces muestra decimales. #}
{% if visible and product.display_price %}
	{% if product.maxPaymentDiscount is defined and product.maxPaymentDiscount.value > 0 %}
		{% set pct = product.maxPaymentDiscount.value %}
		{% set v = product.selected_or_first_available_variant %}
		{# TN: a veces price_number no viene en variante; caer a producto o precio mostrado. #}
		{% set pn = attribute(v, 'price_number') %}
		{% if pn is null or pn == '' %}
			{% set pn = attribute(product, 'price_number') %}
		{% endif %}
		{% if pn is null or pn == '' %}
			{% set pn = product.price %}
		{% endif %}
		{% set tr = null %}
		{% if pn is not null and pn != '' %}
			{% set tr = (pn * (100 - pct) / 100)|round %}
		{% endif %}
		{% set _transfer_suffix = product.maxPaymentDiscount.paymentProviderName
			? ('pagando con' | translate) ~ ' ' ~ product.maxPaymentDiscount.paymentProviderName
			: ('con transferencia' | translate) %}
		<div class="{{ wrapper_class }} js-theme-transfer-computed" data-transfer-pct="{{ pct }}">
			<span class="js-theme-transfer-amount {{ price_class }}" aria-live="polite">{% if tr is not null %}{{ tr | money_nocents }}{% endif %}</span>
			<span class="opacity-90"> {{ _transfer_suffix }}</span>
		</div>
	{% endif %}
{% endif %}
