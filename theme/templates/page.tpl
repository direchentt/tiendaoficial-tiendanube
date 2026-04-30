{# Slug de la pagina (Mi Tiendanube > Paginas): URL publica /SLUG ej. /my-wishlist #}
{% set wl_handle = settings.wishlist_page_handle|default('my-wishlist')|trim %}
{% if wl_handle|slice(0, 1) == '/' %}
	{% set wl_handle = wl_handle|slice(1) %}
{% endif %}
{% set wl_url = '/' ~ wl_handle %}
{% set is_wishlist_page = settings.wishlist_enabled and page.handle == wl_handle %}

{% set spotify_handle = settings.brand_spotify_landing_handle | default('spoti-fy') | trim %}
{% if spotify_handle|slice(0, 1) == '/' %}
	{% set spotify_handle = spotify_handle|slice(1) %}
{% endif %}
{% set is_spotify_landing = page.handle == spotify_handle %}
{% set is_bundle_landing = page.handle == 'bundle' %}

{% if is_wishlist_page %}
{% embed "snipplets/page-header.tpl" with {'breadcrumbs': true} %}
	{% block page_header_text %}
		{{ page.name }}
	{% endblock page_header_text %}
{% endembed %}

<section class="user-content brand-page-user-content hs-wishlist-page theme-brand-phase1 pb-5 pt-md-1">
	<div class="container-fluid">
		<div class="row justify-content-center">
			<div class="col-12 col-lg-11 col-xl-10 brand-page-rail">
				{% if customer %}
				<div class="hs-wl-intro mb-4 mb-md-5">
					<p class="hs-wl-intro__eyebrow mb-2">{{ 'Tu vitrina de deseos' | translate }}</p>
					<p class="hs-wl-intro__lead mb-0">{{ 'Acá converge todo lo que te hizo frenar el dedo en el corazón: repetí la compra al toque, mirá precios y volvé a la ficha cuando quieras más detalle.' | translate }}</p>
				</div>
				{% endif %}

				{% if page.content %}
				<div class="user-content-body mb-4 mb-md-5">{{ page.content }}</div>
				{% endif %}

				{% if not customer %}
				<div class="hs-wishlist-login-gate hs-wl-login-gate mb-4 mb-md-5 text-center">
					<p class="hs-wl-login-gate__title mb-2">{{ 'Iniciá sesión para ver tus favoritos' | translate }}</p>
					<p class="hs-wl-login-gate__lead mb-4">{{ 'Así podemos mostrarte tu lista personal y mantenerla sincronizada.' | translate }}</p>
					<a href="{{ store.customer_login_url }}" class="btn btn-primary px-4">{{ 'Iniciar sesión' | translate }}</a>
				</div>
				{% endif %}

				<div
					id="hs-wishlist-page"
					class="hs-wishlist-page-root"
					data-logged="{% if customer %}1{% else %}0{% endif %}"
					data-wishlist-path="{{ wl_url }}"
					data-msg-empty="{{ 'Tu lista de favoritos está vacía.' | translate | e('html_attr') }}"
					data-msg-empty-lead="{{ 'Tu lista está lista para llenarse: navegá, enamorate de algo y tocá el corazón.' | translate | e('html_attr') }}"
					data-msg-error="{{ 'No pudimos cargar tus favoritos. Intentá de nuevo más tarde.' | translate | e('html_attr') }}"
					data-label-view="{{ 'Ver producto' | translate | e('html_attr') }}"
					data-label-remove="{{ 'Quitar de favoritos' | translate | e('html_attr') }}"
					data-label-removed="{{ 'Quitado de favoritos' | translate | e('html_attr') }}"
					data-label-buy="{{ 'Repetir compra' | translate | e('html_attr') }}"
					data-label-buy-disabled="{{ 'Elegí opciones en la ficha' | translate | e('html_attr') }}"
					data-toast-cart-ok="{{ '¡Listo! Ya está en tu carrito' | translate | e('html_attr') }}"
					data-toast-cart-fail="{{ 'No pudimos agregarlo al carrito. Probá desde la ficha del producto.' | translate | e('html_attr') }}"
					data-wl-stat-noun="{{ 'favoritos curados' | translate | e('html_attr') }}"
					data-wl-empty-cta="{{ 'Seguí explorando la tienda' | translate | e('html_attr') }}"
				>
					{% if customer %}
					<div class="hs-wishlist-loading-state text-center py-5" aria-busy="true">
						<p class="font-small text-muted mb-0">{{ 'Cargando favoritos' | translate }}</p>
					</div>
					{% else %}
					<p class="font-small text-muted text-center mb-0 py-3">{{ 'Iniciá sesión para ver tus favoritos' | translate }}</p>
					{% endif %}
				</div>
			</div>
		</div>
	</div>
</section>

{% elseif is_spotify_landing %}

{% embed "snipplets/page-header.tpl" with {'breadcrumbs': true} %}
	{% block page_header_text %}
		{{ page.name }}
	{% endblock page_header_text %}
{% endembed %}

{% snipplet 'brand/brand-spoti-fy-landing.tpl' %}

{% elseif is_bundle_landing %}

{% embed "snipplets/page-header.tpl" with {'breadcrumbs': true} %}
	{% block page_header_text %}
		{{ page.name }}
	{% endblock page_header_text %}
{% endembed %}

{% include 'snipplets/brand/hache-bundles-storefront.tpl' with {
	intro_html: page.content,
	bundle_mode: 'pas-normal',
	bundle_landing_slug: page.handle
} %}

{% else %}

{% embed "snipplets/page-header.tpl" %}
	{% block page_header_text %}{{ page.name }}{% endblock page_header_text %}
{% endembed %}

{# Institutional page  #}

<section class="user-content brand-page-user-content pb-5 pt-md-1">
	<div class="container-fluid">
		<div class="row justify-content-center">
			<div class="col-12 col-lg-10 col-xl-8 brand-page-rail">
				<div class="user-content-body">
					{{ page.content }}
				</div>
			</div>
		</div>
	</div>
</section>

{% endif %}
