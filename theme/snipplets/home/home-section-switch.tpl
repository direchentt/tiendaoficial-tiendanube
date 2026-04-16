{# Home modular: one entry per admin "home_order_position_*". Help vs live content is centralized below. #}

{% set home_help_catalog = show_help or (show_component_help and not has_products) %}
{# Keys avoid Twig reserved words (e.g. "new"). Map: novelties -> section_select "new". #}
{% set home_help = {
  slider: show_help or (show_component_help and not (has_main_slider or has_mobile_slider)),
  main_categories: show_help or (show_component_help and not has_main_categories),
  welcome: show_help or (show_component_help and not has_welcome_message),
  announcement: show_help or (show_component_help and not has_announcement_message),
  institutional: show_help or (show_component_help and not has_institutional_message),
  products: home_help_catalog,
  novelties: home_help_catalog,
  sale: home_help_catalog,
  main_product: home_help_catalog,
  informatives: show_help or (show_component_help and not has_informative_banners),
  categories: show_help or (show_component_help and not has_banners),
  video: show_help or (show_component_help and not has_video),
  instafeed: show_help or (show_component_help and not has_instafeed),
  promotional: show_help or (show_component_help and not has_promotional_banners),
  news_banners: show_help or (show_component_help and not has_news_banners),
  modules: show_help or (show_component_help and not has_image_and_text_module),
  brands: show_help or (show_component_help and not has_brands),
  testimonials: show_help or (show_component_help and not has_testimonials),
  brand_editorial: show_help or (show_component_help and not has_brand_editorial),
  brand_split_video: show_help or (show_component_help and not has_brand_split_video),
  brand_category_triptych: show_help or (show_component_help and not has_brand_category_triptych)
} %}

{% if section_select == 'slider' %}

	{% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}
	{% set head_transparent_section = (has_main_slider or has_mobile_slider) and settings.head_transparent %}

	<section class="section-slider-home section-home-color" data-store="home-slider" data-transition="fade-in" {% if head_transparent_section %}data-header-type="transparent-on-section"{% endif %}>
		{% if home_help.slider %}
			{% snipplet 'defaults/home/slider_help.tpl' %}
		{% else %}
			{% include 'snipplets/home/home-slider.tpl' %}
			{% if has_mobile_slider %}
				{% include 'snipplets/home/home-slider.tpl' with {mobile: true} %}
			{% endif %}
		{% endif %}
	</section>

{% elseif section_select == 'main_categories' %}

	{% if home_help.main_categories %}
		{% snipplet 'defaults/home/main_categories_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-categories.tpl' %}
	{% endif %}

{% elseif section_select == 'welcome' %}

	{% if home_help.welcome %}
		{% include 'snipplets/defaults/home/institutional_message_help.tpl' with { title: 'Mensaje de bienvenida'| translate, data_store: 'home-welcome-message' }  %}
	{% else %}
		{% include 'snipplets/home/home-messages.tpl' with {'has_welcome': true} %}
	{% endif %}

{% elseif section_select == 'announcement' %}

	{% if home_help.announcement %}
		{% include 'snipplets/defaults/home/institutional_message_help.tpl' with { title: 'Mensaje de anuncios'| translate, data_store: 'home-announcement-message' }  %}
	{% else %}
		{% include 'snipplets/home/home-messages.tpl' with {'has_announcement': true} %}
	{% endif %}

{% elseif section_select == 'institutional' %}

	{% if home_help.institutional %}
		{% include 'snipplets/defaults/home/institutional_message_help.tpl' with { title: 'Mensaje institucional'| translate, institutional_message: true, data_store: 'home-institutional-message' }  %}
	{% else %}
		{% include 'snipplets/home/home-institutional-message.tpl' %}
	{% endif %}

{% elseif section_select == 'products' %}

	{% if home_help.products %}
		{% include 'snipplets/defaults/home/featured_products_help.tpl' with { products_title: 'Destacados' | translate, section_id: 'featured', slider: true }  %}
	{% else %}
		{% include 'snipplets/home/home-featured-products.tpl' with {'has_featured': true} %}
	{% endif %}

{% elseif section_select == 'new' %}

	{% if home_help.novelties %}
		{% include 'snipplets/defaults/home/featured_products_help.tpl' with { products_title: 'Novedades' | translate, section_id: 'new' }  %}
	{% else %}
		{% include 'snipplets/home/home-featured-products.tpl' with {'has_new': true} %}
	{% endif %}

{% elseif section_select == 'sale' %}

	{% if home_help.sale %}
		{% include 'snipplets/defaults/home/featured_products_help.tpl' with { products_title: 'Ofertas' | translate, section_id: 'sale' }  %}
	{% else %}
		{% include 'snipplets/home/home-featured-products.tpl' with {'has_sale': true} %}
	{% endif %}

{% elseif section_select == 'informatives' %}

	{% if home_help.informatives %}
		{% snipplet 'defaults/home/informative_banners_help.tpl' %}
	{% else %}
		{% include 'snipplets/banner-services/banner-services.tpl' %}
	{% endif %}

{% elseif section_select == 'categories' %}

	{% if home_help.categories %}
		{% include 'snipplets/defaults/home/banners_help.tpl' with { banner_name: 'category', banner_title: 'Categoría' | translate, help_text: 'Podés destacar categorías de tu tienda desde' | translate, section_name: 'Banners de categorías' | translate, data_store: 'home-banner-categories' }  %}
	{% else %}
		{% include 'snipplets/home/home-banners.tpl' with {'has_banner': true} %}
	{% endif %}

{% elseif section_select == 'main_product' %}

	{% if home_help.main_product %}
		{% snipplet 'defaults/home/main_product_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-main-product.tpl' %}
	{% endif %}

{% elseif section_select == 'video' %}

	{% if home_help.video %}
		{% snipplet 'defaults/home/video_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-video.tpl' %}
	{% endif %}

{% elseif section_select == 'newsletter' %}

	{% include 'snipplets/home/home-newsletter.tpl' %}

{% elseif section_select == 'instafeed' %}

	{% if home_help.instafeed %}
		{% snipplet 'defaults/home/instafeed_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-instafeed.tpl' %}
	{% endif %}

{% elseif section_select == 'promotional' %}

	{% if home_help.promotional %}
		{% include 'snipplets/defaults/home/banners_help.tpl' with { banner_name: 'promotional', banner_title: 'Promoción' | translate, help_text: 'Podés mostrar tus promociones desde' | translate, section_name: 'Banners promocionales' | translate, data_store: 'home-banner-promotional' }  %}
	{% else %}
		{% include 'snipplets/home/home-banners.tpl' with {'has_banner_promotional': true} %}
	{% endif %}

{% elseif section_select == 'news_banners' %}

	{% if home_help.news_banners %}
		{% include 'snipplets/defaults/home/banners_help.tpl' with { banner_name: 'news', banner_title: 'Nuevo' | translate, help_text: 'Podés mostrar tus últimas novedades desde' | translate, section_name: 'Banners de novedades' | translate, data_store: 'home-banner-news' }  %}
	{% else %}
		{% include 'snipplets/home/home-banners.tpl' with {'has_banner_news': true} %}
	{% endif %}

{% elseif section_select == 'modules' %}

	{% if home_help.modules %}
		{% include 'snipplets/defaults/home/image_text_modules_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-banners.tpl' with {'has_module': true} %}
	{% endif %}

{% elseif section_select == 'brands' %}

	{% if home_help.brands %}
		{% snipplet 'defaults/home/brands_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-brands.tpl' %}
	{% endif %}

{% elseif section_select == 'testimonials' %}

	{% if home_help.testimonials %}
		{% snipplet 'defaults/home/testimonials_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-testimonials.tpl' %}
	{% endif %}

{% elseif section_select == 'brand_editorial' %}

	{% if home_help.brand_editorial %}
		{% snipplet 'defaults/home/brand_editorial_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-brand-editorial.tpl' %}
	{% endif %}

{% elseif section_select == 'brand_split_video' %}

	{% if home_help.brand_split_video %}
		{% include 'snipplets/defaults/home/banners_help.tpl' with { banner_name: 'brand-video', banner_title: 'Video' | translate, help_text: 'Podés configurar este video desde' | translate, section_name: 'Video hero — General' | translate, data_store: 'home-brand-split-video' }  %}
	{% else %}
		{% include 'snipplets/brand/brand-split-video-hero.tpl' with { force_show: true } %}
	{% endif %}

{% elseif section_select == 'brand_category_triptych' %}

	{% if home_help.brand_category_triptych %}
		{% include 'snipplets/defaults/home/banners_help.tpl' with { banner_name: 'brand-category-triptych', banner_title: 'Categoría' | translate, help_text: 'Podés configurar estos banners desde' | translate, section_name: 'Banners de categorías marca (3 bloques)' | translate, data_store: 'home-brand-category-triptych' }  %}
	{% else %}
		{% include 'snipplets/home/home-brand-category-triptych.tpl' %}
	{% endif %}

{% endif %}
