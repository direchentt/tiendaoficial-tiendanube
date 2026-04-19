<style>
	.account-premium-split { display: flex; min-height: 85vh; align-items: stretch; flex-wrap: wrap; margin-top: -15px; }
	.account-media-side { flex: 1 1 45%; position: relative; min-height: 300px; background-color: #111; overflow: hidden; }
	.account-media-side video, .account-media-side .media-bg { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; background-position: center; background-size: cover; }
	.account-form-side { flex: 1 1 55%; display: flex; flex-direction: column; justify-content: center; padding: 8%; background: #ffffff; }
	.premium-form-wrapper { max-width: 480px; width: 100%; margin: 0 auto; }
	.premium-form-title { font-family: var(--font-headings, sans-serif); font-weight: 600; font-size: 2.8rem; color: #111; line-height: 1.1; margin-bottom: 12px; letter-spacing: -0.01em; }
	.premium-form-subtitle { font-family: var(--font-body, sans-serif); font-size: 1.1rem; color: #555; line-height: 1.5; margin-bottom: 45px; }
	@media (max-width: 767px) {
		.account-premium-split { flex-direction: column; min-height: auto; }
		.account-media-side { flex: 0 0 220px; min-height: 220px; }
		.account-form-side { padding: 50px 25px; }
		.premium-form-title { font-size: 2.2rem; }
	}
</style>

<section class="account-premium-split">
	<div class="account-media-side">
		{% if settings.login_split_video_url|trim %}
			<video autoplay muted loop playsinline>
				<source src="{{ settings.login_split_video_url }}" type="video/mp4">
			</video>
		{% elseif "login_split_background.jpg" | has_custom_image %}
			<div class="media-bg" style="background-image: url('{{ "login_split_background.jpg" | static_url | settings_image_url("large") }}');"></div>
		{% else %}
			{# Fallback placeholder premium #}
			<div class="media-bg" style="background-image: url('https://d3ugyf2ht6aenh.cloudfront.net/stores/003/996/535/themes/zestful/1-slide-1736630048600-2410298642-a8ceb466139cdedb700f135b34a6aa791736630049.webp');"></div>
		{% endif %}
		<div style="position:absolute;inset:0;background:rgba(0,0,0,0.15);"></div>
	</div>
	
	<div class="account-form-side">
		<div class="premium-form-wrapper">
			<h1 class="premium-form-title">
				{% if settings.login_premium_title %}
					{{ settings.login_premium_title }}
				{% else %}
					Bienvenido a tu espacio.
				{% endif %}
			</h1>
			<p class="premium-form-subtitle">
				{% if settings.login_premium_subtitle %}
					{{ settings.login_premium_subtitle }}
				{% else %}
					Si necesitás algo, estamos acá para ayudarte a encontrar exactamente lo que buscás.
				{% endif %}
			</p>

			{{ component('forms/account/login' , {
					validation_classes: {
						link: 'btn-link font-small ml-1',
						text_align: 'text-left',
						text_size: 'font-small',
					},
					spacing_classes: {
						top_2x: 'mt-2',
						bottom_2x: 'mb-2',
						bottom_3x: 'mb-3',
						bottom_4x: 'mb-4',
					},
					form_classes: {
						facebook_login: 'btn btn-secondary btn-big d-block mb-4',
						password_toggle: 'btn',
						input_help_align: 'text-right',
						input_help_link: 'btn-link font-small mb-2',
						help_align: 'text-left',
						help_text_size: 'font-small',
						help_link: 'btn-link font-small mb-2 font-weight-bold',
						submit: 'btn btn-primary btn-big btn-block mb-3 border-radius-0 text-uppercase',
						submit_spinner: 'icon-inline icon-spin svg-icon-mask ml-2'
					}})
			}}
		</div>
	</div>
</section>