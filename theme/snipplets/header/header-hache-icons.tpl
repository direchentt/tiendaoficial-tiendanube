{# Campana + favoritos en barra (solo desktop; en móvil van en header-hamburger-modal-toolbar). #}
{% set show_notify = settings.header_notify_enabled|default(1) %}
{% set show_wl_icon = settings.wishlist_enabled and settings.header_wishlist_icon|default(1) %}

{% if show_notify or show_wl_icon %}
	<span class="utilities-container hache-header-utils d-none d-md-inline-flex align-items-center">
		{% include 'snipplets/header/header-hache-notify-wishlist.tpl' %}
	</span>
{% endif %}
