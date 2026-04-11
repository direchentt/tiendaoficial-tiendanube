<section class="section-instafeed-home position-relative overflow-none py-2 py-md-5" data-store="home-instagram-feed">
	<div class="container-fluid">
		<div class="row">
			<div class="col-md-3">
				<div class="instafeed-title instafeed-title mb-0">
					<h2 class="h3-huge h2-huge-md section-title mb-0">@{{ 'Instagram' | translate }}</h2>
				</div>
			</div>
			<div class="col-md-9">
				<div id="instafeed" class="row row-grid">
					{% include 'snipplets/defaults/help_instagram.tpl' with {'help_item_1': true} %}
					{% include 'snipplets/defaults/help_instagram.tpl' with {'help_item_2': true} %}
					{% include 'snipplets/defaults/help_instagram.tpl' with {'help_item_1': true} %}
				</div>
			</div>
		</div>
	</div>
	<div class="placeholder-overlay transition-soft">
		<div class="placeholder-info">
			<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
			<div class="placeholder-description font-small-xs">
				{{ "Podés mostrar tus últimas novedades desde" | translate }} <strong>"{{ "Publicaciones de Instagram" | translate }}"</strong>
			</div>
			{% if not params.preview %}
				<a href="{{ admin_link }}#instatheme=redes-sociales" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
			{% endif %}
		</div>
	</div>
</section>