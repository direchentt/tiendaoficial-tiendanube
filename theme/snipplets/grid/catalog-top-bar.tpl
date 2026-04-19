{# Categoría / búsqueda: móvil = isla flotante vidrio (Filtrar / Ordenar); escritorio = pastillas de orden solo si filtros en modal; beneficios. #}
{% if products %}
	{% set _benefit_flag = attribute(settings, 'catalog_benefits_bar_show') | default(1) %}
	{% set show_benefits_bar = _benefit_flag is not same as(false)
		and _benefit_flag is not same as(0)
		and _benefit_flag is not same as('0')
		and _benefit_flag is not same as('') %}
	{% set use_filters_modal_desktop = settings.filters_desktop_modal | default(false) %}
	{% set has_filters_available = has_filters_available | default(false) %}
	{% set _dock_raw = attribute(settings, 'catalog_mobile_filter_dock_float') | default(1) %}
	{% set use_mobile_filter_dock_float = _dock_raw is not same as(false)
		and _dock_raw is not same as(0)
		and _dock_raw is not same as('0')
		and _dock_raw is not same as('') %}
	{% set sort_is_non_default = false %}
	{% for m in sort_methods|default([]) %}
		{% if m.selected|default(false) and loop.index0 > 0 %}
			{% set sort_is_non_default = true %}
		{% endif %}
	{% endfor %}
	{% set catalog_list_applied = has_applied_filters or sort_is_non_default %}
	{% set _fdd_raw = attribute(settings, 'catalog_filter_dock_float_desktop') | default(1) %}
	{% set use_filter_dock_float_desktop = _fdd_raw is not same as(false)
		and _fdd_raw is not same as(0)
		and _fdd_raw is not same as('0')
		and _fdd_raw is not same as('') %}
	{% set fin_legend = (settings.catalog_financing_legend | default('')) | trim %}
	{% set store_benefit_max_installments = 0 %}
	{% set store_benefit_transfer_pct = 0 %}
	{% for p in products %}
		{% if p.display_price and p.show_installments %}
			{% set _inst_n = 0 %}
			{% set _msi_sin_int = p.get_max_installments(false) %}
			{% if _msi_sin_int and _msi_sin_int.installment is defined %}
				{% set _inst_n = _msi_sin_int.installment %}
			{% elseif p.get_max_installments and p.get_max_installments.installment is defined %}
				{% set _inst_n = p.get_max_installments.installment %}
			{% endif %}
			{% if _inst_n > store_benefit_max_installments %}
				{% set store_benefit_max_installments = _inst_n %}
			{% endif %}
		{% endif %}
		{% if p.maxPaymentDiscount is defined and p.maxPaymentDiscount.value is defined and p.maxPaymentDiscount.value > store_benefit_transfer_pct %}
			{% set store_benefit_transfer_pct = p.maxPaymentDiscount.value %}
		{% endif %}
	{% endfor %}
	{% set show_benefit_installments_row = store_benefit_max_installments > 1 %}
	{% set show_benefit_transfer_row = store_benefit_transfer_pct > 0 %}
	{% set benefit_slide_count = (show_benefit_installments_row ? 1 : 0) + 1 + (show_benefit_transfer_row ? 1 : 0) %}
	{% set _legend_tick = fin_legend != '' %}
	{% set benefit_tick_count = benefit_slide_count + (_legend_tick ? 1 : 0) %}
	{% set benefits_use_mobile_ticker = benefit_tick_count > 1 %}
	{% set benefit_tick_first = benefits_use_mobile_ticker %}
	{% set _fs_min = cart is defined and cart.free_shipping.min_price_free_shipping.min_price ? cart.free_shipping.min_price_free_shipping.min_price : false %}
	<div class="catalog-top-bar w-100 visible-when-content-ready{% if not use_mobile_filter_dock_float %} catalog-top-bar--dock-inline{% endif %}{% if use_filter_dock_float_desktop %} catalog-top-bar--float-desktop{% endif %}" data-catalog-top-bar data-catalog-dock-float="{{ use_mobile_filter_dock_float ? '1' : '0' }}" data-catalog-dock-float-desktop="{{ use_filter_dock_float_desktop ? '1' : '0' }}">
		<div class="catalog-top-bar__inner">
			{# —— Móvil: isla vidrio (fija al pie o inline según panel); mismo vidrio carbon que beneficios / modales —— #}
			<div class="catalog-top-bar__float{% if not use_filter_dock_float_desktop %} d-md-none{% endif %}{% if not use_mobile_filter_dock_float %} catalog-top-bar__float--inline{% endif %}{% if use_filter_dock_float_desktop %} catalog-top-bar__float--desktop{% endif %}" data-catalog-controls-dock>
				<div class="catalog-top-bar__glass-pill{% if catalog_list_applied %} is-active{% endif %}" role="toolbar" aria-label="{{ 'Filtros y orden del listado' | translate }}">
					{% if has_filters_available %}
						<a href="#" role="button" class="catalog-top-bar__glass-btn catalog-top-bar__glass-btn--solo js-modal-open{% if catalog_list_applied %} is-active{% endif %}" data-toggle="#nav-filters" data-component="filter-button" aria-haspopup="dialog">
							<span class="catalog-top-bar__glass-btn-icon" aria-hidden="true">
								<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 6h16M7 12h10M10 18h4"/></svg>
							</span>
							<span class="catalog-top-bar__glass-btn-text">{{ 'Filtrar y ordenar' | translate }}</span>
							{% if has_applied_filters %}
								<span class="catalog-top-bar__glass-badge" aria-hidden="true">(<span class="js-filters-total-badge"></span>)</span>
							{% endif %}
						</a>
					{% else %}
						<a href="#" role="button" class="catalog-top-bar__glass-btn catalog-top-bar__glass-btn--solo js-modal-open{% if catalog_list_applied %} is-active{% endif %}" data-toggle="#sort-by" aria-haspopup="dialog">
							<span class="catalog-top-bar__glass-btn-text">{{ 'Ordenar' | translate }}</span>
							<span class="catalog-top-bar__glass-sort-ico" aria-hidden="true">
								<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M7 4v16M4 7l3-3 3 3M17 20V4M14 17l3 3 3-3"/></svg>
							</span>
						</a>
					{% endif %}
				</div>
			</div>

			{# —— Escritorio: una sola barra — titulo unico + boton Filtros (modal) + pastillas de orden —— #}
			{% if use_filters_modal_desktop and not use_filter_dock_float_desktop %}
				<div class="catalog-top-bar__desktop-toolbar d-none d-md-block">
					<div class="catalog-toolbar-unified" data-catalog-toolbar-unified role="region" aria-label="{{ 'Filtrar y ordenar' | translate }}">
						<h2 class="catalog-toolbar-unified__title mb-0">{{ has_filters_available ? ('Filtrar y ordenar' | translate) : ('Ordenar' | translate) }}</h2>
						<div class="catalog-toolbar-unified__row">
							{% if has_filters_available %}
								<a href="#" role="button" class="catalog-toolbar-unified__filter js-modal-open{% if catalog_list_applied %} is-active{% endif %}" data-toggle="#nav-filters" data-component="filter-button" aria-haspopup="dialog" aria-label="{{ 'Filtrar y ordenar' | translate }}">
									<span class="catalog-toolbar-unified__filter-icon" aria-hidden="true">
										<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 6h16M7 12h10M10 18h4"/></svg>
									</span>
									<span class="catalog-toolbar-unified__filter-text">{{ 'Filtros' | translate }}</span>
									{% if has_applied_filters %}
										<span class="catalog-toolbar-unified__badge" aria-label="{{ 'Filtros' | translate }}"><span class="js-filters-total-badge"></span></span>
									{% endif %}
								</a>
							{% endif %}
							<div class="catalog-toolbar-unified__sort-wrap{% if not has_filters_available %} catalog-toolbar-unified__sort-wrap--solo{% endif %}">
								{{ component(
									'sort-by',{
										list: true,
										sort_by: sort_by,
										sort_methods: sort_methods,
										sort_by_classes: {
											container: 'native-sort-pills-wrap mb-0',
											group: 'native-sort-pills-group',
											list_title: has_filters_available ? 'native-sort-pills-heading catalog-toolbar-unified__sort-sr-only' : 'native-sort-pills-heading',
											list: 'radio-button-container list-unstyled native-sort-pills native-sort-pills-scroll my-0',
											list_item: 'radio-button-item native-sort-pills__item',
											radio_button: 'radio-button',
											radio_button_content: 'radio-button-content',
											radio_button_icons_container: 'radio-button-icons-container',
											radio_button_icon: 'radio-button-icon',
											radio_button_label: 'radio-button-label',
											applying_feedback_message: 'font-big mr-2',
											applying_feedback_icon: 'icon-inline font-big icon-spin svg-icon-text',
										},
										applying_feedback_svg_id: 'spinner-third',
									})
								}}
							</div>
						</div>
					</div>
					<div class="js-sorting-overlay filters-overlay" style="display: none;">
						<div class="filters-updating-message">
							<span class="h5 mr-2">{{ 'Ordenando productos' | translate }}</span>
							<span>
								<svg class="icon-inline h5 icon-spin svg-icon-text"><use xlink:href="#spinner-third"/></svg>
							</span>
						</div>
					</div>
				</div>
			{% endif %}

			{% if show_benefits_bar %}
				<div class="catalog-benefits-bar catalog-benefits-bar--glass catalog-benefits-bar--count-{{ benefit_slide_count }}{% if benefits_use_mobile_ticker %} catalog-benefits-bar--ticker-mobile{% endif %}" role="region" aria-label="{{ 'Beneficios de compra' | translate }}" data-benefit-slides="{{ benefit_slide_count }}"{% if benefits_use_mobile_ticker %} data-catalog-benefits-ticker="1"{% endif %}>
					<div class="catalog-benefits-bar__track"{% if benefits_use_mobile_ticker %} aria-live="polite"{% endif %}>
						{% if show_benefit_installments_row %}
						<div class="catalog-benefits-bar__item{% if benefit_tick_first %} is-active{% endif %}"{% if benefits_use_mobile_ticker %} data-benefit-tick="1"{% endif %}>
							{% if benefit_tick_first %}{% set benefit_tick_first = false %}{% endif %}
							<svg class="catalog-benefits-bar__icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.35" aria-hidden="true">
								<rect x="2.5" y="5" width="19" height="14" rx="2"/>
								<path d="M2.5 10h19"/>
							</svg>
							<p class="catalog-benefits-bar__text mb-0">
								{{ 'Hasta' | translate }} <strong>{{ store_benefit_max_installments }} {{ 'cuotas sin interés' | translate }}</strong>
							</p>
						</div>
						{% endif %}
						<div class="catalog-benefits-bar__item{% if benefit_tick_first %} is-active{% endif %}"{% if benefits_use_mobile_ticker %} data-benefit-tick="1"{% endif %}>
							{% if benefit_tick_first %}{% set benefit_tick_first = false %}{% endif %}
							<svg class="catalog-benefits-bar__icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.35" aria-hidden="true">
								<path d="M4 7h16v10H4z"/>
								<path d="M4 11h16"/>
								<path d="M8 15h4"/>
							</svg>
							<p class="catalog-benefits-bar__text mb-0">
								{% if _fs_min %}
									{{ 'Envío gratis desde' | translate }} <strong>{{ _fs_min }}</strong>
								{% else %}
									{{ 'Envíos a todo el país — detalle en checkout.' | translate }}
								{% endif %}
							</p>
						</div>
						{% if show_benefit_transfer_row %}
						<div class="catalog-benefits-bar__item{% if benefit_tick_first %} is-active{% endif %}"{% if benefits_use_mobile_ticker %} data-benefit-tick="1"{% endif %}>
							{% if benefit_tick_first %}{% set benefit_tick_first = false %}{% endif %}
							<svg class="catalog-benefits-bar__icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.35" aria-hidden="true">
								<path d="M20 6L9 17l-5-5"/>
							</svg>
							<p class="catalog-benefits-bar__text mb-0">
								<strong>{{ store_benefit_transfer_pct }}% OFF</strong> {{ 'con transferencia' | translate }}
							</p>
						</div>
						{% endif %}
						{% if benefits_use_mobile_ticker and _legend_tick %}
						<div class="catalog-benefits-bar__item catalog-benefits-bar__item--tick-legend d-md-none" data-benefit-tick="1">
							<p class="catalog-benefits-bar__text catalog-benefits-bar__text--legend-tick mb-0">{{ fin_legend }}</p>
						</div>
						{% endif %}
					</div>
					{% if fin_legend != '' %}
						<p class="catalog-benefits-bar__legend mb-0{% if benefits_use_mobile_ticker %} d-none d-md-block{% endif %}">{{ fin_legend }}</p>
					{% endif %}
				</div>
			{% endif %}
		</div>
	</div>
{% endif %}
