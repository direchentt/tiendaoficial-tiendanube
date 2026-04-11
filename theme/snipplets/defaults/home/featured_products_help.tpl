<section class="section-home section-featured-home" data-store="home-products-{{ section_id }}">
	<div class="container-fluid">
		<div class="row">
			<div class="col-md-3">
				<h2 class="section-title h3-huge h2-huge-md mb-0">{{ products_title }}</h2>
				{% if slider %}
					<div class="swiper-buttons position-relative p-0 ml-neg-2 pl-1">
						<div class="js-swiper-featured-demo-prev swiper-button-prev svg-icon-text">
							<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
						</div>
						<div class="js-swiper-featured-demo-next swiper-button-next svg-icon-text">
							<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
						</div>
					</div>
				{% endif %}
				{% set slide_item = slider ? 'true' : 'false' %}
			</div>
			<div class="col-md-9">
				{% if slider %}
					<div class="js-swiper-featured-demo swiper-container swiper-products">
						<div class="swiper-wrapper swiper-products-slider flex-nowrap row row-grid">
				{% else %}
					<div class="row row-grid">
				{% endif %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_1': true, 'section_columns_desktop': 2, 'section_columns_mobile': 2, 'slide_item': slide_item} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_2': true, 'section_columns_desktop': 2, 'section_columns_mobile': 2, 'slide_item': slide_item} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_3': true, 'section_columns_desktop': 2, 'section_columns_mobile': 2, 'slide_item': slide_item} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_4': true, 'section_columns_desktop': 2, 'section_columns_mobile': 2, 'slide_item': slide_item} %}
					{% if slider %}
						</div>
					{% endif %}
				</div>
			</div>
		</div>
	</div>
</section>
