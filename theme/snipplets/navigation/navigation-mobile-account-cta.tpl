{# Pie del menú móvil: CTA cuenta (visitante / logueado). #}
<div class="brand-mobile-account-cta">
	{% if not customer %}
		<p class="brand-mobile-account-cta__hint font-small text-muted mb-0">
			{{ 'Creá tu cuenta para guardar favoritos, ver pedidos y recibir novedades.' | translate }}
		</p>
		<div class="brand-mobile-account-cta__actions brand-mobile-account-cta__actions--row">
			{% if 'mandatory' not in store.customer_accounts %}
				<a
					href="{{ store.customer_register_url }}"
					class="brand-mobile-account-cta__btn brand-mobile-account-cta__btn--primary text-uppercase font-weight-semibold text-decoration-none text-center"
				>
					{{ 'Crear cuenta' | translate }}
				</a>
			{% endif %}
			<a
				href="{{ store.customer_login_url }}"
				class="brand-mobile-account-cta__btn brand-mobile-account-cta__btn--secondary text-uppercase font-weight-semibold text-decoration-none text-center"
			>
				{{ 'Iniciar sesión' | translate }}
			</a>
		</div>
	{% else %}
		{% set customer_short_name = customer.name|split(' ')|slice(0, 1)|join %}
		<p class="brand-mobile-account-cta__greeting font-weight-semibold mb-2">
			{{ '¡Hola, {1}!' | t(customer_short_name) }}
		</p>
		<div class="brand-mobile-account-cta__actions brand-mobile-account-cta__actions--stacked">
			<a
				href="{{ store.customer_home_url }}"
				class="brand-mobile-account-cta__btn brand-mobile-account-cta__btn--secondary text-uppercase font-weight-semibold text-decoration-none text-center d-block"
			>
				{{ 'Mi cuenta' | translate }}
			</a>
			<a
				href="{{ store.customer_logout_url }}"
				class="brand-mobile-account-cta__link-muted font-small text-decoration-none d-block text-center mt-2"
			>
				{{ 'Cerrar sesión' | translate }}
			</a>
		</div>
	{% endif %}
</div>
