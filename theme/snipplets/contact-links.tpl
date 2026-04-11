<div class="contact-info row no-gutters">
	{% set subtitle_classes = 'font-small text-transform mb-1 opacity-80' %}
	{% set link_classes = 'btn-link text-transform' %}
	{% set contact_item_classes = 'contact-info-item mb-3 d-md-inline-block mr-md-3' %}

	{% if store.whatsapp %}
		<div class="col-md-auto">
			<div class="{{ contact_item_classes }}">
				<div class="{{ subtitle_classes }}">{{ 'Whatsapp' | translate }}</div>
				<a href="{{ store.whatsapp }}" class="{{ link_classes }}">
					{{ store.whatsapp |trim('https://wa.me/') }}
				</a>
			</div>
		</div>
	{% endif %}
	{% if store.phone %}
		<div class="col-md-auto">
			<div class="{{ contact_item_classes }}">
				<div class="{{ subtitle_classes }}">{{ 'Teléfono' | translate }}</div>
				<a href="tel:{{ store.phone }}" class="{{ link_classes }}">
					{{ store.phone }}
				</a>
			</div>
		</div>
	{% endif %}
	{% if store.email %}
		<div class="col-md-auto">
			<div class="{{ contact_item_classes }}">
				<div class="{{ subtitle_classes }}">{{ 'Email' | translate }}</div>
				<a href="mailto:{{ store.email }}" class="{{ link_classes }}">
					{{ store.email }}
				</a>
			</div>
		</div>
	{% endif %}
	{% if not phone_and_mail_only %}
		{% if store.address and not is_order_cancellation %}
			<div class="col-md-auto">
				<div class="text-transform mb-3 {{ contact_item_classes }}">
					<div class="{{ subtitle_classes }}">{{ 'Dirección' | translate }}</div>
					{{ store.address }}
				</div>
			</div>
		{% endif %}
		{% if store.blog %}
			<div class="col-md-auto">
				<div class="{{ contact_item_classes }}">
					<div class="{{ subtitle_classes }}">{{ 'Blog' | translate }}</div>
					<a target="_blank" rel="noopener noreferrer" href="{{ store.blog }}" class="{{ link_classes }}">
						{{ "¡Visitá nuestro Blog!" | translate }}
					</a>
				</div>
			</div>
		{% endif %}
	{% endif %}
</div>