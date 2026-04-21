{# Fila tipo Represent: cerrar, buscar, campana, favoritos (modal menú móvil). #}
<div class="d-flex align-items-center flex-nowrap w-100 hache-hamburger-toolbar px-3 py-3">
	<button type="button" class="btn btn-utility p-2 mr-2 js-toggle-menu-close" aria-label="{{ 'Cerrar' | translate }}">
		<svg class="icon-inline header-utility-svg" width="22" height="22" aria-hidden="true" focusable="false"><use xlink:href="#times"/></svg>
	</button>
	{% if not settings.search_big_mobile %}
		<a
			href="#"
			class="js-search-button js-modal-open js-fullscreen-modal-open btn btn-utility p-2 mr-2"
			data-modal-url="modal-fullscreen-search"
			data-toggle="#nav-search"
			aria-label="{{ 'Buscador' | translate }}"
		>
			{% set search_disp = settings.header_search_display|default('text') %}
			{% if search_disp == 'icon_custom' and settings.header_search_svg|default('')|trim %}
				<span class="header-utility-icon" aria-hidden="true">{{ settings.header_search_svg|raw }}</span>
			{% elseif search_disp == 'icon' %}
				<svg class="icon-inline header-utility-svg" aria-hidden="true"><use xlink:href="#brand-utility-search"/></svg>
			{% else %}
				<svg class="icon-inline header-utility-svg" aria-hidden="true"><use xlink:href="#brand-utility-search"/></svg>
			{% endif %}
		</a>
	{% endif %}
	<span class="d-inline-flex align-items-center flex-shrink-0 hache-hamburger-toolbar__tail">
		{% include 'snipplets/header/header-hache-notify-wishlist.tpl' %}
	</span>
</div>
