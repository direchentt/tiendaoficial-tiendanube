{# Reusable video renderer for brand sections.
   Params:
   - video_raw_url (required)
   - video_autoplay (bool)
   - video_muted (bool)
   - video_class (optional extra class for <video>)
#}
{% set raw = video_raw_url|default('')|trim %}
{% if raw %}
	{% set lower = raw|lower %}
	{% set embed_type = 'iframe' %}
	{% set embed_src = '' %}
	{% set yt_id = '' %}
	{% set video_extra_class = video_class|default('')|trim %}
	{% set is_file =
		(lower|split('.mp4')|length > 1) or
		(lower|split('.webm')|length > 1) or
		(lower|split('.m4v')|length > 1) or
		(lower|split('.mov')|length > 1) or
		(lower|split('.ogv')|length > 1)
	%}

	{% if is_file %}
		{% set embed_type = 'file' %}
	{% elseif 'youtube.com/embed/' in raw %}
		{% set embed_src = raw %}
	{% elseif 'player.vimeo.com/video/' in raw %}
		{% set embed_src = raw %}
	{% elseif '/watch?v=' in raw %}
		{% set yt_id = raw|split('/watch?v=')|last|split('&')|first %}
		{% set embed_src = 'https://www.youtube.com/embed/' ~ yt_id %}
	{% elseif 'youtu.be/' in raw %}
		{% set yt_id = raw|split('youtu.be/')|last|split('?')|first %}
		{% set embed_src = 'https://www.youtube.com/embed/' ~ yt_id %}
	{% elseif '/shorts/' in raw %}
		{% set yt_id = raw|split('/shorts/')|last|split('?')|first %}
		{% set embed_src = 'https://www.youtube.com/embed/' ~ yt_id %}
	{% elseif 'vimeo.com/' in raw %}
		{% set vm = raw|split('vimeo.com/')|last|split('?')|first|split('/')|last %}
		{% set embed_src = 'https://player.vimeo.com/video/' ~ vm %}
	{% elseif raw|length > 7 and (raw|slice(0, 8) == 'https://' or raw|slice(0, 7) == 'http://') %}
		{% set embed_src = raw %}
	{% else %}
		{% set embed_type = 'link' %}
	{% endif %}

	{% if embed_type == 'iframe' and embed_src and video_autoplay %}
		{% set sep = '?' in embed_src ? '&' : '?' %}
		{% if 'youtube.com/embed' in embed_src %}
			{% set embed_src = embed_src ~ sep ~ 'playsinline=1&rel=0' %}
			{% if video_muted %}
				{% set embed_src = embed_src ~ '&mute=1' %}
			{% endif %}
			{% set embed_src = embed_src ~ '&autoplay=1' %}
			{% if yt_id %}
				{% set embed_src = embed_src ~ '&loop=1&playlist=' ~ yt_id %}
			{% endif %}
		{% elseif 'player.vimeo.com' in embed_src %}
			{% set embed_src = embed_src ~ sep ~ 'autoplay=1&playsinline=1' %}
			{% if video_muted %}
				{% set embed_src = embed_src ~ '&muted=1' %}
			{% endif %}
		{% endif %}
	{% endif %}

	{% set file_mime =
		lower|split('.webm')|length > 1 ? 'video/webm' :
		(lower|split('.mov')|length > 1 ? 'video/quicktime' : 'video/mp4')
	%}

	{% if embed_type == 'file' %}
		<video class="brand-split-video__video-el{% if video_extra_class %} {{ video_extra_class }}{% endif %}" playsinline preload="metadata"{% if video_muted %} muted{% endif %}{% if video_autoplay %} autoplay loop{% endif %}>
			<source src="{{ raw|e('html_attr') }}" type="{{ file_mime }}">
		</video>
	{% elseif embed_type == 'iframe' and embed_src %}
		<iframe class="brand-split-video__iframe" src="{{ embed_src }}" title="{{ 'Video' | translate }}" loading="lazy" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
	{% else %}
		<div class="brand-split-video__fallback">
			<a href="{{ raw }}" class="btn btn-outline-light brand-split-video__fallback-btn" target="_blank" rel="noopener noreferrer">{{ 'Ver video' | translate }}</a>
		</div>
	{% endif %}
{% endif %}
