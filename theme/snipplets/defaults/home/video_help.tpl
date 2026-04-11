<section class="section-video-home" data-store="home-video">
	<div class="home-video embed-responsive embed-responsive-16by9">
		<svg viewBox="0 0 1130 635.63"><use xlink:href="#video-placeholder"/></svg>
		<div class="placeholder-overlay transition-soft">
		<div class="placeholder-info">
				<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
				<div class="placeholder-description font-small-xs">
					{{ "Podés subir tu video de YouTube desde" | translate }} <strong>"{{ "Video" | translate }}"</strong>
				</div>
				{% if not params.preview %}
					<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
				{% endif %}
			</div>
		</div>
	</div>
</section>