{# PDP quick facts: only uses product / settings already available on TN. #}
{% set installments_info = product.installments_info_from_any_variant %}
{% set show_payments_chip = settings.product_detail_installments and product.show_installments and product.display_price and installments_info %}

<div class="pdp-highlights mb-3" role="list" aria-label="{{ 'Información clave del producto' | translate }}">
	{% if product.free_shipping %}
		<span class="pdp-chip pdp-chip--accent" role="listitem">{{ "Envío gratis" | translate }}</span>
	{% endif %}

	{% if product.available and product.display_price and product.has_stock %}
		<span class="pdp-chip pdp-chip--ok" role="listitem">{{ "en stock" | translate }}</span>
	{% elseif not product.available or (product.available and not product.has_stock) %}
		<span class="pdp-chip pdp-chip--muted" role="listitem">{{ "Sin stock" | translate }}</span>
	{% endif %}

	{% if show_payments_chip %}
		<a href="#" class="pdp-chip pdp-chip--action js-modal-open js-fullscreen-modal-open" role="listitem" data-toggle="#installments-modal" data-modal-url="modal-fullscreen-payments">{{ "Medios de pago" | translate }}</a>
	{% endif %}
</div>
