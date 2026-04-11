{# Brands that work as examples #}

{% set brand_logo_view_box = '0 0 576 512' %}

<section class="section-home section-brands-home position-relative overflow-none" data-store="home-brands">
	<div class="container-fluid pt-4">
		<div class="row justify-content-center">
			<div class="col-md-1-5 col-4 mb-3 brand-image-container text-center">
				<svg class="icon-inline icon-4x brand-image svg-icon-text opacity-50" viewBox="{{ brand_logo_view_box }}"><use xlink:href="#help-logo"/></svg>
			</div>
			<div class="col-md-1-5 col-4 mb-3 brand-image-container text-center">
				<svg class="icon-inline icon-4x brand-image svg-icon-text opacity-50" viewBox="{{ brand_logo_view_box }}"><use xlink:href="#help-logo"/></svg>
			</div>
			<div class="col-md-1-5 col-4 mb-3 brand-image-container text-center">
				<svg class="icon-inline icon-4x brand-image svg-icon-text opacity-50" viewBox="{{ brand_logo_view_box }}"><use xlink:href="#help-logo"/></svg>
			</div>
			<div class="col-md-1-5 col-4 mb-3 brand-image-container text-center">
				<svg class="icon-inline icon-4x brand-image svg-icon-text opacity-50" viewBox="{{ brand_logo_view_box }}"><use xlink:href="#help-logo"/></svg>
			</div>
			<div class="col-md-1-5 col-4 mb-3 brand-image-container text-center">
				<svg class="icon-inline icon-4x brand-image svg-icon-text opacity-50" viewBox="{{ brand_logo_view_box }}"><use xlink:href="#help-logo"/></svg>
			</div>
			<div class="col-md-1-5 col-4 mb-3 brand-image-container text-center">
				<svg class="icon-inline icon-4x brand-image svg-icon-text opacity-50" viewBox="{{ brand_logo_view_box }}"><use xlink:href="#help-logo"/></svg>
			</div>
		</div>
		<div class="placeholder-overlay transition-soft">
			<div class="placeholder-info p-2">
				<svg class="icon-inline icon-2x"><use xlink:href="#edit"/></svg>
				<div class="placeholder-description font-small-xs my-2">
					{{ "Podés subir logos de tus marcas desde" | translate }} </br><strong>"{{ "Marcas" | translate }}"</strong>
				</div>
				{% if not params.preview %}
					<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
				{% endif %}
			</div>
		</div>
	</div>
</section>
