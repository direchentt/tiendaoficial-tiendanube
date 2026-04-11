{% if product_modal %}
	<div id="product-video-modal-{{ media.id }}" class="js-product-video-modal product-video" style="display: none;">
{% endif %}
<div class="{% if not thumb and not product_native_video %}js-video{% endif %} {% if product_video and not product_modal %}js-video-product{% endif %} embed-responsive embed-responsive-16by9 visible-when-content-ready {% if product_native_video %}product-native-video-container{% endif %} position-relative">
	{% if not thumb %}
		{% if product_modal_trigger %}
			<a id="trigger-video-modal-{{ media.id }}" href="#product-video-modal-{{ media.id }}" data-fancybox="product-gallery" class="js-play-button video-player {% if not home_main_product %}d-block d-md-none{% endif %} {% if home_main_product %}d-none{% endif %}">
				<div class="video-player-text btn-link h1">
					{{ 'Play' | translate }}
				</div>
			</a>
		{% endif %}
		<a href="javascript:void(0)" {% if product_native_video %}data-video_uid="{{ media.next_video }}"{% endif %} class="{% if product_native_video %}js-play-native-button{% else %}js-play-button{% endif %} video-player {% if product_modal_trigger and not home_main_product %}d-none d-md-block{% endif %}">
			<div class="video-player-text btn-link h3-huge">
				{{ 'Play' | translate }}
			</div>
		</a>
	{% else %}
		<div class="video-player-text btn-link h3-huge">
			{{ 'Play' | translate }}
		</div>
	{% endif %}

	{# Video thumbnail #}
	{% if product_native_video %}
		<div class="js-video-native-image w-100">
			<div data-video_uid="{{ media.uid }}" class="js-external-video-iframe-container embed-responsive" data-video-color="{{ settings.accent_color | trim('#') }}" style="display:none;">
				{{ media.render | raw }}
			</div>
			<img data-video_uid="{{ media.uid }}" src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ media.thumbnail }}" class="video-image lazyload" alt="{{ 'Video de' | translate }} {% if template != 'product' %}{{ product.name }}{% else %}{{ store.name }}{% endif %}">
		</div>
	{% else %}
		<div class="js-video-image">
			<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="" class="lazyload{% if not thumb %} video-image{% endif %} fade-in" alt="{{ 'Video de' | translate }} {% if template != 'product' %}{{ product.name }}{% else %}{{ store.name }}{% endif %}" style="display: none;">
			<div class="placeholder-fade">
			</div>
		</div>
	{% endif %}
</div>

{% if not thumb %}
	{% if not product_native_video %}
		{# Empty iframe component: will be filled with JS on play button click #}
		{% if product.video_url %}
			{% set video_url = product.video_url %}
		{% endif %}

		<div class="js-video-iframe embed-responsive embed-responsive-16by9" style="display: none;" data-video-color="{{ settings.accent_color | trim('#') }}" data-video-url="{{ video_url }}">
		</div>
	{% endif %}
{% endif %}

{% if product_modal %}
	</div>
{% endif %}