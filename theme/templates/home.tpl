{# Detect presence of features that remove empty placeholders #}

{% set has_main_slider = settings.slider and settings.slider is not empty %}
{% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}
{% set has_video = settings.video_embed %}
{% set has_main_categories = settings.main_categories and settings.slider_categories and settings.slider_categories is not empty %}
{% set has_banners = settings.banner and settings.banner is not empty %}
{% set has_promotional_banners = settings.banner_promotional and settings.banner_promotional is not empty %}
{% set has_news_banners = settings.banner_news and settings.banner_news is not empty %}
{% set has_image_and_text_module = settings.module and settings.module is not empty %}
{% set has_brands = settings.brands and settings.brands is not empty %}
{% set has_informative_banners = settings.banner_services and (settings.banner_services_01_title or settings.banner_services_02_title or settings.banner_services_03_title or settings.banner_services_01_description or settings.banner_services_02_description or settings.banner_services_03_description) %}
{% set has_instafeed = settings.show_instafeed and store.instagram and store.hasInstagramToken() %}
{% set has_institutional_message = settings.institutional_message or settings.institutional_text %}
{% set has_welcome_message = settings.welcome_message %}
{% set has_announcement_message = settings.announcement_01_message or settings.announcement_02_message or settings.announcement_03_message %}

{% set has_testimonial_01 = settings.testimonial_01_description or settings.testimonial_01_name or "testimonial_01.jpg" | has_custom_image %}
{% set has_testimonial_02 = settings.testimonial_02_description or settings.testimonial_02_name or "testimonial_02.jpg" | has_custom_image %}
{% set has_testimonial_03 = settings.testimonial_03_description or settings.testimonial_03_name or "testimonial_03.jpg" | has_custom_image %}
{% set has_testimonial_04 = settings.testimonial_04_description or settings.testimonial_04_name or "testimonial_04.jpg" | has_custom_image %}
{% set has_testimonials = has_testimonial_01 or has_testimonial_02 or has_testimonial_03 or has_testimonial_04 %}
{% set has_brand_editorial = ('brand_editorial_image.jpg' | has_custom_image) or settings.brand_editorial_title or settings.brand_editorial_kicker or settings.brand_editorial_text or (settings.brand_editorial_btn and settings.brand_editorial_url) %}
{% set has_brand_split_video = settings.brand_split_video_enable and (settings.brand_split_video_1_url or settings.brand_split_video_1_url_es or settings.brand_split_video_1_url_pt or settings.brand_split_video_1_url_en or settings.brand_split_video_1_url_es_mx) %}
{% set has_brand_category_triptych = settings.brand_category_triptych_enable and (('brand_category_triptych_1.jpg' | has_custom_image) or ('brand_category_triptych_2.jpg' | has_custom_image) or ('brand_category_triptych_3.jpg' | has_custom_image)) %}
{% set has_brand_category_carousel = (settings.brand_category_carousel_enable | default(false)) and (('brand_category_carousel_1.jpg' | has_custom_image) or ('brand_category_carousel_2.jpg' | has_custom_image) or ('brand_category_carousel_3.jpg' | has_custom_image) or ('brand_category_carousel_4.jpg' | has_custom_image) or ('brand_category_carousel_5.jpg' | has_custom_image) or ('brand_category_carousel_6.jpg' | has_custom_image)) %}
{% set has_brand_category_rail = settings.brand_category_rail_enable %}
{% set has_brand_routine_showcase = settings.brand_routine_showcase_enable | default(false) %}
{% set has_brand_shoppable_stories = settings.brand_shoppable_stories_enable | default(false) %}
{% set ps_pool_hp = (sections.promo_split_pool is defined and sections.promo_split_pool.products) ? sections.promo_split_pool.products : [] %}
{% set ps_banner_media_hp = (settings.brand_promo_split_media_url | default('') | trim != '') or ('brand_promo_split_banner.jpg' | has_custom_image) %}
{% set has_brand_promo_split = settings.brand_promo_split_enable | default(false) and ps_pool_hp is not empty and ps_banner_media_hp %}

{% set show_help = not (has_main_slider or has_mobile_slider or has_video or has_main_categories or has_banners or has_promotional_banners or has_news_banners or has_image_and_text_module or has_brands or has_informative_banners or has_instafeed or has_testimonials or has_institutional_message or has_welcome_message or has_announcement_message or has_brand_editorial or has_brand_split_video or has_brand_category_triptych or has_brand_category_carousel or has_brand_category_rail or has_brand_routine_showcase or has_brand_shoppable_stories or has_brand_promo_split) and not has_products %}

{% set show_component_help = params.preview %}

{% if show_help or show_component_help %}
	{% include "snipplets/svg/empty-placeholders.tpl" %}
{% endif %}

{% if not params.preview %}
	{% set admin_link = is_theme_draft ? '/admin/themes/settings/draft/' : '/admin/themes/settings/active/' %}
{% endif %}

{# Tracks sections already rendered so order slots do not duplicate the same block. #}
{% set home_sections_rendered = [] %}
<div class="js-home-sections-container home-sections-container{% if settings.brand_home_wide_sections %} brand-home-wide-sections{% endif %}" role="region" aria-label="{{ 'Página de inicio' | translate }}">
	{% for i in 1..19 %}
		{% set section = 'home_order_position_' ~ i %}
		{% set section_select = attribute(settings, section) %}

		{% if section_select not in home_sections_rendered %}
			{% include 'snipplets/home/home-section-switch.tpl' %}
			{% set home_sections_rendered = home_sections_rendered|merge([section_select]) %}
		{% endif %}

	{% endfor %}

	{# Theme editor preview: mount missing section helps without showing them on the live store. #}
	{% if show_component_help %}
		<div class="d-none" aria-hidden="true">
			{% for section_select in ['slider', 'main_categories', 'welcome', 'announcement', 'institutional', 'products', 'new', 'sale', 'informatives', 'categories', 'main_product', 'video', 'newsletter', 'instafeed', 'promotional', 'news_banners', 'brands', 'testimonials', 'modules', 'brand_editorial', 'brand_split_video', 'brand_category_triptych', 'brand_category_carousel', 'brand_category_rail', 'brand_routine_showcase', 'brand_shoppable_stories', 'brand_promo_split'] %}
				{% if section_select not in home_sections_rendered %}
					{% include 'snipplets/home/home-section-switch.tpl' %}
				{% endif %}
			{% endfor %}
		</div>
	{% endif %}
</div>

{% if settings.home_promotional_popup and ("home_popup_image.jpg" | has_custom_image or settings.home_popup_title or settings.home_popup_txt or settings.home_news_box or (settings.home_popup_btn and settings.home_popup_url)) %}
	{% include 'snipplets/home/home-popup.tpl' %}
{% endif %}
