{% if template == 'home' %}
	
    {# Preload home LCP image of first section #}

	{% set has_main_slider = settings.slider and settings.slider is not empty %}
	{% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}

	{% if has_mobile_slider %}
		{% set slider = settings.slider_mobile %}
	{% else %}
		{% set slider = settings.slider %}
	{% endif %}

	{% if settings.home_order_position_1 == 'slider' and (has_main_slider or has_mobile_slider) %}
		{% for slide in slider %}
			{% if loop.first %}
				<link rel="preload" fetchpriority="high" as="image" href="{{ slide.image | static_url | settings_image_url('large') }}" imagesrcset="{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w">
			{% endif %}
		{% endfor %}
	{% endif %}

	{% set has_banner = settings.banner and settings.banner is not empty %}
	{% set has_mobile_banners = settings.toggle_banner_mobile and settings.banner_mobile and settings.banner_mobile is not empty %}

	{% set banners = has_mobile_banners ? settings.banner_mobile : settings.banner %}

	{% if settings.home_order_position_1 == 'categories' and (has_banner or has_mobile_banners) %}
		{% for slide in banners %}
			{% if loop.first %}
				<link rel="preload" fetchpriority="high" as="image" href="{{ slide.image | static_url | settings_image_url('large') }}" imagesrcset="{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w">
			{% endif %}
		{% endfor %}
	{% endif %}

	{% set has_promotional_banner = settings.banner_promotional and settings.banner_promotional is not empty %}
	{% set has_mobile_promotional_banners = settings.toggle_banner_promotional_mobile and settings.banner_promotional_mobile and settings.banner_promotional_mobile is not empty %}

	{% set promotional_banners = has_mobile_promotional_banners ? settings.banner_promotional_mobile : settings.banner_promotional %}

	{% if settings.home_order_position_1 == 'promotional' and (has_promotional_banner or has_mobile_promotional_banners) %}
		{% for slide in promotional_banners %}
			{% if loop.first %}
				<link rel="preload" fetchpriority="high" as="image" href="{{ slide.image | static_url | settings_image_url('large') }}" imagesrcset="{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w">
			{% endif %}
		{% endfor %}
	{% endif %}

	{% set has_news_banner = settings.banner_news and settings.banner_news is not empty %}
	{% set has_mobile_news_banners = settings.toggle_banner_news_mobile and settings.banner_news_mobile and settings.banner_news_mobile is not empty %}

	{% set news_banners = has_mobile_news_banners ? settings.banner_news_mobile : settings.banner_news %}

	{% if settings.home_order_position_1 == 'news_banners' and (has_news_banner or has_mobile_news_banners) %}
		{% for slide in news_banners %}
			{% if loop.first %}
				<link rel="preload" fetchpriority="high" as="image" href="{{ slide.image | static_url | settings_image_url('large') }}" imagesrcset="{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w">
			{% endif %}
		{% endfor %}
	{% endif %}

	{% set has_module_banner = settings.module and settings.module is not empty %}

	{% if settings.home_order_position_1 == 'modules' and has_module_banner %}
		{% for slide in settings.module %}
			{% if loop.first %}
				<link rel="preload" fetchpriority="high" as="image" href="{{ slide.image | static_url | settings_image_url('large') }}" imagesrcset="{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w">
			{% endif %}
		{% endfor %}
	{% endif %}

	{% set has_video = settings.video_embed %}

	{% if settings.home_order_position_1 == 'video' and has_video %}
		{% if "video_image.jpg" | has_custom_image %}
			{% set video_image_src = 'video_image.jpg' | static_url | settings_image_url("large") %}
		{% else %}
			<link rel="preconnect" href="https://img.youtube.com/" />
			{% set video_url = settings.video_embed %}
			{% if '/watch?v=' in settings.video_embed %}
				{% set video_format = '/watch?v=' %}
			{% elseif '/youtu.be/' in settings.video_embed %}
				{% set video_format = '/youtu.be/' %}
			{% elseif '/shorts/' in settings.video_embed %}
				{% set video_format = '/shorts/' %}
			{% endif %}
			{% set video_id = video_url|split(video_format)|last %}
			{% set video_image_src = 'https://img.youtube.com/vi_webp/' ~ video_id ~ '/maxresdefault.webp' %}
		{% endif %}
		<link rel="preload" fetchpriority="high" as="image" href="{{ video_image_src }}"{% if "video_image.jpg" | has_custom_image %} imagesrcset="{{ 'video_image.jpg' | static_url | settings_image_url('large') }} 480w, {{ 'video_image.jpg' | static_url | settings_image_url('huge') }} 640w, {{ 'video_image.jpg' | static_url | settings_image_url('original') }} 1024w"{% endif %}>
	{% endif %}
{% elseif template == 'product' %}

    {# Preload product LCP image #}

    {% for image in product.images %}
        {% if loop.first %}
            <link rel="preload" fetchpriority="high" as="image" href="{{ image | product_image_url('large') }}" imagesrcset="{{ image | product_image_url('large') }} 480w, {{ image | product_image_url('huge') }} 640w, {{ image | product_image_url('original') }} 1024w">
        {% endif %}
    {% endfor %}

{% elseif template == 'category' %}

    {# Preload category LCP image #}

    {% set category_banner = (category.images is not empty) or ("banner-products.jpg" | has_custom_image) %}
    
    {% if category_banner %}

        {% set image_sizes = ['large', 'huge', 'original', '1080p'] %}
        {% set category_images = [] %}
        {% set has_category_images = category.images is not empty %}

        {% for size in image_sizes %}
            {% if has_category_images %}
                {# Define images for admin categories #}
                {% set category_images = category_images|merge({(size):(category.images | first | category_image_url(size))}) %}
            {% else %}
                {# Define images for general banner #}
                {% set category_images = category_images|merge({(size):('banner-products.jpg' | static_url | settings_image_url(size))}) %}
            {% endif %}
        {% endfor %}

        <link rel="preload" fetchpriority="high" as="image" href="{{ category_images['large'] }}" imagesrcset="{{ category_images['large'] }} 480w, {{ category_images['huge'] }} 640w, {{ category_images['original'] }} 1024w, {{ category_images['1080p'] }} 1920w">

    {% endif %}

{% endif %}