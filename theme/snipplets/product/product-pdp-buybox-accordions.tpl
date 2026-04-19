{# Acordeones buybox (referencia boutique): detalles, cuidado, envíos + devoluciones. Requiere show_product_fulfillment desde product-form. #}
{% set care_custom = (settings.brand_pdp_care_html | default('')) | trim %}
<div id="pdp-buybox-accordions" class="pdp-accordion-stack mt-1 mt-md-2 mb-4" data-pdp-accordion-stack>
	{% if product.description is not empty %}
		<details class="pdp-accordion__item">
			<summary class="pdp-accordion__summary">
				<span class="pdp-accordion__title">{{ 'Detalles del producto' | translate }}</span>
				<span class="pdp-accordion__icon" aria-hidden="true"></span>
			</summary>
			<div class="pdp-accordion__body user-content">
				{{ product.description | raw }}
			</div>
		</details>
	{% endif %}

	<details class="pdp-accordion__item">
		<summary class="pdp-accordion__summary">
			<span class="pdp-accordion__title">{{ 'Guía de cuidado de ropa' | translate }}</span>
			<span class="pdp-accordion__icon" aria-hidden="true"></span>
		</summary>
		<div class="pdp-accordion__body font-small pdp-accordion__body--care">
			{% if care_custom is not empty %}
				{{ care_custom | raw }}
			{% else %}
				<p class="mb-2">{{ 'Lavado suave o a mano con agua fría. No uses lejía. Secá a la sombra y planchá a temperatura media del revés.' | translate }}</p>
				<p class="mb-0 opacity-80">{{ 'Consultá la etiqueta de cada prenda: puede haber fibras delicadas.' | translate }}</p>
			{% endif %}
		</div>
	</details>

	<details class="pdp-accordion__item" id="pdp-accordion-shipping-wrap">
		<summary class="pdp-accordion__summary">
			<span class="pdp-accordion__title">{{ 'Envíos y devoluciones' | translate }}</span>
			<span class="pdp-accordion__icon" aria-hidden="true"></span>
		</summary>
		<div class="pdp-accordion__body">
			{% if show_product_fulfillment %}
				<div id="pdp-zone-shipping" class="pdp-shipping-card pdp-shipping-card--accordion mb-0 pb-0" role="region" aria-label="{{ 'Envío' | translate }}">
					<p class="pdp-shipping-card__label mb-3">{{ 'Medios de envío y retiro' | translate }}</p>
					<div id="product-shipping-container" class="product-shipping-calculator list" {% if not product.display_price or not product.has_stock %}style="display:none;"{% endif %} data-shipping-url="{{ store.shipping_calculator_url }}">
						{% if store.has_shipping %}
							{% include 'snipplets/shipping/shipping-calculator.tpl' with {'shipping_calculator_variant' : product.selected_or_first_available_variant, 'product_detail': true} %}
						{% endif %}
					</div>
					{% if store.branches %}
						{% include 'snipplets/shipping/branches.tpl' with {'product_detail': true} %}
					{% endif %}
				</div>
				<div class="pdp-accordion__returns font-small mt-3 pt-3 border-top">
					<p class="mb-2">{{ 'Los plazos de entrega son orientativos según la zona y el correo elegido en el checkout.' | translate }}</p>
					<p class="mb-0">{{ 'Cambios y devoluciones: escribinos antes de usar la prenda y conservá etiquetas y empaque original cuando aplique.' | translate }}</p>
				</div>
			{% elseif product.free_shipping and not product.is_non_shippable %}
				<p class="font-small mb-0">{{ 'Envío gratis' | translate }}</p>
			{% elseif product.is_non_shippable %}
				<p class="font-small mb-0 opacity-80">{{ 'Este producto no se envía a domicilio.' | translate }}</p>
			{% else %}
				<p class="font-small mb-2">{{ 'Para cotizar envío por código postal, activá “Mostrar el calculador de envíos en la página de producto” en la configuración de tu tienda (Tiendanube).' | translate }}</p>
				<p class="font-small mb-0 opacity-80">{{ 'Los plazos y costos finales se confirman en el checkout.' | translate }}</p>
			{% endif %}
		</div>
	</details>
</div>
