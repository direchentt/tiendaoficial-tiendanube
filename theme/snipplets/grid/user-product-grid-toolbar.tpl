{# Preferencias del visitante: densidad de grilla (localStorage). JS: initUserProductGridPicker en store.js.tpl #}
{% set _gt_for = grid_toolbar_for | default('') %}
{% set _strip = (toolbar_modifier|default('')) == 'user-product-grid-toolbar--nav-strip' %}
<div class="user-product-grid-toolbar{% if toolbar_modifier %} {{ toolbar_modifier }}{% endif %}" role="region" aria-label="{{ 'Como ver los productos' | translate }}"{% if _gt_for %} data-user-grid-toolbar-for="{{ _gt_for }}"{% endif %}>
	{% if _strip %}
		<span class="sr-only">{{ 'Como ver los productos' | translate }}</span>
		<div class="user-product-grid-toolbar__strip d-inline-flex flex-nowrap align-items-center justify-content-center gap-1">
			<div class="user-product-grid-toolbar__chips user-product-grid-toolbar__chips--strip d-inline-flex flex-nowrap align-items-center" role="radiogroup" aria-label="{{ 'En el celular' | translate }}">
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-mobile="1" aria-pressed="false" aria-label="{{ 'En el celular' | translate }}: 1 {{ 'columna' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><rect x="7" y="3" width="10" height="18" rx="1.5" fill="currentColor"/></svg>
				</button>
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-mobile="2" aria-pressed="false" aria-label="{{ 'En el celular' | translate }}: 2 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><rect x="4" y="3" width="7" height="18" rx="1.5" fill="currentColor"/><rect x="13" y="3" width="7" height="18" rx="1.5" fill="currentColor"/></svg>
				</button>
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-mobile="3" aria-pressed="false" aria-label="{{ 'En el celular' | translate }}: 3 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><rect x="3" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/><rect x="9.35" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/><rect x="15.7" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/></svg>
				</button>
			</div>
			<div class="user-product-grid-toolbar__chips user-product-grid-toolbar__chips--strip d-none d-md-inline-flex flex-nowrap align-items-center" role="radiogroup" aria-label="{{ 'En pantalla grande' | translate }}">
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-desktop="2" aria-pressed="false" aria-label="{{ 'En pantalla grande' | translate }}: 2 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><rect x="4" y="3" width="7" height="18" rx="1.5" fill="currentColor"/><rect x="13" y="3" width="7" height="18" rx="1.5" fill="currentColor"/></svg>
				</button>
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-desktop="3" aria-pressed="false" aria-label="{{ 'En pantalla grande' | translate }}: 3 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><rect x="3" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/><rect x="9.35" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/><rect x="15.7" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/></svg>
				</button>
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-desktop="4" aria-pressed="false" aria-label="{{ 'En pantalla grande' | translate }}: 4 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><rect x="2.5" y="3" width="4" height="18" rx="1" fill="currentColor"/><rect x="7.5" y="3" width="4" height="18" rx="1" fill="currentColor"/><rect x="12.5" y="3" width="4" height="18" rx="1" fill="currentColor"/><rect x="17.5" y="3" width="4" height="18" rx="1" fill="currentColor"/></svg>
				</button>
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-desktop="5" aria-pressed="false" aria-label="{{ 'En pantalla grande' | translate }}: 5 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><rect x="1.5" y="3" width="3.2" height="18" rx="0.8" fill="currentColor"/><rect x="5.7" y="3" width="3.2" height="18" rx="0.8" fill="currentColor"/><rect x="9.9" y="3" width="3.2" height="18" rx="0.8" fill="currentColor"/><rect x="14.1" y="3" width="3.2" height="18" rx="0.8" fill="currentColor"/><rect x="18.3" y="3" width="3.2" height="18" rx="0.8" fill="currentColor"/></svg>
				</button>
			</div>
			<button type="button" class="user-product-grid-toolbar__reset user-product-grid-toolbar__reset--icon btn btn-link p-1 d-inline-flex align-items-center" data-user-grid-reset disabled aria-label="{{ 'Restablecer vista' | translate }}">
				<svg class="user-product-grid-toolbar__reset-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true">
					<path d="M3 12a9 9 0 1 0 3-7.1"/>
					<polyline points="3 3 3 9 9 9"/>
				</svg>
			</button>
		</div>
	{% else %}
		<div class="user-product-grid-toolbar__head">
			<span class="user-product-grid-toolbar__title">{{ 'Como ver los productos' | translate }}</span>
			<button type="button" class="user-product-grid-toolbar__reset btn btn-link p-0 d-inline-flex align-items-center" data-user-grid-reset disabled aria-label="{{ 'Restablecer vista' | translate }}">
				<svg class="user-product-grid-toolbar__reset-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true">
					<path d="M3 12a9 9 0 1 0 3-7.1"/>
					<polyline points="3 3 3 9 9 9"/>
				</svg>
				<span class="user-product-grid-toolbar__reset-text d-none d-sm-inline">{{ 'Restablecer vista' | translate }}</span>
			</button>
		</div>

		<div class="user-product-grid-toolbar__row user-product-grid-toolbar__row--mobile d-flex d-md-none" role="group" aria-label="{{ 'En el celular' | translate }}">
			<span class="user-product-grid-toolbar__hint">{{ 'En el celular' | translate }}</span>
			<div class="user-product-grid-toolbar__chips" role="radiogroup" aria-label="{{ 'En el celular' | translate }}">
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-mobile="1" aria-pressed="false" aria-label="{{ 'En el celular' | translate }}: 1 {{ 'columna' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="22" height="22" aria-hidden="true"><rect x="7" y="3" width="10" height="18" rx="1.5" fill="currentColor"/></svg>
				</button>
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-mobile="2" aria-pressed="false" aria-label="{{ 'En el celular' | translate }}: 2 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="22" height="22" aria-hidden="true"><rect x="4" y="3" width="7" height="18" rx="1.5" fill="currentColor"/><rect x="13" y="3" width="7" height="18" rx="1.5" fill="currentColor"/></svg>
				</button>
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-mobile="3" aria-pressed="false" aria-label="{{ 'En el celular' | translate }}: 3 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="22" height="22" aria-hidden="true"><rect x="3" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/><rect x="9.35" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/><rect x="15.7" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/></svg>
				</button>
			</div>
		</div>

		<div class="user-product-grid-toolbar__row user-product-grid-toolbar__row--desktop d-none d-md-flex" role="group" aria-label="{{ 'En pantalla grande' | translate }}">
			<span class="user-product-grid-toolbar__hint">{{ 'En pantalla grande' | translate }}</span>
			<div class="user-product-grid-toolbar__chips" role="radiogroup" aria-label="{{ 'En pantalla grande' | translate }}">
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-desktop="2" aria-pressed="false" aria-label="{{ 'En pantalla grande' | translate }}: 2 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="22" height="22" aria-hidden="true"><rect x="4" y="3" width="7" height="18" rx="1.5" fill="currentColor"/><rect x="13" y="3" width="7" height="18" rx="1.5" fill="currentColor"/></svg>
				</button>
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-desktop="3" aria-pressed="false" aria-label="{{ 'En pantalla grande' | translate }}: 3 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="22" height="22" aria-hidden="true"><rect x="3" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/><rect x="9.35" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/><rect x="15.7" y="3" width="5.3" height="18" rx="1.2" fill="currentColor"/></svg>
				</button>
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-desktop="4" aria-pressed="false" aria-label="{{ 'En pantalla grande' | translate }}: 4 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="22" height="22" aria-hidden="true"><rect x="2.5" y="3" width="4" height="18" rx="1" fill="currentColor"/><rect x="7.5" y="3" width="4" height="18" rx="1" fill="currentColor"/><rect x="12.5" y="3" width="4" height="18" rx="1" fill="currentColor"/><rect x="17.5" y="3" width="4" height="18" rx="1" fill="currentColor"/></svg>
				</button>
				<button type="button" class="user-grid-density-btn js-user-grid-opt" data-user-grid-set-desktop="5" aria-pressed="false" aria-label="{{ 'En pantalla grande' | translate }}: 5 {{ 'columnas' | translate }}">
					<svg class="user-grid-density-icon" viewBox="0 0 24 24" width="22" height="22" aria-hidden="true"><rect x="1.5" y="3" width="3.2" height="18" rx="0.8" fill="currentColor"/><rect x="5.7" y="3" width="3.2" height="18" rx="0.8" fill="currentColor"/><rect x="9.9" y="3" width="3.2" height="18" rx="0.8" fill="currentColor"/><rect x="14.1" y="3" width="3.2" height="18" rx="0.8" fill="currentColor"/><rect x="18.3" y="3" width="3.2" height="18" rx="0.8" fill="currentColor"/></svg>
				</button>
			</div>
		</div>
	{% endif %}
</div>
