{# Icono bookmark / favoritos (mismo trazo en PDP y pagina wishlist). Params: wl_size (default 20), wl_extra_class (opcional, clases en el SVG) #}
{% set wl_size = wl_size|default(20) %}
<svg class="icon-wishlist-bookmark pdp-wishlist-btn__svg{% if wl_extra_class %} {{ wl_extra_class }}{% endif %}" width="{{ wl_size }}" height="{{ wl_size }}" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
	<path d="M5 4h14v15a1 1 0 0 1-1.447.894L12 17.382l-5.553 2.512A1 1 0 0 1 5 19V4z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
</svg>
