{% set slide_view_box = '0 0 1440 770' %}

<section class="section-home section-testimonials-home position-relative overflow-none" data-store="home-testimonials">
	<div class="container-fluid">
		<div class="js-swiper-testimonials-demo swiper-testimonials swiper-container">
			<div class="swiper-buttons position-relative p-0 ml-neg-2">
				<div class="js-swiper-testimonials-prev-demo swiper-button-prev svg-icon-text mb-2">
					<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
				</div>
				<div class="js-swiper-testimonials-next-demo swiper-button-next svg-icon-text mb-2">
					<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
				</div>
			</div>
			<div class="swiper-wrapper">
				<div class="swiper-slide p-0">
					<div class="mb-3">1 / 2</div>
					<p class="font-huge mb-3">{{ 'Descripción del testimonio' | translate }}</p>
					<div class="row justify-content-end mt-3 mb-4">
						<div class="col-auto">
							<div class="testimonial-quote">”</div>
						</div>
					</div>
					<h3 class="font-family-body font-body mb-2">{{ 'Testimonio' | translate }}</h3>
				</div>
				<div class="swiper-slide p-0">
					<div class="mb-3">1 / 2</div>
					<p class="font-huge mb-3">{{ 'Descripción del testimonio' | translate }}</p>
					<div class="row justify-content-end mt-3 mb-4">
						<div class="col-auto">
							<div class="testimonial-quote">”</div>
						</div>
					</div>
					<h3 class="font-family-body font-body mb-2">{{ 'Testimonio' | translate }}</h3>
				</div>
			</div>
		</div>
	</div>
	<div class="placeholder-overlay transition-soft">
		<div class="placeholder-info">
			<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
			<div class="placeholder-description font-small-xs">
				{{ "Podés mostrar testimonios de tus clientes desde" | translate }} <strong>"{{ "Testimonios" | translate }}"</strong>
			</div>
			{% if not params.preview %}
				<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
			{% endif %}
		</div>
	</div>
</section>