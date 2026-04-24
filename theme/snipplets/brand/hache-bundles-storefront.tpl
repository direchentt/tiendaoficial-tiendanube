{# Contenedor Hache Suite para combos (hache-suite.js → GET /api/storefront/bundles). Incluir desde category.tpl o pages.combo.tpl. #}
<section class="user-content brand-page-user-content theme-brand-phase1 hs-bundles-page pb-5 pt-md-1">
	<div class="container-fluid">
		<div class="row justify-content-center">
			<div class="col-12 col-lg-11 col-xl-10 brand-page-rail">
				{% if intro_html is defined and intro_html | trim != '' %}
				<div class="user-content-body text-center mb-4 mb-md-5">
					{{ intro_html | raw }}
				</div>
				{% endif %}
				<div id="hs-bundles-container" style="min-height: 200px;">
					<noscript>
						<p class="text-center text-muted">
							Para ver los combos disponibles necesitás tener JavaScript habilitado.
						</p>
					</noscript>
				</div>
			</div>
		</div>
	</div>
</section>

<style>
.hs-bundles-page {
	padding-top: 0.5rem;
}
@media (min-width: 768px) {
	.hs-bundles-page {
		padding-top: 1rem;
	}
}
</style>
