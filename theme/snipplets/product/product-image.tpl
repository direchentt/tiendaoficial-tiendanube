{% if home_main_product %}
	{% set has_multiple_slides = product.media_count > 1 %}
{% else %}
	{% set has_multiple_slides = product.media_count > 1 or product.video_url %}
{% endif %}
{% set product_grid_detail = not home_main_product and settings.product_image_format == 'grid' %}
{% set product_grid_detail_md_class = product_grid_detail ? 'd-md-none' %}

<div class="pdp-gallery-root" data-store="product-image-{{ product.id }}">
	{% if product.media_count > 0 %}
		{% if has_multiple_slides %}
			<div class="swiper-buttons p-0 mr-2 {{ product_grid_detail_md_class }}">
				<div class="js-swiper-product-prev swiper-button-prev svg-icon-text">
					<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
				</div>
				<div class="js-swiper-product-next swiper-button-next svg-icon-text">
					<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
				</div>
			</div>
			<div class="js-swiper-product-pagination swiper-pagination d-inline-block w-auto position-relative pt-3 text-left {{ product_grid_detail_md_class }}"></div>
		{% endif %}
		<div class="js-swiper-product pdp-gallery-swiper swiper-container{% if product_grid_detail %} product-detail-slider{% endif %}" data-product-images-amount="{{ product.media_count }}">
            {% include 'snipplets/labels.tpl' with {product_detail: true, label_custom_class: product_grid_detail_md_class} %}
			<div class="swiper-wrapper">
				{% for media in product.media %}
					{% if media.isImage %}
					 <div class="js-product-slide swiper-slide{% if settings.product_image_format == 'slider' or home_main_product %} product-slide{% if home_main_product %}-small{% endif %}{% endif %} slider-slide{% if product_grid_detail %} col-md-6 px-0 px-md-2 mr-md-0 mb-md-3{% endif %}" data-image="{{media.id}}" data-image-position="{{loop.index0}}">
						{% if home_main_product %}
							<div class="js-product-slide-link d-block position-relative" style="padding-bottom: {{ media.dimensions['height'] / media.dimensions['width'] * 100}}%;">
						{% else %}
							<a href="{{ media | product_image_url('original') }}" data-fancybox="product-gallery" class="js-product-slide-link d-block position-relative" style="padding-bottom: {{ media.dimensions['height'] / media.dimensions['width'] * 100}}%;">
						{% endif %}
						{% if product_grid_detail and loop.first %}
							{% include 'snipplets/labels.tpl' with {product_detail: true, label_custom_class: 'd-none d-md-block'} %}
						{% endif %}

							{% set apply_lazy_load = home_main_product or not loop.first %}

							{% if apply_lazy_load %}
								{% set product_image_src = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==' %}
							{% else %}
								{% set product_image_src = media | product_image_url('large') %}
							{% endif %}

							<img 
								{% if not apply_lazy_load %}fetchpriority="high"{% endif %}
								decoding="async"
								{% if apply_lazy_load %}data-{% endif %}src="{{ product_image_src }}"
								{% if apply_lazy_load %}data-{% endif %}srcset='{{  media | product_image_url('large') }} 480w, {{  media | product_image_url('huge') }} 640w, {{  media | product_image_url('original') }} 1024w' 
								{% if not apply_lazy_load %}sizes="(max-width: 767px) 100vw, (max-width: 1199px) 46vw, 560px"{% endif %}
								class="js-product-slide-img product-slider-image img-absolute img-absolute-centered {% if apply_lazy_load %}lazyautosizes lazyload{% endif %}" 
								{% if apply_lazy_load %}data-sizes="auto"{% endif %}
								{% if media.dimensions.width and media.dimensions.height %}width="{{ media.dimensions.width }}" height="{{ media.dimensions.height }}"{% endif %}
								{% if media.alt %}alt="{{media.alt}}"{% endif %} />

						{% if home_main_product %}
							</div>
						{% else %}
							</a>
						{% endif %}
					</div>
					{% else %}
						{% include 'snipplets/product/product-video.tpl' with {video_id: media.next_video, product_native_video: true, home_main_product: home_main_product} %}
					{% endif %}
				{% endfor %}
				{% if not home_main_product %}
					{% include 'snipplets/product/product-video.tpl' with {video_id: 'yt'} %}
				{% endif %}
			</div>
		</div>
	{% endif %}
</div>