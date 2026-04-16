{# PDP: franja envio / stock / pago o contacto (estilo fila, siempre visible). #}
{% set installments_info = product.installments_info_from_any_variant %}
{% set show_payments_row = settings.product_detail_installments and product.show_installments and product.display_price and installments_info %}
{% set has_free_shipping = cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price %}
{% set has_product_free_shipping = product.free_shipping %}
{% set show_shipping_row = not product.is_non_shippable and product.available and product.display_price and (has_product_free_shipping or has_free_shipping) %}

<div class="pdp-trust-strip" role="region" aria-label="{{ 'Información de envíos, pagos y compra' | translate }}">
	<ul class="pdp-trust-strip__list" role="list">
		{% if show_shipping_row %}
			<li class="pdp-trust-strip__row" role="listitem">
				<span class="pdp-trust-strip__icon pdp-trust-strip__icon--ring" aria-hidden="true"></span>
				<span class="pdp-trust-strip__text">
					{% if has_product_free_shipping %}
						{{ "Envío gratis" | translate }}
					{% else %}
						<span class="text-accent">{{ "Envío gratis" | translate }}</span>
						<span class="js-shipping-minimum-label">{{ "superando los" | translate }} <span>{{ cart.free_shipping.min_price_free_shipping.min_price }}</span></span>
					{% endif %}
				</span>
			</li>
		{% endif %}

		{% if product.available and product.display_price and product.has_stock %}
			<li class="pdp-trust-strip__row pdp-trust-strip__row--stock" role="listitem">
				<span class="pdp-trust-strip__icon pdp-trust-strip__icon--dot" aria-hidden="true"></span>
				<span class="pdp-trust-strip__text">{{ "en stock" | translate }}</span>
			</li>
		{% elseif not product.available or (product.available and not product.has_stock) %}
			<li class="pdp-trust-strip__row pdp-trust-strip__row--muted" role="listitem">
				<span class="pdp-trust-strip__icon pdp-trust-strip__icon--dot pdp-trust-strip__icon--dot-muted" aria-hidden="true"></span>
				<span class="pdp-trust-strip__text">{{ "Sin stock" | translate }}</span>
			</li>
		{% endif %}

		{% if show_payments_row %}
			<li class="pdp-trust-strip__row" role="listitem">
				<span class="pdp-trust-strip__icon pdp-trust-strip__icon--square" aria-hidden="true"></span>
				<a href="#" class="pdp-trust-strip__action js-modal-open js-fullscreen-modal-open" data-toggle="#installments-modal" data-modal-url="modal-fullscreen-payments">{{ "Medios de pago" | translate }}</a>
			</li>
		{% elseif store.whatsapp %}
			<li class="pdp-trust-strip__row" role="listitem">
				<svg class="pdp-trust-strip__svg" aria-hidden="true" width="14" height="14"><use xlink:href="#whatsapp"/></svg>
				<a href="{{ store.whatsapp }}" class="pdp-trust-strip__action" target="_blank" rel="noopener noreferrer">{{ "WhatsApp" | translate }}</a>
			</li>
		{% elseif store.email and template == 'product' %}
			<li class="pdp-trust-strip__row" role="listitem">
				<span class="pdp-trust-strip__icon pdp-trust-strip__icon--square" aria-hidden="true"></span>
				<a href="mailto:{{ store.email }}?subject={{ product.name | url_encode }}" class="pdp-trust-strip__action">{{ "Email" | translate }}</a>
			</li>
		{% endif %}
	</ul>
</div>
