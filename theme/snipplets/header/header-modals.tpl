{# Modal Hamburger #}

{% set modal_position_desktop_val = settings.logo_position_desktop != 'center' ? 'right' : 'left' %}
{% set modal_position_mobile_val = settings.logo_position_mobile != 'center' ? 'right' : 'left' %}

{% if not settings.search_big_desktop %}

	{# Modal Search #}

	{% embed "snipplets/modal.tpl" with{modal_id: 'nav-search', modal_class: 'nav-search modal-fade', modal_position: modal_position_mobile_val, modal_position_desktop: modal_position_desktop_val, modal_body_class: 'h-100', modal_transition: 'slide', modal_width: 'full', modal_mobile_full_screen: false, search_modal: true } %}
		{% block modal_body %}
			{% include "snipplets/header/header-search.tpl" with {search_modal: true} %}
		{% endblock %}
	{% endembed %}

{% endif %}

{% set modal_with_desktop_only_overlay_val = false %}

{% set brand_hamburger_nav_tabs = [] %}
{% for item in navigation %}
	{% if item.subitems %}
		{% set brand_hamburger_nav_tabs = brand_hamburger_nav_tabs | merge([item]) %}
	{% endif %}
{% endfor %}
{% set brand_hamburger_drawer_use = settings.brand_hamburger_drawer_enable and brand_hamburger_nav_tabs | length > 0 %}
{% set brand_hamburger_modal_class = 'nav-hamburger modal-docked-md pb-0' ~ (brand_hamburger_drawer_use ? ' brand-hamburger-drawer-modal' : '') %}
{% set brand_hamburger_modal_body_class = brand_hamburger_drawer_use ? 'nav-body brand-hamburger-drawer-body' : 'nav-body' %}

{# Modal Hamburger #}

{% set brand_hamburger_modal_class_toolbar = brand_hamburger_modal_class ~ ' hache-hamburger-has-toolbar' %}
{% embed "snipplets/modal.tpl" with{modal_id: 'nav-hamburger', modal_class: brand_hamburger_modal_class_toolbar, modal_position: modal_position_mobile_val, modal_position_desktop: modal_position_desktop_val, modal_transition: 'slide', modal_width: 'full', modal_mobile_full_screen: false, modal_hide_close: true, modal_header_autoclose: false, modal_header_class: 'border-bottom p-0 hache-hamburger-modal-head', modal_body_class: brand_hamburger_modal_body_class, modal_footer_class: 'hamburger-footer mb-0 p-0', modal_header_title: true, modal_head_col_class: 'text-left p-0', modal_fixed_footer: true, modal_footer: true, desktop_overlay_only: modal_with_desktop_only_overlay_val} %}
	{% block modal_head %}
		{% include 'snipplets/header/header-hamburger-modal-toolbar.tpl' %}
	{% endblock %}
	{% block modal_body %}
		{% if brand_hamburger_drawer_use %}
			{% include 'snipplets/navigation/navigation-brand-hamburger-drawer.tpl' %}
		{% else %}
			{% include "snipplets/navigation/navigation-panel.tpl" with {hamburger: true, primary_links: true} %}
		{% endif %}
	{% endblock %}
	{% block modal_foot %}
			<div class="d-block d-md-none">
				{% include "snipplets/navigation/navigation-panel.tpl" with {mobile: true} %}
			</div>
	{% endblock %}
{% endembed %}

{# Modal Cart #}

{% if not store.is_catalog and settings.ajax_cart and template != 'cart' %}           

	{# Cart Ajax #}

	{% embed "snipplets/modal.tpl" with{
		modal_id: 'modal-cart',
		modal_class: 'cart', 
		modal_position: 'right', 
		modal_position_desktop: 'right', 
		modal_transition: 'slide', 
		modal_width: 'docked-md', 
		modal_form_action: store.cart_url, 
		modal_form_class: 'js-ajax-cart-panel h-100', 
		modal_body_class: 'h-100', 
		modal_header_title: true, 
		modal_mobile_full_screen: true,
		modal_url: 'modal-fullscreen-cart',
		modal_form_hook: 'cart-form', 
		data_component:'cart',
		custom_data_attribute: 'cart-open-type',
		custom_data_attribute_value: settings.cart_open_type,
		desktop_overlay_only: modal_with_desktop_only_overlay_val 
	} %}
		{% block modal_head %}
			{% block page_header_text %}{{ "Carrito de compras" | translate }}{% endblock page_header_text %}
		{% endblock %}
		{% block modal_body %}
			{% snipplet "cart-panel.tpl" %}
		{% endblock %}
	{% endembed %}

	{% if settings.add_to_cart_recommendations %}

		{# Recommended products on add to cart #}

		{% embed "snipplets/modal.tpl" with{modal_id: 'related-products-notification', modal_class: 'bottom modal-overflow-none modal-bottom-sheet h-auto', modal_position: 'bottom', modal_transition: 'slide', modal_header_title: true, modal_footer: false, modal_width: 'centered-md modal-centered-md-600px', modal_body_class: 'modal-scrollable'} %}
			{% block modal_head %}
				{% block page_header_text %}{{ '¡Agregado al carrito!' | translate }}{% endblock page_header_text %}
			{% endblock %}
			{% block modal_body %}

				{# Product added info #}

				{% include "snipplets/notification-cart.tpl" with {related_products: true} %}
				
				{# Product added recommendations #}

				<div class="js-related-products-notification-container" style="display: none"></div>

			{% endblock %}
		{% endembed %}
	{% endif %}

{% endif %}