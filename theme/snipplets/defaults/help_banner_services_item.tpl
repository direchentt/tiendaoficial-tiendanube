{% set banner_services_icon_classes = 'icon-inline h2 align-item-middle svg-icon-text' %}

<div class="swiper-slide w-md-auto d-table-cell mw-md-25 p-0">
	<h3 class="h3-huge h2-huge-md d-inline-block align-middle mb-1 mr-3">
		{% if help_item_1 %}
			{{ 'Medios de envío' | translate }}
		{% elseif help_item_2 %}
			{{ 'Medios de pago' | translate }}
		{% elseif help_item_3 %}
			{{ 'Promociones' | translate }}
		{% elseif help_item_4 %}
			{{ 'Cambios y devoluciones' | translate }}
		{% endif %}
	</h3>
</div>