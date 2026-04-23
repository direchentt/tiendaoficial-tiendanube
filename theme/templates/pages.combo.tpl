{% embed "snipplets/page-header.tpl" %}
	{% block page_header_text %}{{ page.name | default("Combos") }}{% endblock page_header_text %}
{% endembed %}

{# Página especial de Bundles/Combos — renderizada por hache-suite.js #}

<section class="user-content brand-page-user-content theme-brand-phase1 hs-bundles-page pb-5 pt-md-1">
	<div class="container-fluid">
		<div class="row justify-content-center">
			<div class="col-12 col-lg-11 col-xl-10 brand-page-rail">

				{# Intro text (editable desde el admin de TN en el campo de contenido de la página) #}
				{% if page.content %}
				<div class="user-content-body text-center mb-4 mb-md-5">
					{{ page.content }}
				</div>
				{% endif %}

				{#
					Contenedor donde hache-suite.js inyecta las cards de bundles.
					El script detecta este id="hs-bundles-container" para saber que está en la página de combos.
				#}
				<div id="hs-bundles-container" style="min-height: 200px;">
					{# Fallback si JS no carga #}
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
