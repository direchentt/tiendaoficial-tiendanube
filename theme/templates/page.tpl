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
		<span class="hs-wishlist-page-heading d-inline-flex align-items-center flex-wrap" style="gap:0.65rem;">
			<span class="pdp-wishlist-btn pdp-wishlist-btn--static" aria-hidden="true">
				{% include 'snipplets/icons/icon-wishlist-bookmark.tpl' with { wl_size: 22 } %}
			</span>
			<span>{{ page.name }}</span>
		</span>
	{% endblock page_header_text %}
{% endembed %}

<section class="hs-wishlist-page theme-brand-phase1 pb-5 pt-md-1">
	<div class="container-fluid">
		<div class="row justify-content-center">
			<div class="col-12 col-lg-10 col-xl-9">
				{% if page.content %}
				<div class="user-content-body mb-4">{{ page.content }}</div>
				{% endif %}

				{% if not customer %}
				<div class="hs-wishlist-login-gate card border p-4 mb-4 text-center">
					<p class="mb-3">{{ 'Iniciá sesión para ver tus favoritos' | translate }}</p>
					<a href="{{ store.customer_login_url }}" class="btn btn-primary">{{ 'Iniciar sesión' | translate }}</a>
				</div>
				{% endif %}

				<div
					id="hs-wishlist-page"
					class="hs-wishlist-page-root"
					data-logged="{% if customer %}1{% else %}0{% endif %}"
					data-wishlist-path="{{ wl_url }}"
					data-msg-empty="{{ 'Tu lista de favoritos está vacía.' | translate | e('html_attr') }}"
					data-msg-error="{{ 'No pudimos cargar tus favoritos. Intentá de nuevo más tarde.' | translate | e('html_attr') }}"
				>
					{% if customer %}
					<p class="hs-wishlist-loading text-muted text-center mb-0 py-4">{{ 'Cargando favoritos' | translate }}</p>
					{% else %}
					<p class="text-muted text-center mb-0 py-3">{{ 'Iniciá sesión para ver tus favoritos' | translate }}</p>
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
