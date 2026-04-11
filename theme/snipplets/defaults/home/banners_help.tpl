{% set slide_view_box = '0 0 1440 770' %}

<section class="section-home section-banners-home" data-store="{{ data_store }}">
	<div class="container-fluid p-0">
		<div class="row no-gutters">
			<div class="col-grid col-md-6">
				<div class="textbanner">
					<div class="textbanner-image p-0 overlay">
						<svg viewBox='{{ slide_view_box }}'><use xlink:href="#slider-slide-placeholder"/></svg>
					</div>
					<div class="textbanner-text over-image">
						<div class="h3-huge h2-huge-md mb-2">{{ banner_title }}</div>
					</div>
					<div class="placeholder-overlay transition-soft">
						<div class="placeholder-info">
							<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
							<div class="placeholder-description font-small-xs">
								{{ help_text }} <strong>"{{ section_name }}"</strong>
							</div>
							{% if not params.preview %}
								<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
							{% endif %}
						</div>
					</div>
				</div>
			</div>
			<div class="col-grid col-md-6">
				<div class="textbanner">
					<div class="textbanner-image p-0 overlay">
						<svg viewBox='{{ slide_view_box }}'><use xlink:href="#slider-slide-placeholder"/></svg>
					</div>
					<div class="textbanner-text over-image">
						<div class="h3-huge h2-huge-md mb-2">{{ banner_title }}</div>
					</div>
					<div class="placeholder-overlay transition-soft">
						<div class="placeholder-info">
							<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
							<div class="placeholder-description font-small-xs">
								{{ help_text }} <strong>"{{ section_name }}"</strong>
							</div>
							{% if not params.preview %}
								<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
							{% endif %}
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</section>