{# Landing Spoti-Fy: iframe al Astro desplegado (HTTPS). La pagina TN usa el handle configurado en settings. #}
{% set _src = (settings.brand_spotify_landing_url | default('')) | trim | trim(' /') %}
{% set _ok = _src|slice(0, 8) == 'https://' %}

<section class="brand-spoti-fy-landing user-content brand-page-user-content pb-0 pt-md-0" data-store="brand-spoti-fy-landing">
	{% if _ok %}
		<p class="sr-only">{{ page.name }}</p>
		<div class="brand-spoti-fy-embed-wrap">
			<iframe
				class="brand-spoti-fy-iframe"
				title="{{ page.name|e('html_attr') }}"
				src="{{ _src|e('html_attr') }}"
				loading="lazy"
				referrerpolicy="strict-origin-when-cross-origin"
				allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture"
			></iframe>
		</div>
	{% else %}
		<div class="container-fluid py-5">
			<div class="row justify-content-center">
				<div class="col-12 col-lg-10 col-xl-8 brand-page-rail">
					<p class="mb-3">{{ 'Para ver la landing Spoti-Fy, configurá en el personalizador del tema la URL HTTPS donde está publicado el proyecto (por ejemplo Vercel), sin barra al final.' | translate }}</p>
					{% if page.content %}
						<div class="user-content-body">{{ page.content }}</div>
					{% endif %}
				</div>
			</div>
		</div>
	{% endif %}
</section>
