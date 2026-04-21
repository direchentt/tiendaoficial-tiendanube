{# Slug de la pagina (Mi Tiendanube > Paginas): URL publica /SLUG ej. /my-wishlist #}
{% set wl_handle = settings.wishlist_page_handle|default('my-wishlist')|trim %}
{% if wl_handle|slice(0, 1) == '/' %}
	{% set wl_handle = wl_handle|slice(1) %}
{% endif %}
{% set wl_url = '/' ~ wl_handle %}
{% set is_wishlist_page = settings.wishlist_enabled and page.handle == wl_handle %}

{% if is_wishlist_page %}
{% embed "snipplets/page-header.tpl" with {'breadcrumbs': true} %}
	{% block page_header_text %}
		{{ page.name }}
	{% endblock page_header_text %}
{% endembed %}

<section class="user-content brand-page-user-content hs-wishlist-page theme-brand-phase1 pb-5 pt-md-1">
	<div class="container-fluid">
		<div class="row justify-content-center">
			<div class="col-12 col-lg-10 col-xl-8 brand-page-rail">
				{% if customer %}
				<p class="font-small text-muted mb-4">{{ 'Los productos que marcaste con el corazón al navegar la tienda aparecen acá, igual que en el catálogo.' | translate }}</p>
				{% endif %}

				{% if page.content %}
				<div class="user-content-body mb-4">{{ page.content }}</div>
				{% endif %}

				{% if not customer %}
				<div class="hs-wishlist-login-gate card border-0 shadow-sm p-4 p-md-5 mb-4 text-center">
					<p class="font-body mb-1 font-weight-bold">{{ 'Iniciá sesión para ver tus favoritos' | translate }}</p>
					<p class="font-small text-muted mb-4">{{ 'Así podemos mostrarte tu lista personal y mantenerla sincronizada.' | translate }}</p>
					<a href="{{ store.customer_login_url }}" class="btn btn-primary px-4">{{ 'Iniciar sesión' | translate }}</a>
				</div>
				{% endif %}

				<div
					id="hs-wishlist-page"
					class="hs-wishlist-page-root"
					data-logged="{% if customer %}1{% else %}0{% endif %}"
					data-wishlist-path="{{ wl_url }}"
					data-msg-empty="{{ 'Tu lista de favoritos está vacía.' | translate | e('html_attr') }}"
					data-msg-error="{{ 'No pudimos cargar tus favoritos. Intentá de nuevo más tarde.' | translate | e('html_attr') }}"
					data-label-view="{{ 'Ver producto' | translate | e('html_attr') }}"
					data-label-remove="{{ 'Quitar de favoritos' | translate | e('html_attr') }}"
					data-label-removed="{{ 'Quitado de favoritos' | translate | e('html_attr') }}"
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
