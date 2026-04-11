window.tiendaNubeInstaTheme = (function(jQueryNuvem) {
	return {
		waitFor: function() {
			return [window.homeSlider];
		},
		handlers: function(instaElements) {
			return {
				logo: new instaElements.Logo({
					$storeName: jQueryNuvem('#no-logo'),
					$logo: jQueryNuvem('#logo')
				}),
				// ----- Section order -----
				home_order_position: new instaElements.Sections({
					container: '.js-home-sections-container',
					data_store: {
						'slider': 'home-slider',
						'main_categories': 'home-categories-featured',
						'products': 'home-products-featured',
						'welcome': 'home-welcome-message',
						'institutional': 'home-institutional-message',
						'announcement': 'home-announcement-message',
						'informatives': 'banner-services',
						'categories': 'home-banner-categories',
						'promotional': 'home-banner-promotional',
						'news_banners': 'home-banner-news',
						'new': 'home-products-new',
						'modules': 'home-image-text-module',
						'video': 'home-video',
						'sale': 'home-products-sale',
						'newsletter': 'home-newsletter',
						'instafeed': 'home-instagram-feed',
						'main_product': 'home-product-main',
						'brands': 'home-brands',
						'testimonials': 'home-testimonials',
					}
				}),
				slider: new instaElements.GenericSlider(window.homeSlider),
				slider_auto: new instaElements.AutoSliderCheckbox({
					slider: 'slider'
				})
			};
		}
	};
})(jQueryNuvem);