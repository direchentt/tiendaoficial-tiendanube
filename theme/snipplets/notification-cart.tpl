
{% set notification_without_recommendations_classes = 'js-alert-added-to-cart notification-floating notification-cart-container notification-hidden notification-fixed position-absolute' %}
{% set notification_wrapper_classes = 
	related_products ? 'row' 
	: not related_products and not settings.head_fix_desktop ? notification_without_recommendations_classes ~ ' position-fixed-md' 
	: notification_without_recommendations_classes 
%}

<div class="{{ notification_wrapper_classes }}" {% if not related_products %}style="display: none;"{% endif %}>
	<div class="{% if related_products %}col-12 col-md mb-4 mb-md-0{% else %}notification notification-primary notification-cart p-0{% endif %}">
		{% if not related_products %}
			<div class="js-cart-notification-close notification-close">
				<svg class="icon-inline icon-2x notification-icon"><use xlink:href="#times"/></svg>
			</div>
		{% endif %}
		<div class="js-cart-notification-item row no-gutters align-items-center" data-store="cart-notification-item">
			<div class="col-auto pr-0 notification-img">
				<img src="" class="js-cart-notification-item-img img-absolute-centered-vertically" />
			</div>
			<div class="col text-left pl-3 {% if not related_products %}pr-4{% endif %}">
				<div class="mb-1 mr-2 text-transform font-weight-bold">
					<span class="js-cart-notification-item-name"></span>
					<span class="js-cart-notification-item-variant-container" style="display: none;">
						(<span class="js-cart-notification-item-variant"></span>)
					</span>
				</div>
				<div class="mb-1">
					<span class="js-cart-notification-item-quantity"></span>
					<span> x </span>
					<span class="js-cart-notification-item-price"></span>
				</div>
			</div>
		</div>
	</div>
	{% if related_products %}
		<div class="col-12 col-md-auto">
			<div class="mb-2 pb-1">
				<div class="row text-primary h4 font-large font-family-body">
					<span class="col-auto text-left">
						<span>{{ "Total" | translate }}</span> 
						(<span class="js-cart-widget-amount">
							{{ "{1}" | translate(cart.items_count ) }} 
						</span>
						<span class="js-cart-counts-plural" style="display: none;">
							{{ 'productos' | translate }}):
						</span>
						<span class="js-cart-counts-singular" style="display: none;">
							{{ 'producto' | translate }}):
						</span>
					</span>
					<span class="js-cart-total col text-right">{{ cart.total | money_nocents }}</span>
				</div>
			</div>
			<a href="#" data-toggle="#modal-cart" data-modal-url="modal-fullscreen-cart" class="js-modal-close js-modal-open js-fullscreen-modal-open btn btn-primary btn-big d-block">{{ 'Ver carrito' | translate }}</a>
		</div>
	{% endif %}
</div>

