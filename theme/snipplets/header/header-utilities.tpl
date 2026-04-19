{% set search_padding_md_classes = settings.logo_position_desktop == 'center' and not settings.hamburger_desktop ? 'pl-md-0' %}
{% set menu_padding_classes = settings.logo_position_mobile == 'center' ? 'pl-0' %}
{% set menu_padding_md_classes = settings.logo_position_desktop == 'center' ? 'pl-md-0' : 'pl-md-2' %}

{% set menu_disp = settings.header_menu_display|default('text') %}
{% set search_disp = settings.header_search_display|default('text') %}
{% set account_disp = settings.header_account_display|default('text') %}
{% set cart_disp = settings.header_cart_display|default('text') %}

{% if use_menu %}
	<span class="utilities-container d-inline-block">
		<a href="#" class="js-modal-open utilities-item btn btn-utility {{ menu_padding_classes }} {{ menu_padding_md_classes }}" data-toggle="#nav-hamburger" aria-label="{{ 'Menú' | translate }}" data-component="menu-button">
			{% if menu_disp == 'icon_custom' and settings.header_menu_svg|default('')|trim %}
				<span class="header-utility-icon" aria-hidden="true">{{ settings.header_menu_svg|raw }}</span>
			{% elseif menu_disp == 'icon' %}
				<svg class="icon-inline header-utility-svg" aria-hidden="true"><use xlink:href="#brand-utility-menu"/></svg>
			{% else %}
				<span class="utilities-text">{{ 'Menú' | translate }}</span>
			{% endif %}
		</a>
	</span>
{% elseif use_account %}
	<span class="utilities-container text-transform">
		{% if login_only %}
			<a href="{% if not customer %}{{ store.customer_login_url }}{% else %}{{ store.customer_home_url }}{% endif %}" class="btn btn-utility" aria-label="{% if customer %}{{ 'Mi cuenta' | translate }}{% else %}{{ 'Login' | translate }}{% endif %}">
				<span style="position:relative; display:inline-flex; align-items:center; justify-content:center;">
					{% if account_disp == 'icon_custom' and settings.header_account_svg|default('')|trim %}
						<span class="header-utility-icon" aria-hidden="true">{{ settings.header_account_svg|raw }}</span>
					{% elseif account_disp == 'icon' %}
						<svg class="icon-inline header-utility-svg" aria-hidden="true"><use xlink:href="#brand-utility-user"/></svg>
					{% else %}
						<span class="utilities-text">
							{% if customer %}
								{{ 'Mi cuenta' | translate }}
							{% else %}
								{{ 'Login' | translate }}
							{% endif %}
						</span>
					{% endif %}
					{# ── Login status dot: verde=logueado, rojo=visitante ── #}
					<span aria-hidden="true" style="position:absolute; bottom:0px; right:-2px; width:8px; height:8px; border-radius:50%; background:{% if customer %}#22c55e{% else %}#ef4444{% endif %}; border:1.5px solid #fff; display:block; animation: blink-dot 1.5s infinite ease-in-out;"></span>
				</span>
				<style>
					@keyframes blink-dot {
						0%, 100% { opacity: 1; transform: scale(1); }
						50% { opacity: 0.4; transform: scale(0.9); }
					}
				</style>
			</a>
		{% else %}
			{% if not customer %}
				{{ "Iniciar sesión" | translate | a_tag(store.customer_login_url, '', '') }}
				{% if 'mandatory' not in store.customer_accounts %}
					<span class="mx-1">/</span>
					{{ "Crear cuenta" | translate | a_tag(store.customer_register_url, '', '') }}
				{% endif %}
			{% else %}
				{% set customer_short_name = customer.name|split(' ')|slice(0, 1)|join %}
				{{ "¡Hola, {1}!" | t(customer_short_name) | a_tag(store.customer_home_url, '', '') }}
				<span class="mx-1">/</span>
				{{ "Cerrar sesión" | translate | a_tag(store.customer_logout_url, '', 'ml-1') }}
			{% endif %}
		{% endif %}
	</span>
{% elseif use_languages %}
	<span class="utilities-container nav-dropdown text-transform">
		<span class="btn btn-utility">
			{% for language in languages if language.active %}
				{{ language.country }}
			{% endfor %}
			<svg class="icon-inline icon-xs icon-w-12 ml-1"><use xlink:href="#chevron-down"/></svg>
		</span>
		<div class="nav-dropdown-content desktop-dropdown-small position-absolute">
			{% include "snipplets/navigation/navigation-lang.tpl" with { header: true } %}
		</div>
	</span>
{% elseif use_search %}
	<span class="utilities-container d-inline-block">
		<a href="#" class="js-search-button js-modal-open js-fullscreen-modal-open btn btn-utility utilities-item {{ search_padding_md_classes }}" data-modal-url="modal-fullscreen-search" data-toggle="#nav-search" aria-label="{{ 'Buscador' | translate }}">
			{% if search_disp == 'icon_custom' and settings.header_search_svg|default('')|trim %}
				<span class="header-utility-icon" aria-hidden="true">{{ settings.header_search_svg|raw }}</span>
			{% elseif search_disp == 'icon' %}
				<svg class="icon-inline header-utility-svg" aria-hidden="true"><use xlink:href="#brand-utility-search"/></svg>
			{% else %}
				<span class="utilities-text">{{ 'Buscar' | translate }}</span>
			{% endif %}
		</a>
	</span>
{% else %}
	<span class="utilities-container d-inline-block">
		<div id="ajax-cart" class="cart-summary" data-component='cart-button'>
			<a
				{% if settings.ajax_cart and template != 'cart' %}
					href="#"
					data-toggle="#modal-cart"
					data-modal-url="modal-fullscreen-cart"
				{% else %}
					href="{{ store.cart_url }}"
				{% endif %}
				class="{% if settings.ajax_cart and template != 'cart' %}js-modal-open js-fullscreen-modal-open{% endif %} btn btn-utility d-flex align-items-center pr-0"
				aria-label="{{ 'Carrito' | translate }}"
				>
				{% if cart_disp == 'icon_custom' and settings.header_cart_svg|default('')|trim %}
					<span class="header-utility-icon mr-1" aria-hidden="true">{{ settings.header_cart_svg|raw }}</span>
				{% elseif cart_disp == 'icon' %}
					<svg class="icon-inline header-utility-svg mr-1" aria-hidden="true"><use xlink:href="#brand-utility-cart"/></svg>
				{% else %}
					<span class="utilities-text">{{ 'Carrito' | translate }}</span>
				{% endif %}
				<span class="js-cart-widget-amount badge">{{ "{1}" | translate(cart.items_count ) }}</span>
			</a>
		</div>
	</span>
{% endif %}
