{# Preferencias del visitante: columnas por fila (localStorage). Ver store.js initUserProductGridPicker. #}
<div class="user-product-grid-toolbar mb-2 pb-2" role="region" aria-label="{{ 'Como ver los productos' | translate }}">
	<div class="d-flex flex-wrap align-items-center justify-content-between gap-2">
		<span class="font-small font-weight-bold">{{ 'Como ver los productos' | translate }}</span>
		<button type="button" class="btn btn-link btn-sm py-0 px-1 text-underline" data-user-grid-reset disabled>{{ 'Restablecer vista' | translate }}</button>
	</div>
	<div class="d-flex flex-wrap align-items-center mt-2 gap-2">
		<span class="font-smallest text-muted text-uppercase" style="letter-spacing:0.06em;">{{ 'En el celular' | translate }}</span>
		<div class="btn-group btn-group-sm" role="group" aria-label="{{ 'En el celular' | translate }}">
			<button type="button" class="btn btn-outline-secondary px-2 js-user-grid-opt" data-user-grid-set-mobile="1" aria-pressed="false" title="1 {{ 'columna' | translate }}">1</button>
			<button type="button" class="btn btn-outline-secondary px-2 js-user-grid-opt" data-user-grid-set-mobile="2" aria-pressed="false" title="2 {{ 'columnas' | translate }}">2</button>
			<button type="button" class="btn btn-outline-secondary px-2 js-user-grid-opt" data-user-grid-set-mobile="3" aria-pressed="false" title="3 {{ 'columnas' | translate }}">3</button>
		</div>
	</div>
	<div class="d-flex flex-wrap align-items-center mt-2 gap-2">
		<span class="font-smallest text-muted text-uppercase" style="letter-spacing:0.06em;">{{ 'En pantalla grande' | translate }}</span>
		<div class="btn-group btn-group-sm" role="group" aria-label="{{ 'En pantalla grande' | translate }}">
			<button type="button" class="btn btn-outline-secondary px-2 js-user-grid-opt" data-user-grid-set-desktop="2" aria-pressed="false" title="2 {{ 'columnas' | translate }}">2</button>
			<button type="button" class="btn btn-outline-secondary px-2 js-user-grid-opt" data-user-grid-set-desktop="3" aria-pressed="false" title="3 {{ 'columnas' | translate }}">3</button>
			<button type="button" class="btn btn-outline-secondary px-2 js-user-grid-opt" data-user-grid-set-desktop="4" aria-pressed="false" title="4 {{ 'columnas' | translate }}">4</button>
			<button type="button" class="btn btn-outline-secondary px-2 js-user-grid-opt" data-user-grid-set-desktop="5" aria-pressed="false" title="5 {{ 'columnas' | translate }}">5</button>
		</div>
	</div>
</div>
