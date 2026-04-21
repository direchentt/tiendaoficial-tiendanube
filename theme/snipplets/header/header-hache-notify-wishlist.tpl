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
			<span class="js-hache-notify-badge hache-header-badge{% if not settings.header_notify_badge_always|default(1) %} d-none{% endif %}" aria-hidden="true">{% if settings.header_notify_badge_always|default(1) %}1{% endif %}</span>
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
			<div class="js-hache-notify-list hache-notify-panel__body"></div>
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
