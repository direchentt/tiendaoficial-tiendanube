{# Contenedor Hache Suite para combos (hache-suite.js → GET /api/storefront/bundles). Incluir desde category.tpl o pages.combo.tpl. #}
{% set is_pas_normal = bundle_mode is defined and bundle_mode == 'pas-normal' %}
<section class="user-content brand-page-user-content theme-brand-phase1 hs-bundles-page{% if is_pas_normal %} hs-bundles-page--pas-normal{% endif %} pb-5 pt-md-1">
	<div class="container-fluid">
		<div class="row justify-content-center">
			<div class="col-12 col-lg-11 col-xl-10 brand-page-rail">
				{% if intro_html is defined and intro_html | trim != '' %}
				<div class="user-content-body{% if is_pas_normal %} text-left mb-3 mb-md-4 hs-bundles-page__intro{% else %} text-center mb-4 mb-md-5{% endif %}">
					{{ intro_html | raw }}
				</div>
				{% endif %}
				<div
					id="hs-bundles-container"
					style="min-height: 200px;"
					{% if bundle_landing_slug is defined and bundle_landing_slug | trim != '' %}
					data-bundle-landing-slug="{{ bundle_landing_slug | trim | e('html_attr') }}"
					{% endif %}
				>
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

/* Bundle landing: look inspired by Pas Normal product bundle builder. */
.hs-bundles-page--pas-normal {
  padding-top: 0;
  letter-spacing: 0;
}

.hs-bundles-page--pas-normal .brand-page-rail {
  max-width: 100%;
  flex: 0 0 100%;
  width: 100%;
}

.hs-bundles-page--pas-normal .hs-bundles-page__intro {
  max-width: 62rem;
  margin-left: 0;
  margin-bottom: 0.75rem;
  font-size: 0.78rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-v2-landing-head {
  max-width: 62rem;
  margin-bottom: 1rem;
}
.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-v2-landing-title {
  font-size: 1.05rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  margin: 0 0 0.35rem;
  font-weight: 600;
}
.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-v2-landing-intro {
  font-size: 0.82rem;
  line-height: 1.5;
  color: #4a4a4a;
  margin: 0;
  max-width: 52rem;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.25rem;
  padding-top: 0;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-card {
  border-radius: 0;
  border: 1px solid rgba(0, 0, 0, 0.08);
  box-shadow: none;
  transform: none;
  background: #fff;
  overflow: hidden;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-card:hover {
  transform: none;
  box-shadow: none;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-media,
.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-placeholder {
  width: 100%;
  min-height: 22rem;
  height: clamp(22rem, 52vw, 40rem);
  object-fit: cover;
  border-radius: 0;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-body {
  padding: 1.15rem 1.2rem 1.25rem;
  display: flex;
  flex-direction: column;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-title {
  font-size: 0.98rem;
  line-height: 1.35;
  letter-spacing: 0.03em;
  text-transform: uppercase;
  font-weight: 700;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-desc {
  font-size: 0.78rem;
  line-height: 1.5;
  color: #494949;
  margin-top: 0.45rem;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-list {
  margin-top: 0.65rem;
  border-top: 1px solid rgba(0, 0, 0, 0.09);
  padding-top: 0.5rem;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-row {
  font-size: 0.71rem;
  letter-spacing: 0.02em;
  color: #222;
  padding: 0.35rem 0;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-row-thumb {
  border-radius: 0;
  width: 18px;
  height: 18px;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-variant {
  border-radius: 0;
  border: 1px solid rgba(0, 0, 0, 0.2);
  background: #fff;
  color: #111;
  font-size: 0.7rem;
  height: 28px;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-price-old {
  font-size: 0.76rem;
  color: #7a7a7a;
  margin-top: 0.3rem;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-price-new {
  font-size: 1rem;
  letter-spacing: 0.01em;
  font-weight: 500;
  margin-top: 0.05rem;
  margin-bottom: 0.7rem;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-btn {
  border-radius: 0;
  background: #111;
  color: #fff;
  box-shadow: none;
  text-transform: uppercase;
  font-size: 0.72rem;
  letter-spacing: 0.08em;
  min-height: 40px;
}

.hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-btn:hover {
  opacity: 0.92;
  transform: none;
}

@media (min-width: 992px) {
  .hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-card {
    display: grid;
    grid-template-columns: minmax(0, 56%) minmax(0, 44%);
    align-items: stretch;
  }

  .hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-body {
    padding: 1.2rem 1.15rem 1.15rem;
  }

  .hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-media,
  .hs-bundles-page--pas-normal #hs-bundles-container .hs-bundle-placeholder {
    height: 100%;
    min-height: 34rem;
  }
}
</style>
