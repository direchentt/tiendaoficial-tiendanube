{# Miniaturas por opción Color/Cor cuando existe imagen de variante (listado). Requiere .js-item-product con form oculto de variantes. #}
{% if product.variations %}
	{% for variation in product.variations %}
		{% if variation.name in ['Color', 'Cor'] and variation.options | length > 1 %}
			{% set thumb_wrap_open = false %}
			{% for option in variation.options %}
				{% set opt_image = null %}
				{% for variant in product.variants %}
					{% if opt_image is null and variant.image and ((variant.option1 == option.id) or (variant.option2 == option.id) or (variant.option3 == option.id)) %}
						{% set opt_image = variant.image %}
					{% endif %}
				{% endfor %}
				{% if opt_image %}
					{% if not thumb_wrap_open %}
						<div class="item-variant-thumbs d-flex flex-wrap align-items-center pb-1 mb-2" role="group" aria-label="{{ 'Variantes' | translate }}">
						{% set thumb_wrap_open = true %}
					{% endif %}
					{% set is_selected = product.default_options[variation.id] is defined and product.default_options[variation.id] is same as(option.id) %}
					<button
						type="button"
						class="js-listing-variant-thumb js-color-variant item-variant-thumb{% if is_selected %} selected{% endif %}"
						data-option="{{ option.id }}"
						data-variation-id="{{ variation.id }}"
						title="{{ option.name }}"
						aria-label="{{ option.name }}"
						aria-pressed="{{ is_selected ? 'true' : 'false' }}"
					>
						<img
							src="{{ 'images/empty-placeholder.png' | static_url }}"
							data-src="{{ opt_image | product_image_url('thumb') }}"
							data-sizes="auto"
							class="lazyload item-variant-thumb__img"
							alt=""
							width="48"
							height="48"
							loading="lazy"
							decoding="async"
						/>
					</button>
				{% endif %}
			{% endfor %}
			{% if thumb_wrap_open %}
				</div>
			{% endif %}
		{% endif %}
	{% endfor %}
{% endif %}
