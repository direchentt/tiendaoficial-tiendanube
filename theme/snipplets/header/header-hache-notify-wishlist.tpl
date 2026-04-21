{# Campana novedades + favoritos (marcado compartido; HeaderHacheModule en hache-suite.js). #}
{% set wl_handle = settings.wishlist_page_handle|default('my-wishlist')|trim %}
{% if wl_handle|slice(0, 1) == '/' %}
	{% set wl_handle = wl_handle|slice(1) %}
{% endif %}
{% set wl_url = '/' ~ wl_handle %}
{% set show_notify = settings.header_notify_enabled|default(1) %}
{% set show_wl_icon = settings.wishlist_enabled and settings.header_wishlist_icon|default(1) %}

{% if show_notify %}
	<span class="position-relative d-inline-block hache-notify-wrap">
		<button
			type="button"
			class="js-hache-notify-toggle btn btn-utility position-relative"
			aria-expanded="false"
			aria-haspopup="true"
			aria-label="{{ 'Novedades de la tienda' | translate }}"
			data-notify-days="{{ settings.header_notify_days|default(30) }}"
			data-notify-limit="10"
			data-badge-always="{% if settings.header_notify_badge_always|default(1) %}1{% else %}0{% endif %}"
			data-title="{{ 'Últimos ingresos' | translate | e('html_attr') }}"
			data-empty="{{ 'Sin lanzamientos recientes en este periodo.' | translate | e('html_attr') }}"
			data-label-new="{{ 'Nuevo' | translate | e('html_attr') }}"
		>
			<svg class="icon-inline header-utility-svg hache-header-bell-svg" width="22" height="22" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
				<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
				<path d="M13.73 21a2 2 0 0 1-3.46 0" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
			</svg>
			{% set badge_count = sections.new.products | length %}
			{% if badge_count > 10 %}{% set badge_count = 10 %}{% endif %}
			<span class="js-hache-notify-badge hache-header-badge{% if badge_count == 0 and not settings.header_notify_badge_always|default(1) %} d-none{% endif %}" aria-hidden="true">
				{% if badge_count > 0 %}{{ badge_count }}{% else %}0{% endif %}
			</span>
		</button>
		<div class="js-hache-notify-backdrop hache-notify-backdrop" hidden aria-hidden="true"></div>
		<div
			class="js-hache-notify-panel hache-notify-panel card border-0 shadow"
			hidden
			role="dialog"
			aria-label="{{ 'Últimos ingresos' | translate }}"
		>
			<div class="hache-notify-panel__head hache-notify-panel__head--compact px-3 py-2 border-bottom font-weight-semibold font-small text-uppercase" style="letter-spacing:0.06em;">
				{{ 'Últimos ingresos' | translate }}
			</div>
			<div class="js-hache-notify-list-native hache-notify-panel__body">
				{% set count = 0 %}
				{% for product in sections.new.products %}
					{% if count < 10 %}
						<a href="{{ product.url }}" class="hache-notify-row d-flex align-items-center text-decoration-none text-reset py-2 px-2 rounded">
							<div class="hache-notify-row__thumb flex-shrink-0 mr-2">
								<img src="{{ product.featured_image | product_image_url('small') }}" alt="{{ product.name }}" class="rounded" loading="lazy" style="width: 40px; height: 40px; object-fit: cover;">
							</div>
							<div class="min-w-0 flex-grow-1">
								<div class="font-weight-semibold font-small text-truncate" style="line-height: 1.2;">{{ product.name }}</div>
								<div class="text-muted text-uppercase mt-1" style="font-size: 0.65rem; letter-spacing: 0.06em;">{{ 'Nuevo' | translate }}</div>
							</div>
						</a>
						{% set count = count + 1 %}
					{% endif %}
				{% endfor %}
				{% if count == 0 %}
					<p class="font-small text-muted mb-0 px-2 py-3 text-center">{{ 'Sin lanzamientos recientes en este periodo.' | translate }}</p>
				{% endif %}
			</div>
		</div>
	</span>
{% endif %}

{% if show_wl_icon %}
	<a
		href="{{ wl_url }}"
		class="btn btn-utility{% if show_notify %} ml-1{% endif %}"
		aria-label="{{ 'Mis favoritos' | translate }}"
		title="{{ 'Mis favoritos' | translate }}"
	>
		<span class="d-inline-flex align-items-center justify-content-center" style="width:22px;height:22px;">
			{% include 'snipplets/icons/icon-wishlist-bookmark.tpl' with { wl_size: 20 } %}
		</span>
	</a>
{% endif %}
