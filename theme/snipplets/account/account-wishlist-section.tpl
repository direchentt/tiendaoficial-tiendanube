{# Bloque en Mi cuenta: enlace a la pagina de favoritos (solo si la wishlist esta activa en el tema). #}
{% if settings.wishlist_enabled %}
{% set wl_handle = settings.wishlist_page_handle|default('my-wishlist')|trim %}
{% if wl_handle|slice(0, 1) == '/' %}
	{% set wl_handle = wl_handle|slice(1) %}
{% endif %}
{% set wl_url = '/' ~ wl_handle %}
<div class="account-wishlist-block mt-5 pt-4 border-top">
	<h4 class="font-weight-bold mb-2" style="font-family: var(--font-headings, sans-serif); font-size: 1.15rem;">
		{{ 'Mis favoritos' | translate }}
	</h4>
	<p class="font-small text-muted mb-3" style="line-height: 1.55;">
		{{ 'Productos que guardaste para más tarde.' | translate }}
	</p>
	<a href="{{ wl_url }}" class="btn btn-outline-primary btn-sm text-uppercase font-weight-semibold" style="letter-spacing: 0.06em;">
		{{ 'Ir a favoritos' | translate }}
	</a>
</div>
{% endif %}
