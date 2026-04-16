{# Reusable block: video + optional overlay (kicker/title/buttons).
   Params:
   - block_raw_url (required)
   - block_kicker, block_title
   - block_btn1, block_btn1_url
   - block_btn2, block_btn2_url
   - block_autoplay (bool)
   - block_muted (bool)
   - block_video_class (optional extra class for <video>)
#}
{% set raw = block_raw_url|default('')|trim %}
{% if raw %}
	{% set has_btn1 = block_btn1|default('')|trim and block_btn1_url|default('')|trim %}
	{% set has_btn2 = block_btn2|default('')|trim and block_btn2_url|default('')|trim %}
	{% set has_overlay = block_kicker|default('')|trim or block_title|default('')|trim or has_btn1 or has_btn2 %}

	<div class="brand-split-video__cell">
		<div class="brand-split-video__media">
			{% include 'snipplets/brand/brand-video-media.tpl' with {
				video_raw_url: raw,
				video_autoplay: block_autoplay|default(false),
				video_muted: block_muted|default(false),
				video_class: block_video_class|default('')|trim
			} %}
		</div>
		{% if has_overlay %}
			<div class="brand-split-video__overlay">
				<div class="brand-split-video__overlay-inner">
					{% if block_kicker|default('')|trim %}
						<p class="brand-split-video__kicker">{{ block_kicker }}</p>
					{% endif %}
					{% if block_title|default('')|trim %}
						<h2 class="brand-split-video__title">{{ block_title }}</h2>
					{% endif %}
					{% if has_btn1 or has_btn2 %}
						<div class="brand-split-video__actions">
							{% if has_btn1 %}
								<a href="{{ block_btn1_url }}" class="brand-split-video__btn">{{ block_btn1 }}</a>
							{% endif %}
							{% if has_btn2 %}
								<a href="{{ block_btn2_url }}" class="brand-split-video__btn">{{ block_btn2 }}</a>
							{% endif %}
						</div>
					{% endif %}
				</div>
			</div>
		{% endif %}
	</div>
{% endif %}
