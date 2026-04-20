{# Bloque en Mi cuenta: enlace a la pagina de favoritos (solo si la wishlist esta activa en el tema). #}
{% if settings.wishlist_enabled %}
{% set wl_handle = settings.wishlist_page_handle|default('my-wishlist')|trim %}
{% if wl_handle|slice(0, 1) == '/' %}
	{% set wl_handle = wl_handle|slice(1) %}
{% endif %}
{% set wl_url = '/' ~ wl_handle %}
<div class="mt-4 pt-4" style="border-top:1px solid #eaeaea;">
	<div class="d-flex justify-content-between align-items-center mb-2">
		<h4 class="d-inline-flex align-items-center flex-wrap account-wishlist-heading" style="margin:0; font-family:var(--font-headings); font-weight:600; font-size:1.2rem; gap:0.5rem;">
			<span class="pdp-wishlist-btn pdp-wishlist-btn--static pdp-wishlist-btn--inline" aria-hidden="true">
				{% include 'snipplets/icons/icon-wishlist-bookmark.tpl' with { wl_size: 18 } %}
			</span>
			<span>{{ 'Mis favoritos' | translate }}</span>
		</h4>
	</div>
	<p class="font-small text-muted mb-3" style="line-height:1.5;">{{ 'Productos que guardaste para más tarde.' | translate }}</p>
	<a href="{{ wl_url }}" class="btn btn-outline-dark btn-sm text-uppercase d-inline-flex align-items-center" style="letter-spacing:0.06em; gap:0.5rem;">
		{% include 'snipplets/icons/icon-wishlist-bookmark.tpl' with { wl_size: 16 } %}
		{{ 'Ir a favoritos' | translate }}
	</a>
</div>
{% endif %}
