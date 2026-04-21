{#/*============================================================================
    #Specific store JS functions: product variants, cart, shipping, etc
==============================================================================*/#}

{#/*============================================================================

	Table of Contents

	#Lazy load
	#Notifications and tooltips
	#Modals
	#Cards
	#Accordions
	#Transitions
	#Header and nav
		// Header
		// Nav
	#Sliders
		// Home slider
		// Products slider
		// Main categories
		// Brands slider
		// Product related
		// Banner services slider
	#Social
		// Youtube video
	#Product grid
		// Fixed category controls
		// Filters
		// Product item slider
		// Infinite scroll
		// Quickshop
	#Product detail functions
		// Installments
		// Change Variant
		// Submit to contact form
		// Product labels on variant change
		// Color and size variants change
		// Custom mobile variants change
		// Submit to contact
		// Product slider
		// Pinterest sharing
		// Add to cart
		// Product quantity
	#Cart
		// Toggle cart 
		// Add to cart
		// Cart quantitiy changes
		// Empty cart alert
	#Shipping calculator
		// Select and save shipping function
		// Calculate shipping function
		// Calculate shipping by submit
		// Shipping and branch click
		// Select shipping first option on results
		// Toggle more shipping options
		// Calculate shipping on page load
		// Shipping provinces
		// Change store country
	#Forms
	#Footer
	#Empty placeholders

==============================================================================*/#}

// Move to our_content
window.urls = {
    "shippingUrl": "{{ store.shipping_calculator_url | escape('js') }}"
}

/** Montos enteros redondeados (alineado a Twig | money_nocents). */
function formatMoneyRoundedNumber(value) {
    if (value === null || value === undefined || value === '') {
        return '';
    }
    var n = Math.round(Number(value));
    if (isNaN(n)) {
        return String(value);
    }
    var sym = (window.LS && LS.currency && LS.currency.display_short) ? LS.currency.display_short : '$';
    var lang = (document.documentElement.getAttribute('lang') || '').toLowerCase();
    var locale = lang.indexOf('es') === 0 ? 'es-AR' : 'de-DE';
    return sym + n.toLocaleString(locale, { maximumFractionDigits: 0, minimumFractionDigits: 0 });
}

/** Precio transferencia / descuento medio de pago: recalcula con base entera (variante o texto del listado). */
function themeRefreshTransferLines($root) {
    var $scope = $root && $root.length ? $root : jQueryNuvem(document);
    $scope.find('.js-theme-transfer-computed').each(function () {
        var $row = jQueryNuvem(this);
        var pct = Number($row.data('transferPct'));
        if (!isFinite(pct) || pct <= 0 || pct >= 100) {
            return;
        }
        var $ctx = $row.closest('.js-item-product, .js-product-container, .js-quickshop-modal-shell, .js-price-container, #single-product');
        var $price = $ctx.find('.js-price-display').first();
        if (!$price.length) {
            return;
        }
        var base = NaN;
        {# Precio ya mostrado con descuento dinámico (HacheSuite): la transferencia debe partir de ese monto. #}
        var hsEffRaw = $price.attr('data-hs-effective-price');
        if (hsEffRaw != null && hsEffRaw !== '') {
            var hsEff = Number(hsEffRaw);
            if (isFinite(hsEff) && hsEff > 0) {
                base = hsEff;
            }
        }
        if (!isFinite(base) || base <= 0) {
            var contentNum = Number($price.attr('content'));
            if (isFinite(contentNum) && contentNum > 0) {
                base = contentNum;
            }
        }
        if (!isFinite(base) || base <= 0) {
            base = Number($price.attr('data-product-price'));
        }
        if (!isFinite(base) || base <= 0) {
            var digits = String($price.text() || '').replace(/\D/g, '');
            if (digits) {
                base = parseInt(digits, 10);
            }
        }
        if (!isFinite(base) || base <= 0) {
            return;
        }
        var transfer = Math.round(base * (100 - pct) / 100);
        $row.find('.js-theme-transfer-amount').first().text(formatMoneyRoundedNumber(transfer));
    });
}
window.themeRefreshTransferLines = themeRefreshTransferLines;

{#/*============================================================================
  #Lazy load
==============================================================================*/ #}

document.addEventListener('lazybeforeunveil', function(e){
    if ((e.target.parentElement) && (e.target.nextElementSibling)) {
        var parent = e.target.parentElement;
        var sibling = e.target.nextElementSibling;
        if (sibling.classList.contains('js-lazy-loading-preloader')) {
            sibling.style.display = 'none';
            parent.style.display = 'block';
        }
    }
});


window.lazySizesConfig = window.lazySizesConfig || {};
lazySizesConfig.hFac = 0.4;

DOMContentLoaded.addEventOrExecute(() => {

    themeRefreshTransferLines();
    setTimeout(function () {
        themeRefreshTransferLines();
    }, 500);

	{#/*============================================================================
	  #Notifications and tooltips
	==============================================================================*/ #}

    {# /* // Close notification and tooltip */ #}

    jQueryNuvem(".js-notification-close, .js-tooltip-close").on( "click", function(e) {
        e.preventDefault();
        jQueryNuvem(e.currentTarget).closest(".js-notification, .js-tooltip").hide();
    });

    {# /* // Open tooltip */ #}

    jQueryNuvem(document).on("click", ".js-tooltip-open", function(e) {
        e.preventDefault();
        jQueryNuvem(this).next(".js-tooltip").show();
    });

    {# Carrusel nativo TN: flechas/puntos suelen ir dentro del <a> de product-item-image; sin preventDefault el clic abre el producto en lugar de cambiar slide. #}
    (function themeBindProductItemSliderNavInsideLink() {
        function sliderHostFromControl(el) {
            if (!el || !el.closest) {
                return null;
            }
            var host = el.closest('.item-image.item-image-slider');
            if (!host) {
                host = el.closest('.item-image-slider');
            }
            return host;
        }

        function sliderHostFromItemCard(el) {
            if (!el || !el.closest) {
                return null;
            }
            var card = el.closest('.js-item-product');
            if (!card) {
                return null;
            }
            return (
                card.querySelector('.item-image.item-image-slider') ||
                card.querySelector('.item-image-slider')
            );
        }

        function swiperFromHost(host) {
            if (!host) {
                return null;
            }
            var sc =
                host.querySelector('.swiper-container.swiper-container-initialized') ||
                host.querySelector('.swiper-container');
            return sc && sc.swiper ? sc.swiper : null;
        }

        function handleCapture(e) {
            if (!e || !e.target || !e.target.closest) {
                return;
            }
            var t = e.target;
            var btn = t.closest('.item-image-slider .swiper-button-prev, .item-image-slider .swiper-button-next');
            var bullet = !btn
                ? t.closest('.js-item-product .swiper-pagination-bullet.swiper-pagination-bullet')
                : null;
            if (!btn && !bullet) {
                return;
            }
            if (!t.closest('.js-item-product')) {
                return;
            }
            var host = btn ? sliderHostFromControl(btn) : sliderHostFromItemCard(bullet);
            var sw = swiperFromHost(host);
            if (!sw) {
                if (btn || bullet) {
                    e.preventDefault();
                    e.stopPropagation();
                }
                return;
            }
            if (btn) {
                if (btn.classList.contains('swiper-button-disabled')) {
                    e.preventDefault();
                    e.stopPropagation();
                    if (typeof e.stopImmediatePropagation === 'function') {
                        e.stopImmediatePropagation();
                    }
                    return;
                }
                e.preventDefault();
                e.stopPropagation();
                if (typeof e.stopImmediatePropagation === 'function') {
                    e.stopImmediatePropagation();
                }
                if (btn.classList.contains('swiper-button-next')) {
                    if (typeof sw.slideNext === 'function') {
                        sw.slideNext();
                    }
                } else if (typeof sw.slidePrev === 'function') {
                    sw.slidePrev();
                }
                return;
            }
            if (bullet) {
                var pag = bullet.parentElement;
                if (!pag) {
                    return;
                }
                var bullets = pag.querySelectorAll('.swiper-pagination-bullet');
                var idx = Array.prototype.indexOf.call(bullets, bullet);
                if (idx < 0) {
                    return;
                }
                e.preventDefault();
                e.stopPropagation();
                if (typeof e.stopImmediatePropagation === 'function') {
                    e.stopImmediatePropagation();
                }
                if (typeof sw.slideTo === 'function') {
                    sw.slideTo(idx);
                }
            }
        }

        document.addEventListener('click', handleCapture, true);
    })();

    {# Segunda foto en ítems de grilla: toggle hover secundaria o avanzar carrusel por ítem #}
    jQueryNuvem(document).on("click", ".js-item-img-flip", function (e) {
        e.preventDefault();
        e.stopPropagation();
        var $btn = jQueryNuvem(this);
        var $wrap = $btn.closest(".js-item-image-flip-wrap");
        if ($wrap.length) {
            var on = !$wrap.hasClass("is-flipped");
            $wrap.toggleClass("is-flipped", on);
            $btn.attr("aria-pressed", on ? "true" : "false");
            return;
        }
        var $item = $btn.closest(".js-item-product");
        var $next = $item.find(".item-image-slider .swiper-button-next").first();
        if (!$next.length) {
            $next = $item.find(".swiper-button-next").first();
        }
        if ($next.length) {
            $next.trigger("click");
        }
    });

    {# Compra rápida "+": mismo comportamiento que "Comprar" (delegación .js-quickshop-modal-open: fillQuickshop, modal, slide, etc.). #}
    function themeHandleGridQsPlus($btn) {
        var $item = $btn.closest(".js-item-product");
        if (!$item.length) {
            return;
        }
        var $actions = $item.find(".item-actions");
        var $open = $actions.find(".js-quickshop-modal-open").first();
        {% if settings.quick_shop %}
        if ($open.length) {
            $open.trigger("click");
            return;
        }
        {% endif %}
        var $add = $actions.find("input.js-addtocart[type='submit']").first();
        if (!$add.length) {
            $add = $actions.find(".js-addtocart").first();
        }
        if ($add.length && $add[0]) {
            $add[0].click();
            return;
        }
        var $link = $actions.find("a[href]").first();
        if ($link.length && $link[0]) {
            $link[0].click();
            return;
        }
        var $span = $actions.find("span.btn-link").first();
        if ($span.length && $span[0]) {
            $span[0].click();
        }
    }

    jQueryNuvem(document).on("click", ".js-item-qs-plus-floating, [data-theme-grid-qs-plus='1']", function (e) {
        e.preventDefault();
        e.stopPropagation();
        themeHandleGridQsPlus(jQueryNuvem(this));
    });

    {# Orden aleatorio visible: barajar filas en el cliente (Twig/cache o scroll infinito) #}
    (function () {
        function themeFyShuffle(arr) {
            var i, j, t;
            for (i = arr.length - 1; i > 0; i--) {
                j = Math.floor(Math.random() * (i + 1));
                t = arr[i];
                arr[i] = arr[j];
                arr[j] = t;
            }
            return arr;
        }
        window.themeShuffleGridRow = function ($row) {
            if (!$row || !$row.length) {
                return;
            }
            var $kids = $row.children(".js-item-product");
            if ($kids.length < 2) {
                return;
            }
            var nodes = themeFyShuffle($kids.detach().get());
            $row.append(nodes);
        };
        if (jQueryNuvem("body").hasClass("template-home")) {
            jQueryNuvem(".js-home-sections-container .js-user-product-grid .row.row-grid").each(function () {
                window.themeShuffleGridRow(jQueryNuvem(this));
            });
        }
    })();

    {# Notifications variables #}

    var $notification_status_page = jQueryNuvem(".js-notification-status-page");
    var $fixed_bottom_button = jQueryNuvem(".js-btn-fixed-bottom");
    var head_height = jQueryNuvem(".js-head-main").height();
    
	{# /* // Follow order status notification */ #}
    
    if ($notification_status_page.length > 0){
        if (LS.shouldShowOrderStatusNotification($notification_status_page.data('url'))){

            $notification_status_page.css("top" , head_height + 15 + "px");
            $notification_status_page.show();
        };
        jQueryNuvem(".js-notification-status-page-close").on( "click", function(e) {
            e.preventDefault();
            LS.dontShowOrderStatusNotificationAgain($notification_status_page.data('url'));
        });
    }

    {# /* // Cart notification: Dismiss notification */ #}

    jQueryNuvem(".js-cart-notification-close").on("click", function(){
        jQueryNuvem(".js-alert-added-to-cart").removeClass("notification-visible").addClass("notification-hidden");
        setTimeout(function(){
            jQueryNuvem('.js-cart-notification-item-img').attr('src', '');
            jQueryNuvem(".js-alert-added-to-cart").hide();
        },2000);
    });

    {% if not settings.head_fix_desktop %}

        {# /* // Add to cart notification on non fixed header */ #}
        if (window.innerWidth > 768) {
            var adBarHeight = jQueryNuvem(".js-adbar").outerHeight();
            var logoBarHeight = jQueryNuvem(".js-nav-logo-bar").outerHeight();
            var fixedNotificationPosition = adBarHeight + logoBarHeight + 20; 
            var $addedToCartNotification = jQueryNuvem(".js-alert-added-to-cart");

            $addedToCartNotification.css("top", fixedNotificationPosition.toString() + 'px').css("marginTop", "-1px");

            !function () {
                window.addEventListener("scroll", function (e) {
                    if (window.pageYOffset == 0) {
                        $addedToCartNotification.css("top" , fixedNotificationPosition.toString() + 'px');
                    } else {
                        $addedToCartNotification.css("top" , "30px");
                    }
                });
            }();
        }

    {% endif %}

    {% if not params.preview %}

        {# /* // Cookie banner notification */ #}

        restoreNotifications = function(){

            // Whatsapp button position
            $fixed_bottom_button.css("marginBottom", "0");

        };

        if (!window.cookieNotificationService.isAcknowledged()) {
            jQueryNuvem(".js-notification-cookie-banner").show();

            const cookieBannerHeight = jQueryNuvem(".js-notification-cookie-banner").outerHeight();
            
            if (window.innerWidth < 768) {
                
                {# Whatsapp button position #}

                $fixed_bottom_button.css("marginBottom", cookieBannerHeight + 10 + "px");
            }

        }

        jQueryNuvem(".js-acknowledge-cookies").on( "click", function(e) {
            window.cookieNotificationService.acknowledge();
            restoreNotifications();
        });

    {% endif %}

    {#/*============================================================================
      #Modals
    ==============================================================================*/ #}

    {% if settings.quick_shop %}

        restoreQuickshopForm = function(){

            {# Restore form to item when quickshop closes #}

            {# Clean quickshop modal #}

            jQueryNuvem("#quickshop-modal .js-item-product").removeClass("js-swiper-slide-visible js-item-slide");
            jQueryNuvem("#quickshop-modal .js-quickshop-container").attr( { 'data-variants' : '' , 'data-quickshop-id': '' } );
            jQueryNuvem("#quickshop-modal .js-item-product").attr('data-product-id', '');

            {# Wait for modal to become invisible before removing form #}
            
            setTimeout(function(){
                var $quickshop_form = jQueryNuvem("#quickshop-form").find('.js-product-form');
                var $item_form_container = jQueryNuvem(".js-quickshop-opened").find(".js-item-variants");
                
                $quickshop_form.detach().appendTo($item_form_container);
                jQueryNuvem(".js-quickshop-opened").removeClass("js-quickshop-opened");
                jQueryNuvem("#quickshop-modal .js-quickshop-img").attr('srcset', '');
                jQueryNuvem("#quickshop-form").removeAttr("style");
            },350);

        };

    {% endif %}

    {# Reset al open searches when closing a modal #}

    resetSearchBox = function(){

        {# Reset al open searches when closing a modal #}
        
        jQueryNuvem(".js-search-input").val("");
        jQueryNuvem(".js-search-form-suggestions").hide();

        const empty_search = jQueryNuvem(".js-empty-search");
        const empty_submit = jQueryNuvem(".js-search-input-submit");

        empty_search.fadeOut(100);
        empty_submit.fadeIn(100);

    };

    {# Full screen mobile modals back events #}

    if (window.innerWidth < 768) {

        {# Clean url hash function #}

        cleanURLHash = function(){
            const uri = window.location.toString();
            const clean_uri = uri.substring(0, uri.indexOf("#"));
            window.history.replaceState({}, document.title, clean_uri);
        };

        {# Go back 1 step on browser history #}

        goBackBrowser = function(){
            cleanURLHash();
            history.back();
        };

        {# Clean url hash on page load: All modals should be closed on load #}

        if(window.location.href.indexOf("modal-fullscreen") > -1) {
            cleanURLHash();
        }

        {# Open full screen modal and url hash #}

        jQueryNuvem(document).on("click", ".js-fullscreen-modal-open", function(e) {
            e.preventDefault();
            var modal_url_hash = jQueryNuvem(this).data("modalUrl");
            window.location.hash = modal_url_hash;
        });

        {# Close full screen modal: Remove url hash #}

        jQueryNuvem(document).on("click", ".js-fullscreen-modal-close", function(e) {
            e.preventDefault();
            goBackBrowser();
        });

        {# Hide panels or modals on browser backbutton #}

        window.onhashchange = function() {
            if(window.location.href.indexOf("modal-fullscreen") <= -1) {

                {# Close opened modal #}

                if(jQueryNuvem(".js-fullscreen-modal").hasClass("modal-show")){

                    {# Remove body lock only if a single modal is visible on screen #}

                    if(jQueryNuvem(".js-modal.modal-show").length == 1){
                        jQueryNuvem("body").removeClass("overflow-none");
                    }
                    var $opened_modal = jQueryNuvem(".js-fullscreen-modal.modal-show");
                    var $opened_modal_overlay = $opened_modal.prev();

                    $opened_modal.removeClass("modal-show");
                    setTimeout(() => $opened_modal.hide(), 500);
                    $opened_modal_overlay.fadeOut(500);

                    {# Reset al open searches when closing a modal #}
        
                    resetSearchBox();

                    {% if settings.quick_shop %}
                        restoreQuickshopForm();
                    {% endif %}

                }
            }
        }

    }

    modalOpen = function(modal_id, openType){
        var $overlay_id = jQueryNuvem('.js-modal-overlay[data-modal-id="' + modal_id + '"]');

        if (jQueryNuvem(modal_id).hasClass("modal-show")) {
            {# If modal is already opened, close it #}
            if(jQueryNuvem(".js-modal.modal-show").length == 1){
                jQueryNuvem("body").removeClass("overflow-none");
            }
            let modal = jQueryNuvem(modal_id).removeClass("modal-show");
            setTimeout(() => modal.hide(), 500);
        } else {

            {# Lock body scroll if there is no modal visible on screen #}
            
            if(!jQueryNuvem(".js-modal.modal-show").length){
                jQueryNuvem("body").addClass("overflow-none move-right");
            }

            jQueryNuvem(modal_id).detach().appendTo("body");
            jQueryNuvem(modal_id).show().addClass("modal-show");
            
            {# Show overlay for all modals or tab modals only in desktop #}
            if (((jQueryNuvem(modal_id).hasClass("js-modal-overlay-md")) && (window.innerWidth > 768)) || (!jQueryNuvem(modal_id).hasClass("js-modal-overlay-md"))) {
                $overlay_id.fadeIn(400);
                $overlay_id.detach().insertBefore(modal_id);
            }

            {# Filtros: abrir bloque "Ordenar" si el acordeon viene cerrado (un clic menos; respeta aria-expanded). #}
            if (modal_id === '#nav-filters') {
                setTimeout(function () {
                    var $sortTitle = jQueryNuvem('#nav-filters .filter-accordion--catalog-sort .js-accordion-title').first();
                    if ($sortTitle.length && $sortTitle.attr('aria-expanded') === 'false') {
                        $sortTitle.trigger('click');
                    }
                }, 120);
            }
        }

        {# Add url hash to full screen modal if it is opened without click #}

        if(openType == 'openFullScreenWithoutClick' && window.innerWidth < 768 && jQueryNuvem(modal_id).hasClass("js-fullscreen-modal")){
            var modal_url_hash = jQueryNuvem(modal_id).data("modalUrl");
            window.location.hash = modal_url_hash;
        }
    }

    jQueryNuvem(document).on("click", ".js-modal-open", function(e) {
        e.preventDefault(); 
        var modal_id = jQueryNuvem(this).data('toggle');
        modalOpen(modal_id);   
    });

    jQueryNuvem(document).on("click", ".js-modal-close", function(e) {
        e.preventDefault();

        {# Remove body lock only if a single modal is visible on screen #}

        if(jQueryNuvem(".js-modal.modal-show").length == 1){
            jQueryNuvem("body").removeClass("overflow-none");
        }
        var $modal = jQueryNuvem(this).closest(".js-modal");
        var modal_id = $modal.attr('id');
        var $overlay_id = jQueryNuvem('.js-modal-overlay[data-modal-id="#' + modal_id + '"]');
        $modal.removeClass("modal-show");
        setTimeout(() => $modal.hide(), 500);
        $overlay_id.fadeOut(500);
        
        {# Close full screen modal: Remove url hash #}

        if ((window.innerWidth < 768) && (jQueryNuvem(this).hasClass(".js-fullscreen-modal-close"))) {
            goBackBrowser();
        }

        {# Reset al open searches when closing a modal #}

        resetSearchBox();

        {% if settings.quick_shop %}
            restoreQuickshopForm();
        {% endif %}

    });

    jQueryNuvem(document).on("click", ".js-modal-overlay", function(e) {
        e.preventDefault();

        {# Remove body lock only if a single modal is visible on screen #}

        if(jQueryNuvem(".js-modal.modal-show").length == 1){
            jQueryNuvem("body").removeClass("overflow-none");
        }

        var modal_id = jQueryNuvem(this).data('modalId');
        let modal = jQueryNuvem(modal_id).removeClass("modal-show");
        setTimeout(() => modal.hide(), 500);
        jQueryNuvem(this).fadeOut(500);

        {# Reset al open searches when closing a modal #}
        
        resetSearchBox();

        {% if settings.quick_shop %}
            restoreQuickshopForm();
        {% endif %}

    });

    {% if template == 'home' and settings.home_promotional_popup %}

        {# /* // Home popup and newsletter popup */ #}

        jQueryNuvem('#news-popup-form').on("submit", function () {
            jQueryNuvem(".js-news-spinner").show();
            jQueryNuvem(".js-news-popup-submit").prop("disabled", true);
        });

        LS.newsletter('#news-popup-form-container', '#home-modal', '{{ store.contact_url | escape('js') }}', function (response) {
            jQueryNuvem(".js-news-spinner").hide();
            jQueryNuvem(".js-news-popup-submit").show();
            var selector_to_use = response.success ? '.js-news-popup-success' : '.js-news-popup-failed';
            let newPopupAlert = jQueryNuvem(this).find(selector_to_use).fadeIn(100);
            setTimeout(() => newPopupAlert.fadeOut(500), 4000);
            if (jQueryNuvem(".js-news-popup-success").css("display") == "block") {
                setTimeout(function () {
                    jQueryNuvem('[data-modal-id="#home-modal"]').fadeOut(500);
                    let homeModal = jQueryNuvem("#home-modal").removeClass("modal-show");
                    setTimeout(() => homeModal.hide(), 500);
                }, 2500);
            }
            jQueryNuvem(".js-news-popup-submit").prop("disabled", false);
        });

        var callback_show = function(){
            {% if store.whatsapp %}
                jQueryNuvem('.js-btn-fixed-bottom').fadeOut(500);
            {% endif %}
            jQueryNuvem("#home-modal").detach().appendTo("body").show().addClass("modal-show");
        }
        var callback_hide = function(){
            let homeModal = jQueryNuvem("#home-modal").removeClass("modal-show");
            setTimeout(() => homeModal.hide(), 500);
        }

        {% if store.whatsapp %}
            jQueryNuvem("#home-modal .js-modal-close").on("click", function (e) {
                e.preventDefault();
                jQueryNuvem('.js-btn-fixed-bottom').fadeIn(500);
            });
        {% endif %}

        LS.homePopup({
            selector: "#home-modal",
            mobile_max_pixels: 0,
            timeout: {{ (settings.home_popup_timeout | default(5)) * 1000 }}
        }, callback_hide, callback_show);

    {% endif %}

    {#/*============================================================================
      #Cards
    ==============================================================================*/ #}
    jQueryNuvem(document).on("click", ".js-card-collapse-toggle", function(e) {
        e.preventDefault();
        var parent = jQueryNuvem(this).closest(".js-card-collapse");
        parent.find(".js-card-collapse-icon").toggle();
        parent.toggleClass('active');
    });

    {#/*============================================================================
      #Transitions
    ==============================================================================*/ #}

    const inViewport = (entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.observed) {
          entry.target.classList.add("is-inViewport");
          entry.target.observed = true;
        }
      });
    };

    // Attach observer to every [data-transition] element:
    const ELs_inViewport = document.querySelectorAll('[data-transition]');
    ELs_inViewport.forEach(EL => {
      EL.observed = false; // Initialize the observed flag for each element
      const Obs = new IntersectionObserver(inViewport);
      Obs.observe(EL);
    });

    applyMarqueeAnimation = function(marqueeSelector, textSelector, textDirection){

        {# Reference speed values #}

        var defaultDelay = 5;
        var defaultWidth = 300;

        {# New speed values based on dynamic content #}
        var animatedWidth = jQueryNuvem(textSelector).first(el => el.offsetWidth);
        var newDelay = defaultDelay*(animatedWidth/defaultWidth)*1.5;

        if((window.innerWidth > 768) && (newDelay < 60)){

            {# If content is too short, set a minimum speed #}
            var newDelay = newDelay + 20;
        }

        var animationDirection = textDirection === 'reverse' ? "reverse" : "normal";

        jQueryNuvem(marqueeSelector).css("animation", "marquee " + newDelay + "s linear infinite " + animationDirection);
    };

    {% if template == 'home' and (settings.welcome_animate or settings.announcement_animate or settings.institutional_animate or (settings.brands and settings.brands is not empty and settings.brands_format == 'animate') or (settings.main_categories and settings.slider_categories and settings.slider_categories is not empty and settings.main_categories_format == 'animate'))  %}

        {# /* // Animated welcome message */ #}

        jQueryNuvem('.js-home-message-animated').each(function(el) {
            var textContainer = jQueryNuvem(el).find(".js-home-message-text-container");
            applyMarqueeAnimation(el , textContainer);
        });

        jQueryNuvem('.js-home-message-animated-reverse').each(function(el) {
            var textReverseContainer = jQueryNuvem(el).find(".js-home-message-text-container-reverse");
            applyMarqueeAnimation(el, textReverseContainer, "reverse");
        });

    {% endif %}

	{#/*============================================================================
      #Header and nav
    ==============================================================================*/ #}

    {# /* // Adbar slider */ #}

    {% set adbarMessage01 = settings.ad_bar_01_text %}
    {% set adbarMessage02 = settings.ad_bar_02_text %}
    {% set adbarMessage03 = settings.ad_bar_03_text %}
    {% set adbarMultipleMessages = (adbarMessage01 and adbarMessage02) or (adbarMessage01 and adbarMessage03) or (adbarMessage02 and adbarMessage03) %}
    {% set adbarMessages = adbarMessage01 or adbarMessage02 or adbarMessage03 %}
    {% set hasAdbar = settings.ad_bar and adbarMessages %}

    {% if settings.ad_bar %}

        {% if settings.ad_bar_animate %}

            {# /* // Animated adbar */ #}

            applyMarqueeAnimation(".js-adbar-animated" , ".js-adbar-text-container");

        {% elseif adbarMultipleMessages %}

            createSwiper('.js-swiper-adbar', {
                loop: true,
                slidesPerView: 1,
                navigation: {
                    nextEl: '.js-swiper-adbar-next',
                    prevEl: '.js-swiper-adbar-prev',
                },
            });

        {% endif %}

    {% endif %}

    {# /* // Nav */ #}


    {# Transparent head #}

    var $category_controls = jQueryNuvem(".js-category-controls");

    {% if settings.head_transparent and ((template == 'home' and settings.head_transparent_type == 'slider_and_video') or settings.head_transparent_type == 'all') %}
        var fixedNavTransparent = jQueryNuvem(".js-head-mutator");
        var fixedNavTransparentHeight = fixedNavTransparent.height();
        var videoSection = jQueryNuvem(".js-section-video");
        var sliderSection = jQueryNuvem(".js-home-main-slider-container");

        {# Components validations #}

        {% set has_main_slider = settings.slider and settings.slider is not empty %}
        {% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}
        {% set has_slider = has_main_slider or has_mobile_slider %}
        {% set has_slider_above_the_fold = settings.home_order_position_1 == 'slider' and has_slider %}

        {% set has_video = settings.video_embed %}
        {% set has_video_above_the_fold = settings.home_order_position_1 == 'video' and has_video %}

        {# Remove transparent header when stop swiping #}

        {% set remove_header_transparent_on_scroll_stop = settings.head_transparent and settings.head_transparent_type == 'all' %}

        {% if remove_header_transparent_on_scroll_stop %}

            if (window.innerWidth < 768) {

                {% if template == 'home' and (has_video_above_the_fold or has_slider_above_the_fold) %}
                    {% if has_slider_above_the_fold %}
                        removeTransparentLimit = sliderSection.height();
                    {% else %}
                        removeTransparentLimit = videoSection.height();
                    {% endif %}
                {% else %}
                    removeTransparentLimit = fixedNavTransparentHeight;
                {% endif %}

                var isScrolling;

                window.addEventListener('scroll', function ( event ) {

                    fixedNavTransparent.addClass('head-transparent');
                    $category_controls.addClass('category-controls-transparent');

                    // Clear our timeout throughout the scroll
                    window.clearTimeout(isScrolling);

                    // Set a timeout to run after scrolling ends
                    isScrolling = setTimeout(function() {

                        if((window.scrollY > removeTransparentLimit)){

                            // Stopped scrolling
                            fixedNavTransparent.removeClass('head-transparent');
                            $category_controls.removeClass('category-controls-transparent');
                        }else {

                            // Stopped scrolling on window top
                            fixedNavTransparent.addClass('head-transparent');
                            $category_controls.addClass('category-controls-transparent');
                        }
                    },  500);
                }, false);
            }

        {% endif %}

        {% set toggle_header_transparent_on_hover = settings.head_fix_desktop and settings.head_transparent and settings.head_transparent_type == 'all' %}

        {% if toggle_header_transparent_on_hover %}

            {# Change header transparent for mouseover on not related elements #}

            if (window.innerWidth > 767) {
                jQueryNuvem(document).on("mouseover", ".js-head-mutator", function(e) {
                    jQueryNuvem(".js-category-controls-transparent-md.is-sticky").addClass("hover");
                }).on("mouseout", ".js-head-mutator", function(e) {
                    jQueryNuvem(".js-category-controls-transparent-md.is-sticky").removeClass("hover");
                });

                jQueryNuvem(document).on("mouseover", ".js-category-controls-transparent-md.is-sticky", function(e) {
                    jQueryNuvem(".js-head-mutator").addClass("hover");
                }).on("mouseout", ".js-category-controls-transparent-md.is-sticky", function(e) {
                    jQueryNuvem(".js-head-mutator").removeClass("hover");
                });
            }

        {% endif %}
    {% endif %}

    {# Nav subitems hamburger #}

    jQueryNuvem(".js-toggle-menu-panel").click(function (e) {
        e.preventDefault();
        jQueryNuvem(this).next(".js-menu-panel").show().addClass("nav-list-panel-show");
    });

    jQueryNuvem(".js-toggle-menu-back").click(function (e) {
        e.preventDefault();
        var $panel_to_change = jQueryNuvem(this).closest(".js-menu-panel");
        $panel_to_change.removeClass("nav-list-panel-show");
         setTimeout(function(){
            $panel_to_change.hide();
        },600);
    });

    closeHamburgerSubpanels = function() {
        jQueryNuvem("#nav-hamburger").addClass("modal-transition-fast");
        jQueryNuvem(".js-menu-panel").removeClass("nav-list-panel-show");
        
         setTimeout(function(){
            jQueryNuvem(".js-menu-panel").hide();
            jQueryNuvem("#nav-hamburger").removeClass("modal-transition-fast");
        },1000);
    };

    jQueryNuvem(".js-toggle-menu-close, .js-modal-overlay[data-modal-id='#nav-hamburger'").click(function () {
        closeHamburgerSubpanels();
    });

    {% set _brand_hamburger_nav_tabs = [] %}
    {% for item in navigation %}
        {% if item.subitems %}
            {% set _brand_hamburger_nav_tabs = _brand_hamburger_nav_tabs | merge([item]) %}
        {% endif %}
    {% endfor %}
    {% if settings.brand_hamburger_drawer_enable and _brand_hamburger_nav_tabs | length > 0 %}
    jQueryNuvem(document).on("click", ".js-brand-hamburger-tab", function (e) {
        e.preventDefault();
        var $btn = jQueryNuvem(this);
        var idx = $btn.data("brandTab");
        if (typeof idx === "undefined") {
            return;
        }
        var $root = $btn.closest(".js-brand-hamburger-drawer");
        if (!$root.length) {
            return;
        }
        $root.find(".js-brand-hamburger-tab").removeClass("is-active").attr("aria-selected", "false");
        $root.find(".js-brand-hamburger-panel").removeClass("is-active").attr("hidden", true);
        $btn.addClass("is-active").attr("aria-selected", "true");
        $root.find('.js-brand-hamburger-panel[data-brand-panel="' + idx + '"]').addClass("is-active").removeAttr("hidden");
    });

    jQueryNuvem(document).on("click", ".js-brand-hamburger-accordion-toggle", function (e) {
        e.preventDefault();
        var $btn = jQueryNuvem(this);
        var $branch = $btn.closest(".brand-hamburger-drawer__branch");
        var $panel = $branch.find(".js-brand-hamburger-accordion-panel").first();
        if (!$panel.length) {
            return;
        }
        var open = $btn.attr("aria-expanded") === "true";
        if (open) {
            $btn.attr("aria-expanded", "false");
            $branch.removeClass("is-open");
            $panel.attr("hidden", true);
        } else {
            $btn.attr("aria-expanded", "true");
            $branch.addClass("is-open");
            $panel.removeAttr("hidden");
        }
    });
    {% endif %}

    {# Nav subitems desktop #}

    var win_height = window.innerHeight;
    const logoContainer = jQueryNuvem('.js-logo-container');

    jQueryNuvem(".js-desktop-dropdown").css('maxHeight', (win_height - head_height - 50).toString() + 'px');

    jQueryNuvem(".js-item-subitems-desktop").on("mouseenter", function (e) {
        jQueryNuvem(e.currentTarget).addClass("active");
    }).on("mouseleave", function(e) {
        jQueryNuvem(e.currentTarget).removeClass("active");
    });

    jQueryNuvem(".js-nav-main-item").on("mouseenter", function (e) {
        jQueryNuvem('.js-nav-desktop-list').children(".selected").removeClass("selected");
        jQueryNuvem(e.currentTarget).addClass("selected");
    }).on("mouseleave", function(e) {
        const self = jQueryNuvem(this);
        setTimeout(function(){
            self.removeClass("selected");
        },500);
    });

    jQueryNuvem(".js-nav-desktop-list-arrow").on("mouseenter", function (e) {
        jQueryNuvem('.js-desktop-nav-item').removeClass("selected");
    });

     {# Nav desktop scroller #}

    {% set logo_desktop_left = settings.logo_position_desktop == 'left' and not (settings.search_big_desktop and settings.hamburger_desktop) %}

    const menuContainer = jQueryNuvem('.js-nav-desktop-list').first(el => el.offsetWidth);
    const logoColWidth = logoContainer.first(el => el.offsetWidth);
    let utilityColWidth = 0;
    
    jQueryNuvem('.js-utility-col').each(function(el) {
        utilityColWidth +=  jQueryNuvem(el).first(el => el.offsetWidth);
    });

    const totalColsWidth = logoColWidth + utilityColWidth;

    {% if logo_desktop_left %}
        const menuColWidth = menuContainer - totalColsWidth - 30;
    {% endif %}

    let menuItems = 0;

    jQueryNuvem('.js-nav-desktop-list > .js-desktop-nav-item').each(function(el) {
        menuItems +=  jQueryNuvem(el).first(el => el.offsetWidth);
    });

    jQueryNuvem(".js-nav-desktop-list").on("scroll", function() {
        var position = jQueryNuvem('.js-nav-desktop-list').prop("scrollLeft");
        if(position == 0) {
            jQueryNuvem(".js-nav-desktop-list-arrow-left").addClass('disable');
        } else {
            jQueryNuvem(".js-nav-desktop-list-arrow-left").removeClass('disable');
        }
        if(position == ( menuItems - menuContainer )) {
            jQueryNuvem(".js-nav-desktop-list-arrow-right").addClass('disable');
        } else {
            jQueryNuvem(".js-nav-desktop-list-arrow-right").removeClass('disable');
        }
    });

    {% if logo_desktop_left %}

        {# Recalculate items width including first and last element different paddings #}

        menuItems = menuItems;
        
    {% endif %}
    
    if (menuContainer < menuItems) {
        jQueryNuvem('.js-nav-desktop-list').addClass('nav-desktop-with-scroll');
        jQueryNuvem('.js-nav-desktop-list-arrow').show();
        {% if logo_desktop_left %}
            jQueryNuvem(".js-desktop-nav-col").css("width" , menuColWidth.toString() + 'px');
        {% endif %}
    }

    setTimeout(function(){
        jQueryNuvem(".js-desktop-nav-col, .js-utility-col").css("visibility", "visible").css("height", "auto");
    },200);

    {# Show nav row once columns layout are ready #}

    jQueryNuvem(".js-menu-and-banners-row").css("visibility" , "visible").css("height" , "auto").css("overflow" , "initial");

    jQueryNuvem('.js-nav-desktop-list-arrow-right').on("click", function() {
        var posL = jQueryNuvem('.js-nav-desktop-list').prop("scrollLeft") + 400;
        jQueryNuvem('.js-nav-desktop-list').each((el) => el.scroll({ left: posL, behavior: 'smooth' }));
    });
    jQueryNuvem('.js-nav-desktop-list-arrow-left').on("click", function() {
        var posR = jQueryNuvem('.js-nav-desktop-list').prop("scrollLeft") - 400;
        jQueryNuvem('.js-nav-desktop-list').each((el) => el.scroll({ left: posR, behavior: 'smooth' }));
    });

    {# Expandable search #}

    {% if not settings.search_big_desktop %}
        jQueryNuvem(".js-search-button").on("click", function (e) {
            var searchBox = jQueryNuvem(".js-search-utility").find(".js-search-form");
            searchBox.addClass("expanded");
        });
    {% endif%}

    {# Avoid megamenu dropdown flickering when mouse leave #}

    jQueryNuvem(".js-desktop-dropdown").on("mouseleave", function (e) {
        const self = jQueryNuvem(this);
        self.css("pointer-events" , "none");
        setTimeout(function(){
            self.css("pointer-events" , "initial");
        },1000);
    });

    {# Focus search #}

    const search_input = jQueryNuvem(".js-search-input");

    jQueryNuvem(".js-search-button").on("click", function (e) {
        setTimeout(function(){
            search_input.val('').each(el => el.focus());
        },10);
    });

    {# /* // Header */ #}

    {# Fixed nav #} 

    {% set has_only_mobile_with_fixed_nav =  not settings.head_fix_desktop %}

    {% if has_only_mobile_with_fixed_nav %}
        if (window.innerWidth < 768) {
    {% endif %}

        {# Show and hide mobile nav on scroll #}

        var didScroll;
        var lastScrollTop = 0;
        var delta = 30;
        var navbarHeight = jQueryNuvem(".js-head-main").outerHeight();
        var topbarHeight = jQueryNuvem(".js-adbar").outerHeight();

        window.addEventListener("scroll", function(event){
            didScroll = true;
        });

        setInterval(function() {
            if (didScroll) {
                hasScrolled();
                didScroll = false;
            }
        }, 250);

        function hasScrolled() {
            var st = window.pageYOffset;
            
            // Make sure they scroll more than delta
            if(Math.abs(lastScrollTop - st) <= delta)
                return;
            
            // If they scrolled down and are past the navbar, add class .compress.
            if (st > lastScrollTop && st > navbarHeight){
                jQueryNuvem(".js-head-main").addClass('compress').css('top', (- topbarHeight).toString() + 'px' );
                {% if template == 'category' or template == 'search' %}
                    if (window.innerWidth < 768) {
                        setTimeout(function(){
                            offsetCategories();
                        },300);
                    }
                {% endif %}
            } else {
                // Scroll Up
                let documentHeight = Math.max(
                    document.body.scrollHeight,
                    document.body.offsetHeight,
                    document.documentElement.clientHeight,
                    document.documentElement.scrollHeight,
                    document.documentElement.offsetHeight
                );

                if(st + window.innerHeight < documentHeight) {
                    jQueryNuvem(".js-head-main").removeClass('compress').css('top', "0px" );
                    {% if template == 'category' or template == 'search' %}
                        if (window.innerWidth < 768) {
                            setTimeout(function(){
                                offsetCategories();
                            },300);
                        }
                    {% endif %}
                }
            }

            lastScrollTop = st;
        }
        
    {% if has_only_mobile_with_fixed_nav %}
        }
    {% endif %} 


    {# /* // Lang select */ #}


    changeLang = function(element) {
        var selected_country_url = element.find("option").filter((el) => el.selected).attr("data-country-url");
        location.href = selected_country_url;
    };

    jQueryNuvem('.js-lang-select').on("change", function (e) {
        lang_select_option = jQueryNuvem(this);

        changeLang(lang_select_option);
    });

	{#/*============================================================================
	  #Sliders
	==============================================================================*/ #}

    {% set columns_desktop = settings.grid_columns_desktop %}
    {% set columns_mobile = settings.grid_columns_mobile %}
    var slidesPerViewDesktopVal = {% if columns_desktop == 5 %}5{% elseif columns_desktop == 4 %}4{% elseif columns_desktop == 3 %}3{% else %}2{% endif %};
    var slidesPerViewMobileVal = {% if columns_mobile == 1 %}1{% elseif columns_mobile == 2 %}2{% elseif columns_mobile == 3 %}3{% else %}2{% endif %};
    var itemSwiperSpaceBetween = 15;

    {# Hide arrow controls when swiper is not swipable #}

    hideSwiperControls = function(elemPrev, elemNext) {
        if((jQueryNuvem(elemPrev).hasClass("swiper-button-disabled") && jQueryNuvem(elemNext).hasClass("swiper-button-disabled"))){
            jQueryNuvem(elemPrev).remove();
            jQueryNuvem(elemNext).remove();
        }
    };

    {# Carrusel TN por tarjeta dentro de otro Swiper (ej. Destacados): LS puede correr antes que el padre; nested + re-init tras slide del padre. #}
    var themeNestedProductItemSliderRefreshTimer = null;
    function themeNestedProductItemSliderRefresh() {
        if (themeNestedProductItemSliderRefreshTimer) {
            clearTimeout(themeNestedProductItemSliderRefreshTimer);
        }
        themeNestedProductItemSliderRefreshTimer = setTimeout(function () {
            themeNestedProductItemSliderRefreshTimer = null;
            if (typeof LS === 'undefined' || typeof LS.productItemSlider !== 'function') {
                return;
            }
            try {
                LS.productItemSlider({
                    pagination_type: 'bullets',
                });
            } catch (eRun) {
                /* ignore */
            }
            if (typeof window.requestAnimationFrame === 'function') {
                window.requestAnimationFrame(function () {
                    try {
                        document
                            .querySelectorAll(
                                '.js-swiper-featured, .js-swiper-new, .js-swiper-sale, .js-swiper-related, .js-swiper-complementary, .js-swiper-pdp-sec-complementary, .js-swiper-pdp-sec-alternative'
                            )
                            .forEach(function (root) {
                                if (!root.classList.contains('swiper-container-initialized')) {
                                    return;
                                }
                                root.querySelectorAll('.item-image-slider .swiper-container').forEach(function (inner) {
                                    var sw = inner.swiper;
                                    if (!sw || !sw.params) {
                                        return;
                                    }
                                    sw.params.nested = true;
                                    if (sw.navigation && typeof sw.navigation.update === 'function') {
                                        sw.navigation.update();
                                    }
                                    if (typeof sw.update === 'function') {
                                        sw.update();
                                    }
                                });
                            });
                    } catch (e2) {
                        /* ignore */
                    }
                });
            }
        }, 90);
    }

	{% if template == 'home' %}

		{# /* // Home slider */ #}


        var width = window.innerWidth;
        if (width > 767) {
            var slider_autoplay = {delay: 6000,};
        } else {
            var slider_autoplay = false;
        }

        window.homeSlider = {
            getAutoRotation: function() {
                return slider_autoplay;
            },
            updateSlides: function(slides) {
                homeSwiper.removeAllSlides();
                slides.forEach(function(aSlide, index){
                    homeSwiper.appendSlide(
                        '<div class="swiper-slide slide-container ' + aSlide.color + '">' +
                            (aSlide.link ? '<a href="' + aSlide.link + '">' : '' ) +
                                '<img src="' + aSlide.src + '" class="slider-image"/>' +
                                '<div class="swiper-text{% if settings.slider_align == 'center' %} swiper-text-centered{% elseif settings.slider_align == 'right' %} swiper-text-right{% endif %} swiper-text-' + aSlide.color + '">' +
                                    (aSlide.description || aSlide.title ? '<div class="mb-1 mb-md-2">' + (index + 1) + '/' + slides.length + '</div>' : '' ) +
                                    (aSlide.title ? '<div class="h1{% if settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}-huge{% endif %} h1-huge-md mb-2 mb-md-3">' + aSlide.title + '</div>' : '' ) +
                                    (aSlide.description ? '<p class="mb-2 mb-md-3">' + aSlide.description + '</p>' : '' ) +
                                    (aSlide.button && aSlide.link ? '<div class="btn btn-link d-inline-block mb-2 mb-md-3">' + aSlide.button + '</div>' : '' ) +
                                '</div>' +
                            (aSlide.link ? '</a>' : '' ) +
                        '</div>'
                    );
                });

                {% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}

                if(!slides.length){
                    jQueryNuvem(".js-home-main-slider-container").addClass("hidden");
                    jQueryNuvem(".js-home-empty-slider-container").removeClass("hidden");
                    jQueryNuvem(".js-home-mobile-slider-visibility").removeClass("d-md-none");
                    {% if has_mobile_slider %}
                        jQueryNuvem(".js-home-main-slider-visibility").removeClass("d-none d-md-block");
                        homeMobileSwiper.update();
                    {% endif %}
                }else{
                    jQueryNuvem(".js-home-main-slider-container").removeClass("hidden");
                    jQueryNuvem(".js-home-empty-slider-container").addClass("hidden");
                    jQueryNuvem(".js-home-mobile-slider-visibility").addClass("d-md-none");
                    {% if has_mobile_slider %}
                        jQueryNuvem(".js-home-main-slider-visibility").addClass("d-none d-md-block");
                    {% endif %}
                }
            },
            changeAutoRotation: function(){

            },
        };

        var preloadImagesValue = false;
        var lazyValue = true;
        var loopValue = true;
        var paginationClickableValue = true;

        function arrowsColor() {
            if(jQueryNuvem(".js-home-slider").find('.swiper-slide-active').hasClass("swiper-light")){
                jQueryNuvem(".js-home-slider").addClass("swiper-arrows-light");
            } else {
                jQueryNuvem(".js-home-slider").removeClass("swiper-arrows-light");
            }
        }

        var homeSwiper = null;
        createSwiper(
            '.js-home-slider', {
                preloadImages: preloadImagesValue,
                lazy: lazyValue,
                {% if settings.slider | length > 1 %}
                    loop: loopValue,
                {% endif %}
                autoplay: slider_autoplay,
                navigation: {
                    nextEl: '.js-swiper-home-next',
                    prevEl: '.js-swiper-home-prev',
                },
                on: {
                  init: arrowsColor,
                  slideChangeTransitionEnd: arrowsColor,
                },
            },
            function(swiperInstance) {
                homeSwiper = swiperInstance;
            }
        );

        function arrowsMobileColor() {
            if(jQueryNuvem(".js-home-slider-mobile").find('.swiper-slide-active').hasClass("swiper-light")){
                jQueryNuvem(".js-home-slider-mobile").addClass("swiper-arrows-light");
            } else {
                jQueryNuvem(".js-home-slider-mobile").removeClass("swiper-arrows-light");
            }
        }

        var homeMobileSwiper = null;
        createSwiper(
            '.js-home-slider-mobile', {
                preloadImages: preloadImagesValue,
                lazy: lazyValue,
                {% if settings.slider_mobile | length > 1 %}
                    loop: loopValue,
                {% endif %}
                autoplay: slider_autoplay,
                navigation: {
                    nextEl: '.js-swiper-home-next-mobile',
                    prevEl: '.js-swiper-home-prev-mobile',
                },
                on: {
                  init: arrowsMobileColor,
                  slideChangeTransitionEnd: arrowsMobileColor,
                },
            },
            function(swiperInstance) {
                homeMobileSwiper = swiperInstance;
            }
        );

        {% if settings.slider | length == 1 %}
            jQueryNuvem('.js-swiper-home .swiper-wrapper').addClass( "disabled" );
            jQueryNuvem('.js-swiper-home-pagination, .js-swiper-home-prev, .js-swiper-home-next').remove();
        {% endif %}

        {% if settings.slider_mobile | length == 1 %}
            jQueryNuvem('.js-swiper-home-pagination-mobile, .js-swiper-home-prev-mobile, .js-swiper-home-next-mobile').remove();
        {% endif %}

        {# /* // Products slider */ #}

        {% set has_featured_products_slider = sections.primary.products and (settings.featured_products_format_mobile == 'slider' or settings.featured_products_format_desktop == 'slider') %}
        {% set has_new_products_slider = sections.new.products and (settings.new_products_format_mobile == 'slider' or settings.new_products_format_desktop == 'slider') %}
        {% set has_sale_products_slider = sections.sale.products and (settings.sale_products_format_mobile == 'slider' or settings.sale_products_format_desktop == 'slider') %}

        {% if has_featured_products_slider or has_new_products_slider or has_sale_products_slider %}

            var lazyVal = true;
            var watchOverflowVal = true;
            var centerInsufficientSlidesVal = true;

            {% if has_featured_products_slider %}

                {% set featured_desktop_slider = settings.featured_products_format_desktop == 'slider' %}
                {% set featured_only_mobile_slider = settings.featured_products_format_mobile == 'slider' and settings.featured_products_format_desktop != 'slider' %}
                {% set featured_only_desktop_slider = settings.featured_products_format_desktop == 'slider' and settings.featured_products_format_mobile != 'slider' %}
                {% set featured_columns_desktop = settings.featured_products_desktop %}
                {% set featured_columns_mobile = settings.featured_products_mobile %}
                var slidesPerViewFeaturedDesktopVal = {% if featured_columns_desktop == 2 %}2{% elseif featured_columns_desktop == 3 %}3{% elseif featured_columns_desktop == 4 %}4{% elseif featured_columns_desktop == 5 %}5{% else %}4{% endif %};
                var slidesPerViewFeaturedMobileVal = {% if featured_columns_mobile == 1 %}1{% elseif featured_columns_mobile == 2 %}2{% elseif featured_columns_mobile == 3 %}3{% else %}2{% endif %};

                {% if featured_only_mobile_slider %}
                    if (window.innerWidth < 768) {
                {% elseif featured_only_desktop_slider %}
                    if (window.innerWidth > 768) {
                {% endif %}
                    window.swiperLoader('.js-swiper-featured', {
                        lazy: lazyVal,
                        watchOverflow: watchOverflowVal,
                        centerInsufficientSlides: centerInsufficientSlidesVal,
                        threshold: 5,
                        watchSlideProgress: true,
                        watchSlidesVisibility: true,
                        slideVisibleClass: 'js-swiper-slide-visible',
                        spaceBetween: itemSwiperSpaceBetween,
                    {% if sections.primary.products | length > 4 %}
                        loop: true,
                    {% endif %}
                        navigation: {
                            nextEl: '.js-swiper-featured-next',
                            prevEl: '.js-swiper-featured-prev',
                        },
                        pagination: {
                            el: '.js-swiper-featured-pagination',
                            type: 'fraction',
                        },
                        on: {
                            afterInit: function () {
                                hideSwiperControls(".js-swiper-featured-prev", ".js-swiper-featured-next");
                                themeNestedProductItemSliderRefresh();
                            },
                            slideChangeTransitionEnd: function () {
                                themeNestedProductItemSliderRefresh();
                            },
                        },
                        slidesPerView: slidesPerViewFeaturedMobileVal,
                    {% if featured_desktop_slider %}
                        breakpoints: {
                            768: {
                                slidesPerView: slidesPerViewFeaturedDesktopVal,
                            }
                        }
                    {% endif %}
                    });
                {% if featured_only_mobile_slider or featured_only_desktop_slider %}
                    }
                {% endif %}

            {% endif %}

            {% if has_new_products_slider %}

                {% set new_desktop_slider = settings.new_products_format_desktop == 'slider' %}
                {% set new_only_mobile_slider = settings.new_products_format_mobile == 'slider' and settings.new_products_format_desktop != 'slider' %}
                {% set new_only_desktop_slider = settings.new_products_format_desktop == 'slider' and settings.new_products_format_mobile != 'slider' %}
                {% set new_columns_desktop = settings.new_products_desktop %}
                {% set new_columns_mobile = settings.new_products_mobile %}
                var slidesPerViewNewDesktopVal = {% if new_columns_desktop == 2 %}2{% elseif new_columns_desktop == 3 %}3{% elseif new_columns_desktop == 4 %}4{% elseif new_columns_desktop == 5 %}5{% else %}4{% endif %};
                var slidesPerViewNewMobileVal = {% if new_columns_mobile == 1 %}1{% elseif new_columns_mobile == 2 %}2{% elseif new_columns_mobile == 3 %}3{% else %}2{% endif %};

                {% if new_only_mobile_slider %}
                    if (window.innerWidth < 768) {
                {% elseif new_only_desktop_slider %}
                    if (window.innerWidth > 768) {
                {% endif %}
                    window.swiperLoader('.js-swiper-new', {
                        lazy: lazyVal,
                        watchOverflow: watchOverflowVal,
                        centerInsufficientSlides: centerInsufficientSlidesVal,
                        threshold: 5,
                        watchSlideProgress: true,
                        watchSlidesVisibility: true,
                        slideVisibleClass: 'js-swiper-slide-visible',
                        spaceBetween: itemSwiperSpaceBetween,
                    {% if sections.new.products | length > 4 %}
                        loop: true,
                    {% endif %}
                        navigation: {
                            nextEl: '.js-swiper-new-next',
                            prevEl: '.js-swiper-new-prev',
                        },
                        pagination: {
                            el: '.js-swiper-new-pagination',
                            type: 'fraction',
                        },
                        on: {
                            afterInit: function () {
                                hideSwiperControls(".js-swiper-new-prev", ".js-swiper-new-next");
                                themeNestedProductItemSliderRefresh();
                            },
                            slideChangeTransitionEnd: function () {
                                themeNestedProductItemSliderRefresh();
                            },
                        },
                        slidesPerView: slidesPerViewNewMobileVal,
                    {% if new_desktop_slider %}
                        breakpoints: {
                            768: {
                                slidesPerView: slidesPerViewNewDesktopVal,
                            }
                        }
                    {% endif %}
                    });
                {% if new_only_mobile_slider or new_only_desktop_slider %}
                    }
                {% endif %}

            {% endif %}

            {% if has_sale_products_slider %}

                {% set sale_desktop_slider = settings.sale_products_format_desktop == 'slider' %}
                {% set sale_only_mobile_slider = settings.sale_products_format_mobile == 'slider' and settings.sale_products_format_desktop != 'slider' %}
                {% set sale_only_desktop_slider = settings.sale_products_format_desktop == 'slider' and settings.sale_products_format_mobile != 'slider' %}
                {% set sale_columns_desktop = settings.sale_products_desktop %}
                {% set sale_columns_mobile = settings.sale_products_mobile %}
                var slidesPerViewSaleDesktopVal = {% if sale_columns_desktop == 2 %}2{% elseif sale_columns_desktop == 3 %}3{% elseif sale_columns_desktop == 4 %}4{% elseif sale_columns_desktop == 5 %}5{% else %}4{% endif %};
                var slidesPerViewSaleMobileVal = {% if sale_columns_mobile == 1 %}1{% elseif sale_columns_mobile == 2 %}2{% elseif sale_columns_mobile == 3 %}3{% else %}2{% endif %};

                {% if sale_only_mobile_slider %}
                    if (window.innerWidth < 768) {
                {% elseif sale_only_desktop_slider %}
                    if (window.innerWidth > 768) {
                {% endif %}
                    window.swiperLoader('.js-swiper-sale', {
                        lazy: lazyVal,
                        watchOverflow: watchOverflowVal,
                        centerInsufficientSlides: centerInsufficientSlidesVal,
                        threshold: 5,
                        watchSlideProgress: true,
                        watchSlidesVisibility: true,
                        slideVisibleClass: 'js-swiper-slide-visible',
                        spaceBetween: itemSwiperSpaceBetween,
                    {% if sections.sale.products | length > 4 %}
                        loop: true,
                    {% endif %}
                        navigation: {
                            nextEl: '.js-swiper-sale-next',
                            prevEl: '.js-swiper-sale-prev',
                        },
                        pagination: {
                            el: '.js-swiper-sale-pagination',
                            type: 'fraction',
                        },
                        on: {
                            afterInit: function () {
                                hideSwiperControls(".js-swiper-sale-prev", ".js-swiper-sale-next");
                                themeNestedProductItemSliderRefresh();
                            },
                            slideChangeTransitionEnd: function () {
                                themeNestedProductItemSliderRefresh();
                            },
                        },
                        slidesPerView: slidesPerViewSaleMobileVal,
                    {% if sale_desktop_slider %}
                        breakpoints: {
                            768: {
                                slidesPerView: slidesPerViewSaleDesktopVal,
                            }
                        }
                    {% endif %}
                    });
                {% if sale_only_mobile_slider or sale_only_desktop_slider %}
                    }
                {% endif %}

            {% endif %}

        {% endif %}

        {# /* // Home demo products slider */ #}

        window.swiperLoader('.js-swiper-featured-demo', {
            lazy: true,
            loop: true,
            watchOverflow: true,
            spaceBetween: itemSwiperSpaceBetween,
            slidesPerView: slidesPerViewMobileVal,
            navigation: {
                nextEl: '.js-swiper-featured-demo-next',
                prevEl: '.js-swiper-featured-demo-prev',
            },
            pagination: {
                el: '.js-swiper-featured-demo-pagination',
                type: 'fraction',
            },
            breakpoints: {
                768: {
                    slidesPerView: 3,
                }
            }
        });

        {# /* // Home demo main categories slider */ #}

        createSwiper('.js-swiper-categories-demo', {
            watchOverflow: true,
            watchSlidesVisibility : true,
            slidesPerView: 'auto',
            spaceBetween: 20,
            navigation: {
                nextEl: '.js-swiper-categories-next-demo',
                prevEl: '.js-swiper-categories-prev-demo',
            },
            
            breakpoints: {
                768: {
                    loop: false,
                }
            }
        });

        {# /* // Home demo testimonial slider */ #}

        createSwiper('.js-swiper-testimonials-demo', {
            lazy: true,
            slidesPerView: 1,
            watchOverflow: true,
            threshold: 5,
            spaceBetween: 25,
            navigation: {
                nextEl: '.js-swiper-testimonials-next-demo',
                prevEl: '.js-swiper-testimonials-prev-demo',
            },
            breakpoints: {
                768: {
                    slidesPerView: 2,
                }
            }
        });

        {# /* // Home demo banner services slider */ #}

        createSwiper('.js-informative-banners-demo', {
            slidesPerView: 1.35,
            watchOverflow: true,
            threshold: 5,
            spaceBetween: 25,
            breakpoints: {
                768: {
                    slidesPerView: 'auto',
                    loop: false,
                }
            }
        });

        {# /* // Product demo slider */ #}

        createSwiper('.js-swiper-product-demo', {
            lazy: true,
            slidesPerView: 1,
            watchOverflow: true,
            spaceBetween: 25,
            navigation: {
                nextEl: '.js-swiper-product-next-demo',
                prevEl: '.js-swiper-product-prev-demo',
            },
            pagination: {
                el: '.js-swiper-product-pagination-demo',
                type: 'fraction',
            },
            breakpoints: {
                768: {
                    slidesPerView: 'auto',
                }
            },
        });

        {# /* // Brands slider */ #}

        {% if settings.brands and settings.brands is not empty %}

            createSwiper('.js-swiper-brands', {
                lazy: true,
                watchOverflow: true,
                centerInsufficientSlides: true,
                threshold: 5,
                slidesPerView: 3,
                navigation: {
                    nextEl: '.js-swiper-brands-next',
                    prevEl: '.js-swiper-brands-prev',
                },
                on: {
                    afterInit: function () {
                        hideSwiperControls(".js-swiper-brands-prev", ".js-swiper-brands-next");
                    },
                    {% if settings.brands | length > 3 and settings.brands | length < 6  %}
                        beforeInit: function () {
                            if (window.innerWidth > 768) {
                                jQueryNuvem(".js-swiper-brands-wrapper").addClass("justify-content-center");
                            }
                        },
                    {% endif %}
                },
                breakpoints: {
                    768: {
                        slidesPerView: 10,
                    }
                }
            });

        {% endif %}

        {# /* // Testimonials slider */ #}

        {% set has_testimonial_01 = settings.testimonial_01_description or settings.testimonial_01_name or "testimonial_01.jpg" | has_custom_image %}
        {% set has_testimonial_02 = settings.testimonial_02_description or settings.testimonial_02_name or "testimonial_02.jpg" | has_custom_image %}
        {% set has_testimonial_03 = settings.testimonial_03_description or settings.testimonial_03_name or "testimonial_03.jpg" | has_custom_image %}
        {% set has_testimonial_04 = settings.testimonial_04_description or settings.testimonial_04_name or "testimonial_04.jpg" | has_custom_image %}
        {% set has_testimonials = (has_testimonial_01 and has_testimonial_02) or (has_testimonial_01 and has_testimonial_03) or (has_testimonial_01 and has_testimonial_04) or (has_testimonial_02 and has_testimonial_03) or (has_testimonial_02 and has_testimonial_04) or (has_testimonial_03 and has_testimonial_04)  %}

        {% if has_testimonial_01 or has_testimonial_02 or has_testimonial_03 or has_testimonial_04 %}

            createSwiper('.js-swiper-testimonials', {
                lazy: true,
                slidesPerView: 1,
                watchOverflow: true,
                threshold: 5,
                spaceBetween: 25,
                navigation: {
                    nextEl: '.js-swiper-testimonials-next',
                    prevEl: '.js-swiper-testimonials-prev',
                },
                breakpoints: {
                    768: {
                        slidesPerView: 2,
                    }
                }
            });

        {% endif %}

        {# /* // Banner services slider */ #}

        {% set has_banner_services_01 = settings.banner_services_01_title or settings.banner_services_01_description %}
        {% set has_banner_services_02 = settings.banner_services_02_title or settings.banner_services_02_description %}
        {% set has_banner_services_03 = settings.banner_services_03_title or settings.banner_services_03_description %}
        {% set has_banner_services = settings.banner_services and (has_banner_services_01 or has_banner_services_02 or has_banner_services_03) %}
        {% set has_multiple_banners_services = (has_banner_services_01 and has_banner_services_02) or (has_banner_services_01 and has_banner_services_03) or (has_banner_services_02 and has_banner_services_03) %}

        {% if has_banner_services %}

            createSwiper('.js-informative-banners', {
                {% if has_multiple_banners_services %}
                    loop: true,
                    slidesPerView: 1.35,
                {% endif %}
                watchOverflow: true,
                threshold: 5,
                spaceBetween: 25,
                breakpoints: {
                    768: {
                        slidesPerView: 'auto',
                        loop: false,
                    }
                }
            });
        {% endif %}

        {# /* // Banners slider */ #}

        {# Category banners #}

        {% if settings.banner_format_mobile == 'slider' or settings.banner_format_desktop == 'slider' %}

            {% set banner_desktop_slider = settings.banner_format_desktop == 'slider' %}
            {% set banner_only_mobile_slider = settings.banner_format_mobile == 'slider' and settings.banner_format_desktop != 'slider' %}
            {% set banner_only_desktop_slider = settings.banner_format_desktop == 'slider' and settings.banner_format_mobile != 'slider' %}
            {% set banner_columns_desktop = settings.banner_columns_desktop %}

            var bannersPerViewDesktopVal = {% if banner_columns_desktop == 4 %}4{% elseif banner_columns_desktop == 3 %}3{% elseif banner_columns_desktop == 2 %}2{% else %}1{% endif %};
            var bannersSpaceBetween = {% if settings.banner_without_margins %}0{% else %}itemSwiperSpaceBetween{% endif %};

            {% if banner_only_mobile_slider %}
                if (window.innerWidth < 768) {
            {% elseif banner_only_desktop_slider %}
                if (window.innerWidth > 768) {
            {% endif %}

                {# General banners #}

                {% if settings.banner and settings.banner is not empty %}

                    createSwiper('.js-swiper-banners', {
                        lazy: true,
                        watchOverflow: true,
                        threshold: 5,
                        watchSlideProgress: true,
                        watchSlidesVisibility: true,
                        slideVisibleClass: 'js-swiper-slide-visible',
                        spaceBetween: bannersSpaceBetween,
                        navigation: {
                            nextEl: '.js-swiper-banners-next',
                            prevEl: '.js-swiper-banners-prev',
                        },
                        slidesPerView: 1,
                        on: {
                            afterInit: function () {
                                hideSwiperControls(".js-swiper-banners-prev", ".js-swiper-banners-next");
                            },
                        },
                    {% if banner_desktop_slider %}
                        breakpoints: {
                            768: {
                                slidesPerView: bannersPerViewDesktopVal,
                            }
                        }
                    {% endif %}
                    });

                {% endif %}

                {# Mobile banners #}

                {% if settings.toggle_banner_mobile and settings.banner_mobile and settings.banner_mobile is not empty %}

                     createSwiper('.js-swiper-banners-mobile', {
                        lazy: true,
                        watchOverflow: true,
                        threshold: 5,
                        watchSlideProgress: true,
                        watchSlidesVisibility: true,
                        slideVisibleClass: 'js-swiper-slide-visible',
                        spaceBetween: bannersSpaceBetween,
                        navigation: {
                            nextEl: '.js-swiper-banners-mobile-next',
                            prevEl: '.js-swiper-banners-mobile-prev',
                        },
                        slidesPerView: 1,
                        on: {
                            afterInit: function () {
                                hideSwiperControls(".js-swiper-banners-mobile-prev", ".js-swiper-banners-mobile-next");
                            },
                        },
                    {% if banner_desktop_slider %}
                        breakpoints: {
                            768: {
                                slidesPerView: bannersPerViewDesktopVal,
                            }
                        }
                    {% endif %}
                    });

                {% endif %}

            {% if banner_only_mobile_slider or banner_only_desktop_slider %}
                }
            {% endif %}

        {% endif %}

        {# Promotional banners #}

        {% if settings.banner_promotional_format_mobile == 'slider' or settings.banner_promotional_format_desktop == 'slider' %}

            {% set banner_promotional_desktop_slider = settings.banner_promotional_format_desktop == 'slider' %}
            {% set banner_promotional_only_mobile_slider = settings.banner_promotional_format_mobile == 'slider' and settings.banner_promotional_format_desktop != 'slider' %}
            {% set banner_promotional_only_desktop_slider = settings.banner_promotional_format_desktop == 'slider' and settings.banner_promotional_format_mobile != 'slider' %}
            {% set banner_promotional_columns_desktop = settings.banner_promotional_columns_desktop %}

            var bannersPromotionalPerViewDesktopVal = {% if banner_promotional_columns_desktop == 4 %}4{% elseif banner_promotional_columns_desktop == 3 %}3{% elseif banner_promotional_columns_desktop == 2 %}2{% else %}1{% endif %};
            var bannersPromotionalSpaceBetween = {% if settings.banner_promotional_without_margins %}0{% else %}itemSwiperSpaceBetween{% endif %};

            {% if banner_promotional_only_mobile_slider %}
                if (window.innerWidth < 768) {
            {% elseif banner_promotional_only_desktop_slider %}
                if (window.innerWidth > 768) {
            {% endif %}

                {# General banners #}

                {% if settings.banner_promotional and settings.banner_promotional is not empty %}

                    createSwiper('.js-swiper-banners-promotional', {
                        lazy: true,
                        watchOverflow: true,
                        threshold: 5,
                        watchSlideProgress: true,
                        watchSlidesVisibility: true,
                        slideVisibleClass: 'js-swiper-slide-visible',
                        spaceBetween: bannersPromotionalSpaceBetween,
                        navigation: {
                            nextEl: '.js-swiper-banners-promotional-next',
                            prevEl: '.js-swiper-banners-promotional-prev',
                        },
                        on: {
                            afterInit: function () {
                                hideSwiperControls(".js-swiper-banners-promotional-prev", ".js-swiper-banners-promotional-next");
                            },
                        },
                        slidesPerView: 1,
                    {% if banner_promotional_desktop_slider %}
                        breakpoints: {
                            768: {
                                slidesPerView: bannersPromotionalPerViewDesktopVal,
                            }
                        }
                    {% endif %}
                    });

                {% endif %}

                {# Mobile banners #}

                {% if settings.toggle_banner_promotional_mobile and settings.banner_promotional_mobile and settings.banner_promotional_mobile is not empty %}

                    createSwiper('.js-swiper-banners-promotional-mobile', {
                        lazy: true,
                        watchOverflow: true,
                        threshold: 5,
                        watchSlideProgress: true,
                        watchSlidesVisibility: true,
                        slideVisibleClass: 'js-swiper-slide-visible',
                        spaceBetween: bannersPromotionalSpaceBetween,
                        navigation: {
                            nextEl: '.js-swiper-banners-promotional-mobile-next',
                            prevEl: '.js-swiper-banners-promotional-mobile-prev',
                        },
                        on: {
                            afterInit: function () {
                                hideSwiperControls(".js-swiper-banners-promotional-mobile-prev", ".js-swiper-banners-promotional-mobile-next");
                            },
                        },
                        slidesPerView: 1,
                    {% if banner_promotional_desktop_slider %}
                        breakpoints: {
                            768: {
                                slidesPerView: bannersPromotionalPerViewDesktopVal,
                            }
                        }
                    {% endif %}
                    });

                {% endif %}

            {% if banner_promotional_only_mobile_slider or banner_promotional_only_desktop_slider %}
                }
            {% endif %}

        {% endif %}

        {# News banners #}

        {% if settings.banner_news_format_mobile == 'slider' or settings.banner_news_format_desktop == 'slider' %}

            {% set banner_news_desktop_slider = settings.banner_news_format_desktop == 'slider' %}
            {% set banner_news_only_mobile_slider = settings.banner_news_format_mobile == 'slider' and settings.banner_news_format_desktop != 'slider' %}
            {% set banner_news_only_desktop_slider = settings.banner_news_format_desktop == 'slider' and settings.banner_news_format_mobile != 'slider' %}
            {% set banner_news_columns_desktop = settings.banner_news_columns_desktop %}

            var bannersNewsPerViewDesktopVal = {% if banner_news_columns_desktop == 4 %}4{% elseif banner_news_columns_desktop == 3 %}3{% elseif banner_news_columns_desktop == 2 %}2{% else %}1{% endif %};
            var bannersNewsSpaceBetween = {% if settings.banner_news_without_margins %}0{% else %}itemSwiperSpaceBetween{% endif %};

            {% if banner_news_only_mobile_slider %}
                if (window.innerWidth < 768) {
            {% elseif banner_news_only_desktop_slider %}
                if (window.innerWidth > 768) {
            {% endif %}

                {# General banners #}

                {% if settings.banner_news and settings.banner_news is not empty %}

                    createSwiper('.js-swiper-banners-news', {
                        lazy: true,
                        watchOverflow: true,
                        threshold: 5,
                        watchSlideProgress: true,
                        watchSlidesVisibility: true,
                        slideVisibleClass: 'js-swiper-slide-visible',
                        spaceBetween: bannersNewsSpaceBetween,
                        navigation: {
                            nextEl: '.js-swiper-banners-news-next',
                            prevEl: '.js-swiper-banners-news-prev',
                        },
                        on: {
                            afterInit: function () {
                                hideSwiperControls(".js-swiper-banners-news-prev", ".js-swiper-banners-news-next");
                            },
                        },
                        slidesPerView: 1,
                    {% if banner_news_desktop_slider %}
                        breakpoints: {
                            768: {
                                slidesPerView: bannersNewsPerViewDesktopVal,
                            }
                        }
                    {% endif %}
                    });

                {% endif %}

                {# Mobile banners #}

                {% if settings.toggle_banner_news_mobile and settings.banner_news_mobile and settings.banner_news_mobile is not empty %}

                    createSwiper('.js-swiper-banners-news-mobile', {
                        lazy: true,
                        watchOverflow: true,
                        threshold: 5,
                        watchSlideProgress: true,
                        watchSlidesVisibility: true,
                        slideVisibleClass: 'js-swiper-slide-visible',
                        spaceBetween: bannersNewsSpaceBetween,
                        navigation: {
                            nextEl: '.js-swiper-banners-news-mobile-next',
                            prevEl: '.js-swiper-banners-news-mobile-prev',
                        },
                        on: {
                            afterInit: function () {
                                hideSwiperControls(".js-swiper-banners-news-mobile-prev", ".js-swiper-banners-news-mobile-next");
                            },
                        },
                        slidesPerView: 1,
                    {% if banner_news_desktop_slider %}
                        breakpoints: {
                            768: {
                                slidesPerView: bannersNewsPerViewDesktopVal,
                            }
                        }
                    {% endif %}
                    });

                {% endif %}

            {% if banner_news_only_mobile_slider or banner_news_only_desktop_slider %}
                }
            {% endif %}

        {% endif %}

        {# Image and text modules #}

        {% if settings.module_slider and settings.module and settings.module is not empty %}

            createSwiper('.js-swiper-modules', {
                lazy: true,
                watchOverflow: true,
                threshold: 5,
                watchSlideProgress: true,
                watchSlidesVisibility: true,
                slideVisibleClass: 'js-swiper-slide-visible',
                spaceBetween: itemSwiperSpaceBetween,
                centerInsufficientSlides: true,
                navigation: {
                    nextEl: '.js-swiper-modules-next',
                    prevEl: '.js-swiper-modules-prev',
                },
                slidesPerView: 1,
                on: {
                    afterInit: function () {
                        hideSwiperControls(".js-swiper-modules-prev", ".js-swiper-modules-next");
                    },
                },
            });

        {% endif %}

        {% if settings.show_instafeed and store.instagram and store.hasInstagramToken() %}
            createSwiper('.js-swiper-instafeed', {
                lazy: true,
                watchOverflow: true,
                spaceBetween: itemSwiperSpaceBetween,
                slidesPerView: 1.15,
                observer: true,
                breakpoints: {
                    768: {
                        slidesPerView: 3,
                    }
                }
            });
        {% endif %}

        {# /* // Main categories */ #}

        {% if settings.main_categories %}

            createSwiper('.js-swiper-categories', {
                lazy: true,
                {% if settings.slider_categories | length > 3 %}
                    loop: true,
                {% endif %}
                preloadImages : false,
                watchOverflow: true,
                watchSlidesVisibility : true,
                slidesPerView: 'auto',
                navigation: {
                    nextEl: '.js-swiper-categories-next',
                    prevEl: '.js-swiper-categories-prev',
                },
                on: {
                    afterInit: function () {
                        hideSwiperControls(".js-swiper-categories-prev", ".js-swiper-categories-next");
                    },
                },
                breakpoints: {
                    768: {
                        loop: false,
                    }
                }
            });

        {% endif %}

        {# /* // Product description toggle */ #}

        {% if sections.featured.products %}
            if (jQueryNuvem('.js-product-description').height() < jQueryNuvem('.js-product-description').prop("scrollHeight")){
                jQueryNuvem(".js-view-description").show();
            }

            jQueryNuvem(document).on("click", ".js-view-description", function(e) {
                e.preventDefault();
                jQueryNuvem(this).prev(".js-product-description").toggleClass("product-description-full");
                jQueryNuvem(".js-view-more, .js-view-less").toggle();
            });
        {% endif %}

	{% endif %}

    {% if template == 'product' %}

        {# /* // Product Related */ #}

        // Set loop for related products products sliders

        function calculateRelatedLoopVal(sectionSelector) {
            let productsAmount = jQueryNuvem(sectionSelector).attr("data-related-amount");
            let loopVal = false;
            const applyLoop = (window.innerWidth < 768 && productsAmount > slidesPerViewMobileVal) || (window.innerWidth > 768 && productsAmount > slidesPerViewDesktopVal);
            
            if (applyLoop) {
                loopVal = true;
            }

            return loopVal;
        }

        let alternativeLoopVal = calculateRelatedLoopVal(".js-related-products");
        let complementaryLoopVal = calculateRelatedLoopVal(".js-complementary-products");

        {# Alternative products #}

        createSwiper('.js-swiper-related', {
            lazy: true,
            loop: alternativeLoopVal,
            watchOverflow: true,
            threshold: 5,
            watchSlideProgress: true,
            watchSlidesVisibility: true,
            spaceBetween: itemSwiperSpaceBetween,
            slideVisibleClass: 'js-swiper-slide-visible',
            slidesPerView: slidesPerViewMobileVal,
            navigation: {
                nextEl: '.js-swiper-related-next',
                prevEl: '.js-swiper-related-prev',
            },
            on: {
                afterInit: function () {
                    hideSwiperControls(".js-swiper-related-prev", ".js-swiper-related-next");
                    themeNestedProductItemSliderRefresh();
                },
            },
            breakpoints: {
                768: {
                    slidesPerView: slidesPerViewDesktopVal,
                }
            }
        });

        {# Complementary products #}

        createSwiper('.js-swiper-complementary', {
            lazy: true,
            loop: complementaryLoopVal,
            watchOverflow: true,
            threshold: 5,
            watchSlideProgress: true,
            watchSlidesVisibility: true,
            spaceBetween: itemSwiperSpaceBetween,
            slideVisibleClass: 'js-swiper-slide-visible',
            slidesPerView: slidesPerViewMobileVal,
            navigation: {
                nextEl: '.js-swiper-complementary-next',
                prevEl: '.js-swiper-complementary-prev',
            },
            on: {
                afterInit: function () {
                    hideSwiperControls(".js-swiper-complementary-prev", ".js-swiper-complementary-next");
                    themeNestedProductItemSliderRefresh();
                },
            },
            breakpoints: {
                768: {
                    slidesPerView: slidesPerViewDesktopVal,
                }
            }
        });

        {% if settings.brand_pdp_store_sections_enable %}
        {# Carruseles PDP desde secciones de tienda (pdp_bundles_*) #}

        if (jQueryNuvem('.js-swiper-pdp-sec-complementary').length) {
            let pdpSecCompLoopVal = calculateRelatedLoopVal('.js-pdp-sec-complementary-products');
            createSwiper('.js-swiper-pdp-sec-complementary', {
                lazy: true,
                loop: pdpSecCompLoopVal,
                watchOverflow: true,
                threshold: 5,
                watchSlideProgress: true,
                watchSlidesVisibility: true,
                spaceBetween: itemSwiperSpaceBetween,
                slideVisibleClass: 'js-swiper-slide-visible',
                slidesPerView: slidesPerViewMobileVal,
                navigation: {
                    nextEl: '.js-swiper-pdp-sec-complementary-next',
                    prevEl: '.js-swiper-pdp-sec-complementary-prev',
                },
                on: {
                    afterInit: function () {
                        hideSwiperControls('.js-swiper-pdp-sec-complementary-prev', '.js-swiper-pdp-sec-complementary-next');
                        themeNestedProductItemSliderRefresh();
                    },
                },
                breakpoints: {
                    768: {
                        slidesPerView: slidesPerViewDesktopVal,
                    },
                },
            });
        }

        if (jQueryNuvem('.js-swiper-pdp-sec-alternative').length) {
            let pdpSecAltLoopVal = calculateRelatedLoopVal('.js-pdp-sec-alternatives-products');
            createSwiper('.js-swiper-pdp-sec-alternative', {
                lazy: true,
                loop: pdpSecAltLoopVal,
                watchOverflow: true,
                threshold: 5,
                watchSlideProgress: true,
                watchSlidesVisibility: true,
                spaceBetween: itemSwiperSpaceBetween,
                slideVisibleClass: 'js-swiper-slide-visible',
                slidesPerView: slidesPerViewMobileVal,
                navigation: {
                    nextEl: '.js-swiper-pdp-sec-alternative-next',
                    prevEl: '.js-swiper-pdp-sec-alternative-prev',
                },
                on: {
                    afterInit: function () {
                        hideSwiperControls('.js-swiper-pdp-sec-alternative-prev', '.js-swiper-pdp-sec-alternative-next');
                        themeNestedProductItemSliderRefresh();
                    },
                },
                breakpoints: {
                    768: {
                        slidesPerView: slidesPerViewDesktopVal,
                    },
                },
            });
        }
        {% endif %}

        {# PDP boutique: ocultar boton secundario tipo "Pago exprés" que inyecta la plataforma junto al formulario #}
        (function () {
            var box = document.querySelector('#single-product.pdp-app--represent .pdp-app-buybox');
            if (!box) {
                return;
            }
            var rx = /(pago\s*expres|pago\s*exprés|pago\s*express|express\s*checkout)/i;
            function hideExpressCheckoutButtons() {
                jQueryNuvem(box).find('a, button').each(function () {
                    var el = jQueryNuvem(this);
                    if (el.closest('.form-quantity').length || el.hasClass('js-addtocart') || el.hasClass('js-prod-submit-form') || el.hasClass('js-modal-open') || el.closest('.js-modal-open').length) {
                        return;
                    }
                    var txt = (el.text() || '').trim();
                    if (!txt || txt.length > 120) {
                        return;
                    }
                    if (!rx.test(txt)) {
                        return;
                    }
                    var col = el.closest('.col-12');
                    if (col.length && col.children('a, button').length <= 4) {
                        col.css('display', 'none');
                    } else {
                        el.css('display', 'none');
                    }
                });
            }
            hideExpressCheckoutButtons();
            setTimeout(hideExpressCheckoutButtons, 800);
            setTimeout(hideExpressCheckoutButtons, 2600);
            if (typeof MutationObserver !== 'undefined') {
                var moTimer;
                var mo = new MutationObserver(function () {
                    if (moTimer) {
                        clearTimeout(moTimer);
                    }
                    moTimer = setTimeout(hideExpressCheckoutButtons, 80);
                });
                mo.observe(box, { childList: true, subtree: true });
            }
        })();


    {% endif %}

	{#/*============================================================================
	  #Social
	==============================================================================*/ #}

    {% if template == 'home' and settings.video_embed %}
        {% set video_url = settings.video_embed %}
        {% if '/watch?v=' in settings.video_embed %}
            {% set video_format = '/watch?v=' %}
        {% elseif '/youtu.be/' in settings.video_embed %}
            {% set video_format = '/youtu.be/' %}
        {% elseif '/shorts/' in settings.video_embed %}
            {% set video_format = '/shorts/' %}
        {% endif %}
        {% set video_id = video_url|split(video_format)|last %}

        {# /* // Youtube video with autoplay */ #}

        function loadVideoFrame() {
            window.youtubeIframeService.executeOnReady(() => { 
                new YT.Player('player', {
                        width: '100%',
                        videoId: '{{video_id}}',
                        playerVars: { 'autoplay': 1, 'playsinline': 1, 'rel': 0, 'loop': 1, 'autopause': 0, 'controls': 0, 'showinfo': 0, 'modestbranding': 1, 'branding': 0, 'fs': 0, 'iv_load_policy': 3 },
                        events: {
                            'onReady': onPlayerReady,
                            'onStateChange':onPlayerStateChange
                        }
                    }
                );
            });
        };

        {% if settings.home_order_position_1 == 'video' and settings.video_type == 'autoplay' %}
            if (window.innerWidth < 768) {
                window.addEventListener("pointerdown", () => {
                    loadVideoFrame();
                }, { once: true });
            } else {
                loadVideoFrame();
            }
        {% else %}
            {% if settings.video_type == 'autoplay' %}
                jQueryNuvem('.js-home-video-container').on('lazyloaded', function(e){
                    loadVideoFrame();
                });
            {% else %}
                jQueryNuvem('.js-play-button').on("click", function(e){
                    e.preventDefault();
                    jQueryNuvem(this).hide();
                    jQueryNuvem(".js-home-video-image").hide();
                    loadVideoFrame();
                });
            {% endif %}
        {% endif %}
        

        function onPlayerReady(event) {
            {% if settings.video_type == 'autoplay' %}
                event.target.mute();
            {% endif %}
            event.target.playVideo();
        }

        function onPlayerStateChange(event) {
            {% if settings.home_order_position_1 == 'video' %}
                if (event.data == YT.PlayerState.PLAYING) {
                    jQueryNuvem(".js-home-video-image").addClass("fade-in");
                }
            {% endif %}
            if (event.data == YT.PlayerState.ENDED) {
                event.target.seekTo(0);
                event.target.playVideo();
            }
        }

    {% endif %}

    {% if template == 'product' and product.video_url %}
        {% set video_url = product.video_url %}
        {# /* // Youtube or Vimeo video for home or each product */ #}
        LS.loadVideo('{{ video_url }}');
    {% endif %}


	{#/*============================================================================
	  #Product grid
	==============================================================================*/ #}

    var nav_height = jQueryNuvem(".js-head-main").innerHeight();

	{% if template == 'category' or template == 'search' %}

        {# /* // Fixed category controls */ #}

            if (window.innerWidth < 768) {

                $category_controls.css("top" , nav_height.toString() + 'px');

                {# Detect if category controls are sticky and add css #}

                var observer = new IntersectionObserver(function(entries) {
                    if(entries[0].intersectionRatio === 0)
                        $category_controls.addClass("is-sticky");
                    else if(entries[0].intersectionRatio === 1)
                        $category_controls.removeClass("is-sticky");
                    }, { threshold: [0,1]
                });
                observer.observe(document.querySelector(".js-category-controls-prev"));

                offsetCategories = function() {
                    var $sticky_category_controls = jQueryNuvem(".js-category-controls");

                    var categoriesOffset = jQueryNuvem(".js-head-main").outerHeight();

                    if(jQueryNuvem(".js-head-main").hasClass("compress")){
                        var categoriesOffset = categoriesOffset - topbarHeight - 1;
                    }

                    $sticky_category_controls.css('top', (categoriesOffset).toString() + 'px' );
                };

                offsetCategories();

                document.addEventListener("scroll", function(){
                    offsetCategories();
                });

            }

        {# /* // Filters */ #}

        {% if has_applied_filters %}
            jQueryNuvem('.js-filter-container').each(function(el) {
                const filterActive = jQueryNuvem(el).find(".js-filter-checkbox [type=checkbox]:checked");
                filterActive.closest(".js-filter-container").find(".js-filters-badge").text(filterActive.length).show();
            });
            const applied_filters = jQueryNuvem("#nav-filters .js-remove-filter-chip").length;
            jQueryNuvem(".js-filters-total-badge").text(applied_filters);
        {% endif %}        

	{% endif %}

    {% if template == 'category' or template == 'search' or template == 'home' %}
        (function initUserProductGridPicker() {
            var STORAGE_PREFIX = 'tnUserGrid_';

            function storageKey(ctx, axis) {
                return STORAGE_PREFIX + ctx + '_' + axis;
            }

            function notifyLayoutAfterGridDensityChange() {
                requestAnimationFrame(function () {
                    window.dispatchEvent(new Event('resize'));
                    var ls = window.lazySizes;
                    if (ls) {
                        if (ls.autoSizer && typeof ls.autoSizer.checkElems === 'function') {
                            ls.autoSizer.checkElems();
                        }
                        if (ls.loader && typeof ls.loader.checkElems === 'function') {
                            ls.loader.checkElems();
                        }
                    }
                });
            }

            function syncToolbar(wrap) {
                var ctx = wrap.getAttribute('data-grid-context');
                if (!ctx) {
                    return;
                }
                var um = wrap.getAttribute('data-user-mobile') || '';
                var ud = wrap.getAttribute('data-user-desktop') || '';
                var roots = document.querySelectorAll(
                    '.js-user-product-grid[data-grid-context="' + ctx + '"], [data-user-grid-toolbar-for="' + ctx + '"]'
                );
                roots.forEach(function (root) {
                    root.querySelectorAll('[data-user-grid-set-mobile]').forEach(function (btn) {
                        var v = btn.getAttribute('data-user-grid-set-mobile');
                        var on = um !== '' && v === um;
                        btn.classList.toggle('active', on);
                        btn.setAttribute('aria-pressed', on ? 'true' : 'false');
                    });
                    root.querySelectorAll('[data-user-grid-set-desktop]').forEach(function (btn) {
                        var v = btn.getAttribute('data-user-grid-set-desktop');
                        var on = ud !== '' && v === ud;
                        btn.classList.toggle('active', on);
                        btn.setAttribute('aria-pressed', on ? 'true' : 'false');
                    });
                    var resetBtn = root.querySelector('[data-user-grid-reset]');
                    if (resetBtn) {
                        resetBtn.disabled = !(um || ud);
                    }
                });
            }

            function applyFromStorage(wrap) {
                var ctx = wrap.getAttribute('data-grid-context');
                if (!ctx) {
                    return;
                }
                try {
                    var m = localStorage.getItem(storageKey(ctx, 'm'));
                    var d = localStorage.getItem(storageKey(ctx, 'd'));
                    if (m === '1' || m === '2' || m === '3') {
                        wrap.setAttribute('data-user-mobile', m);
                    }
                    if (d === '2' || d === '3' || d === '4' || d === '5') {
                        wrap.setAttribute('data-user-desktop', d);
                    }
                } catch (e) {
                    /* ignore */
                }
                syncToolbar(wrap);
            }

            function clearOverride(wrap) {
                var ctx = wrap.getAttribute('data-grid-context');
                wrap.removeAttribute('data-user-mobile');
                wrap.removeAttribute('data-user-desktop');
                try {
                    if (ctx) {
                        localStorage.removeItem(storageKey(ctx, 'm'));
                        localStorage.removeItem(storageKey(ctx, 'd'));
                    }
                } catch (e2) {
                    /* ignore */
                }
                syncToolbar(wrap);
                notifyLayoutAfterGridDensityChange();
            }

            document.addEventListener('click', function (e) {
                var t = e.target;
                if (!t || !t.closest) {
                    return;
                }
                var mb = t.closest('[data-user-grid-set-mobile]');
                var db = t.closest('[data-user-grid-set-desktop]');
                var rs = t.closest('[data-user-grid-reset]');
                if (!mb && !db && !rs) {
                    return;
                }
                var toolbar = t.closest('[data-user-grid-toolbar-for]');
                var wrap = toolbar
                    ? document.querySelector('.js-user-product-grid[data-grid-context="' + toolbar.getAttribute('data-user-grid-toolbar-for') + '"]')
                    : t.closest('.js-user-product-grid');
                if (!wrap) {
                    return;
                }
                if (mb) {
                    var vm = mb.getAttribute('data-user-grid-set-mobile');
                    wrap.setAttribute('data-user-mobile', vm);
                    try {
                        localStorage.setItem(storageKey(wrap.getAttribute('data-grid-context'), 'm'), vm);
                    } catch (e3) {
                        /* ignore */
                    }
                    syncToolbar(wrap);
                    notifyLayoutAfterGridDensityChange();
                    return;
                }
                if (db) {
                    var vd = db.getAttribute('data-user-grid-set-desktop');
                    wrap.setAttribute('data-user-desktop', vd);
                    try {
                        localStorage.setItem(storageKey(wrap.getAttribute('data-grid-context'), 'd'), vd);
                    } catch (e4) {
                        /* ignore */
                    }
                    syncToolbar(wrap);
                    notifyLayoutAfterGridDensityChange();
                    return;
                }
                if (rs) {
                    clearOverride(wrap);
                }
            });

            var userGridWraps = document.querySelectorAll('.js-user-product-grid');
            userGridWraps.forEach(function (wrap) {
                applyFromStorage(wrap);
            });
            if (userGridWraps.length) {
                notifyLayoutAfterGridDensityChange();
            }
        })();
    {% endif %}

    {% set has_item_slider = settings.product_item_slider %}

    {% if template == 'category' or template == 'search' %}

        (function initCatalogBenefitsTicker() {
            var mq = window.matchMedia('(max-width: 767px)');
            var roots = document.querySelectorAll('[data-catalog-benefits-ticker]');
            var timers = [];

            function clearTimers() {
                timers.forEach(function (id) {
                    clearInterval(id);
                });
                timers = [];
            }

            function clearActive(root) {
                root.querySelectorAll('.catalog-benefits-bar__item[data-benefit-tick]').forEach(function (el) {
                    el.classList.remove('is-active');
                });
            }

            function setupRoot(root) {
                var items = root.querySelectorAll('.catalog-benefits-bar__item[data-benefit-tick]');
                if (items.length < 2) {
                    return;
                }
                var i = 0;
                function tick() {
                    items.forEach(function (el, idx) {
                        el.classList.toggle('is-active', idx === i);
                    });
                    i = (i + 1) % items.length;
                }
                tick();
                timers.push(setInterval(tick, 4500));
            }

            function run() {
                clearTimers();
                roots.forEach(function (root) {
                    clearActive(root);
                });
                if (!mq.matches || window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
                    roots.forEach(function (root) {
                        var first = root.querySelector('.catalog-benefits-bar__item[data-benefit-tick]');
                        if (first) {
                            first.classList.add('is-active');
                        }
                    });
                    return;
                }
                roots.forEach(setupRoot);
            }

            if (roots.length) {
                run();
                if (mq.addEventListener) {
                    mq.addEventListener('change', run);
                } else if (mq.addListener) {
                    mq.addListener(run);
                }
            }
        })();

        {# /* // Product item slider */ #}
        {# Barajar ítems antes de inicializar Swiper por producto (reordenar después rompe el carrusel). #}
        if (window.themeShuffleGridRow) {
            window.themeShuffleGridRow(jQueryNuvem('.js-product-table.row.row-grid').first());
        }

        {% if settings.pagination == 'infinite' %}
            !function() {

                {# /* // Infinite scroll */ #}

                {% if pages.current == 1 and not pages.is_last %}
                    LS.hybridScroll({
                        productGridSelector: '.js-product-table',
                        spinnerSelector: '#js-infinite-scroll-spinner',
                        loadMoreButtonSelector: '.js-load-more',
                        hideWhileScrollingSelector: ".js-hide-footer-while-scrolling",
                        productsBeforeLoadMoreButton: 50,
                        productsPerPage: 12,
                        afterLoaded: function(){
                            jQueryNuvem('.js-item-product').addClass('is-inViewport');

                            {% if has_item_slider %}
                                LS.productItemSlider({
                                    pagination_type: 'bullets',
                                });
                            {% endif %}
                        },
                    });
                {% endif %}
            }();

        {% endif %}

	{% endif %}

    {# /* // Variants without stock */ #}

    {% set is_button_variant = settings.bullet_variants or settings.image_color_variants %}

    {% if is_button_variant %}
        const noStockVariants = (container = null) => {

            {# Configuration for variant elements #}
            const config = {
                variantsGroup: ".js-product-variants-group",
                variantButton: ".js-insta-variant",
                noStockClass: "btn-variant-no-stock",
                dataVariationId: "data-variation-id",
                dataOption: "data-option"
            };

            {# Product container wrapper #}
            const wrapper = container ? container : jQueryNuvem('#single-product');
            if (!wrapper) return;

            {# Fetch the variants data from the container #}
            const dataVariants = wrapper.data('variants');
            const variantsLength = wrapper.find(config.variantsGroup).length;

            {# Get selected options from product variations #}
            const getOptions = (productVariationId, variantOption) => {
                if (productVariationId === 2) {
                    return {
                        option0: String(wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="0"] select`).val()),
                        option1: String(wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="1"] select`).val()),
                        option2: String(jQueryNuvem(variantOption).attr('data-option')),
                    };
                } else if (productVariationId === 1) {
                    return {
                        option0: String(wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="0"] select`).val()),
                        option1: String(jQueryNuvem(variantOption).attr('data-option')),
                    };
                } else {
                    return {
                        option0: String(jQueryNuvem(variantOption).attr('data-option')),
                    };
                }
            };

            {# Filter available variants based on selected options #}
            const filterVariants = (options) => {
                return dataVariants.filter(variant => {
                    return Object.keys(options).every(optionKey => variant[optionKey] === options[optionKey]) && variant.available;
                });
            };

            {# Update stock status for variant buttons #}
            const updateStockStatus = (productVariationId) => {
                const variationGroup = wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="${productVariationId}"]`);
                variationGroup.find(`${config.variantButton}.${config.noStockClass}`).removeClass(config.noStockClass);

                variationGroup.find(config.variantButton).each((variantOption, item) => {
                    const options = getOptions(productVariationId, variantOption);
                    const itemsAvailable = filterVariants(options);
                    const button = wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="${productVariationId}"] ${config.variantButton}[${config.dataOption}="${options[`option${productVariationId}`].replace(/"/g, '\\"')}"]`);
                    
                    if (!itemsAvailable.length) {
                        button.addClass(config.noStockClass);
                    }
                });
            };

            {# Iterate through all variant and update stock status #}
            for (let productVariationId = variantsLength - 1; productVariationId >= 0; productVariationId--) {
                updateStockStatus(productVariationId);
            }
        };

        noStockVariants();

    {% endif %}

    {% if settings.quick_shop %}

        {# /* // Quickshop */ #}
        jQueryNuvem(document).on("click", ".js-quickshop-modal-open", function (e) {
            e.preventDefault();
            var $this = jQueryNuvem(this);
            if($this.hasClass("js-quickshop-slide")){
                jQueryNuvem("#quickshop-modal .js-item-product").addClass("js-swiper-slide-visible js-item-slide");
            }

            {% if is_button_variant %}
                {# Updates variants without stock #}
                let container = jQueryNuvem(this).closest('.js-quickshop-container');
                if (!container.length) return;
                noStockVariants(container);
            {% endif %}

            LS.fillQuickshop($this);

            var $srcItem = $this.closest('.js-item-product');
            var $qh = jQueryNuvem('#quickshop-modal .js-theme-transfer-quickshop');
            if ($qh.length) {
                var tpct = $srcItem.attr('data-transfer-pct');
                var tsfx = $srcItem.attr('data-transfer-suffix');
                if (tpct) {
                    $qh.attr('data-transfer-pct', tpct).show();
                    $qh.find('.js-theme-transfer-quickshop-label').text(tsfx ? (' ' + tsfx) : '');
                } else {
                    $qh.attr('data-transfer-pct', '').hide();
                }
            }

            setTimeout(function () {
                themeRefreshTransferLines(jQueryNuvem('#quickshop-modal'));
            }, 0);

            if (window.innerWidth < 768) {
                {# Image dimensions #}

                var product_image_dimension = jQueryNuvem(this).closest('.js-item-product').find('.js-item-image-padding').attr("style");
                jQueryNuvem("#quickshop-modal .js-quickshop-image-padding").attr("style", product_image_dimension);

            }
        });

    {% endif %}

    {% if settings.bullet_variants or settings.product_color_variants or settings.image_color_variants or (settings.product_listing_variant_images | default(false)) %}
        changeVariantButton = function(selector, parentSelector) {
            selector.siblings().removeClass("selected");
            selector.addClass("selected");
            {# Micro-feedback al elegir talle/color (CSS theme-variant-pulse). #}
            var prevPulse = selector.data("themeVariantPulseTimer");
            if (prevPulse) {
                clearTimeout(prevPulse);
            }
            selector.addClass("theme-variant-pulse");
            selector.data("themeVariantPulseTimer", setTimeout(function () {
                selector.removeClass("theme-variant-pulse");
                selector.removeData("themeVariantPulseTimer");
            }, 420));
            var option_id = selector.attr('data-option');
            var parent = selector.closest(parentSelector);
            var $sel = parent.find('select.js-variation-option').first();
            {# val() en el select = valor real del POST (evita desfase visual vs option seleccionada). #}
            $sel.val(String(option_id));
            if (String($sel.val()) !== String(option_id)) {
                $sel.find("option").each(function () {
                    if (String(this.value) === String(option_id)) {
                        this.selected = true;
                    }
                });
            }
            $sel.trigger('change');
            var labelText = selector.attr('title') || selector.find('.btn-variant-content').data('name') || option_id;
            parent.find('.js-insta-variation-label').html(labelText);
        }

        {% if settings.bullet_variants or settings.image_color_variants %}
            {# /* // Color and size variations */ #}

            jQueryNuvem(document).on("click", ".js-insta-variant", function (e) {
                e.preventDefault();
                $this = jQueryNuvem(this);
                changeVariantButton($this, '.js-product-variants-group');
            });

        {% endif %}


        {% if settings.product_color_variants %}

            {# Product color variations (pastillas hex; en móvil no aplica salvo miniaturas de listado) #}
            if (window.innerWidth > 767) {
                jQueryNuvem(document).on("click", ".js-item-product .js-color-variant:not(.js-listing-variant-thumb)", function(e) {
                    e.preventDefault();
                    $this = jQueryNuvem(this);
                    changeVariantButton($this, '.js-item-product');
                });
            }
        {% endif %}

        {% if (settings.product_listing_variant_images | default(false)) %}
            {# Miniaturas con imagen de variante en grilla (todas las anchuras) #}
            jQueryNuvem(document).on("click", ".js-item-product .js-listing-variant-thumb", function(e) {
                e.preventDefault();
                $this = jQueryNuvem(this);
                changeVariantButton($this, '.js-item-product');
                $this.attr('aria-pressed', 'true').siblings('.js-listing-variant-thumb').attr('aria-pressed', 'false');
            });
        {% endif %}

    {% endif %}

    {% if settings.quick_shop or settings.product_color_variants or (settings.product_listing_variant_images | default(false)) %}

        LS.registerOnChangeVariant(function(variant){
            {# Show product image on color change #}
            const productContainer = jQueryNuvem('.js-item-product[data-product-id="'+variant.product_id+'"]');
            const current_image = productContainer.find('.js-item-image');
            current_image.attr('srcset', variant.image_url);

            {% if has_item_slider %}

                {# Remove slider when variant changes #}

                const swiperElement = productContainer.find('.js-product-item-slider-container-private.swiper-container-initialized');

                if(swiperElement.length){
                    productContainer.find('.js-product-item-slider-slide-private').removeClass('item-image-slide');
                    setTimeout(function(){
                        const productImageLink = productContainer.find('.js-product-item-image-link-private');
                        const imageToKeep = productContainer.find('.js-swiper-slide-visible img').clone();
                        
                        // Destroy the Swiper instance
                        if (itemProductSliders[variant.product_id]) {
                            itemProductSliders[variant.product_id].destroy(true, true);
                            delete itemProductSliders[variant.product_id];
                        }
                         // Remove the Swiper elements
                         swiperElement.remove();
                         productContainer.find('.js-product-item-slider-pagination-container').remove();

                        // Insert the cloned image into the link
                        productImageLink.append(imageToKeep);

                    },300);
                }
            {% endif %}

            {% if settings.product_hover %}
                {# Remove secondary feature on image updated from changeVariant #}
                productContainer.find(".js-product-item-private-with-secondary-images").addClass("product-item-secondary-images-disabled");
            {% endif %}
        });

    {% endif %}

    {#/*============================================================================
	  #Product detail functions
	==============================================================================*/ #}

	{# /* // Installments */ #}

	{# Installments without interest #}

	function get_max_installments_without_interests(number_of_installment, installment_data, max_installments_without_interests) {
	    if (parseInt(number_of_installment) > parseInt(max_installments_without_interests[0])) {
	        if (installment_data.without_interests) {
	            return [number_of_installment, installment_data.installment_value];
	        }
	    }
	    return max_installments_without_interests;
	}

	{# Installments with interest #}

	function get_max_installments_with_interests(number_of_installment, installment_data, max_installments_with_interests) {
	    if (parseInt(number_of_installment) > parseInt(max_installments_with_interests[0])) {
	        if (installment_data.without_interests == false) {
	            return [number_of_installment, installment_data.installment_value];
	        }
	    }
	    return max_installments_with_interests;
	}

	{# Updates installments on payment popup for native integrations #}

	function refreshInstallmentv2(price){
        jQueryNuvem(".js-modal-installment-price" ).each(function( el ) {
	        const installment = Number(jQueryNuvem(el).data('installment'));
	        jQueryNuvem(el).text(formatMoneyRoundedNumber(price / installment));
	    });
	}

	{# /* // Change variant */ #}

	{# Updates price, installments, labels and CTA on variant change #}

	function changeVariant(variant) {
        jQueryNuvem(".js-product-detail .js-shipping-calculator-response").hide();
        jQueryNuvem("#shipping-variant-id").val(variant.id);

	    var parent = jQueryNuvem("body");
	    if (variant.element) {
            parent = jQueryNuvem(variant.element);
            if(parent.hasClass("js-quickshop-container")){
                var quick_id = parent.attr("data-quickshop-id");
                var parent = jQueryNuvem('.js-quickshop-container[data-quickshop-id="'+quick_id+'"]');
            }
	    }

        {% if is_button_variant %}
            {# Updates variants without stock #}
            if(parent.hasClass("js-quickshop-container")){
                var itemContainer = parent.closest('.js-item-product');
                if(itemContainer.hasClass("js-item-slide")){
                    var parent = jQueryNuvem('.js-swiper-slide-visible .js-quickshop-container[data-quickshop-id="'+quick_id+'"]');
                }
                noStockVariants(parent);
            } else {
                noStockVariants();
            }
        {% endif %}
        
	    var sku = parent.find('.js-product-sku');
	    if(sku.length) {
	        sku.text(variant.sku).show();
	    }

	    {% if settings.product_stock %}
	        var stock = parent.find('.js-product-stock');
	        stock.text(variant.stock).show();
	    {% endif %}

        {# Updates installments on list item and inside payment popup for Payments Apps #}
        
	    var installment_helper = function($element, amount, price){
	        $element.find('.js-installment-amount').text(amount);
	        $element.find('.js-installment-price').attr("data-value", price);
	        $element.find('.js-installment-price').text(formatMoneyRoundedNumber(price));
	        if(variant.price_number != null && Math.abs(variant.price_number - price * amount) < 1) {
	            $element.find('.js-installment-total-price').text(formatMoneyRoundedNumber(variant.price_number));
	        } else {
	            $element.find('.js-installment-total-price').text(formatMoneyRoundedNumber(price * amount));
	        }
	    };

	    var $payments_module = jQueryNuvem(variant.element + ' .js-product-payments-container');

	    if (variant.installments_data) {
	        var variant_installments = JSON.parse(variant.installments_data);
	        var max_installments_without_interests = [0,0];
	        var max_installments_with_interests = [0,0];

	        {# Hide all installments rows on payments modal #}
	        jQueryNuvem('.js-payment-provider-installments-row').hide();

	        for (let payment_method in variant_installments) {

	            {# Identifies the minimum installment value #}
	            var paymentMethodId = '#installment_' + payment_method.replace(" ", "_") + '_1';
	            var minimumInstallmentValue = jQueryNuvem(paymentMethodId).closest('.js-info-payment-method').attr("data-minimum-installment-value");

                let installments = variant_installments[payment_method];
	            for (let number_of_installment in installments) {
                    let installment_data = installments[number_of_installment];
	                max_installments_without_interests = get_max_installments_without_interests(number_of_installment, installment_data, max_installments_without_interests);
	                max_installments_with_interests = get_max_installments_with_interests(number_of_installment, installment_data, max_installments_with_interests);
	                var installment_container_selector = '#installment_' + payment_method.replace(" ", "_") + '_' + number_of_installment;

	                {# Shows installments rows on payments modal according to the minimum value #}
	                if(minimumInstallmentValue <= installment_data.installment_value) {
	                    jQueryNuvem(installment_container_selector).show();
	                }

	                if(!parent.hasClass("js-quickshop-container")){
	                    installment_helper(jQueryNuvem(installment_container_selector), number_of_installment, installment_data.installment_value);
	                }
	            }
	        }
	        var $installments_container = jQueryNuvem(variant.element + ' .js-max-installments-container .js-max-installments');
	        var $installments_modal_link = jQueryNuvem(variant.element + ' #btn-installments');
	        var $installmens_card_icon = jQueryNuvem(variant.element + ' .js-installments-credit-card-icon');

	        {% if product.has_direct_payment_only %}
	        var installments_to_use = max_installments_without_interests[0] >= 1 ? max_installments_without_interests : max_installments_with_interests;

	        if(installments_to_use[0] <= 0 ) {
	        {%  else %}
	        var installments_to_use = max_installments_without_interests[0] > 1 ? max_installments_without_interests : max_installments_with_interests;

	        if(installments_to_use[0] <= 1 ) {
	        {% endif %}
	            $installments_container.hide();
	            $installments_modal_link.hide();
	            $payments_module.hide();
	            $installmens_card_icon.hide();
	        } else {
	            $installments_container.show();
	            $installments_modal_link.show();
	            $payments_module.show();
	            $installmens_card_icon.show();
	            installment_helper($installments_container, installments_to_use[0], installments_to_use[1]);
	        }
	    }

	    if (variant.contact) {
	        $payments_module.hide();
	    }

	    if(!parent.hasClass("js-quickshop-container")){
            var onePay = (variant.price_number != null && variant.price_number !== '' && !isNaN(Number(variant.price_number)))
                ? formatMoneyRoundedNumber(variant.price_number)
                : variant.price_short;
            jQueryNuvem('#installments-modal .js-installments-one-payment').text(onePay).attr("data-value", variant.price_number);
		}

	    if (variant.price_short){
	        var priceLabel = (variant.price_number != null && variant.price_number !== '' && !isNaN(Number(variant.price_number)))
	            ? formatMoneyRoundedNumber(variant.price_number)
	            : variant.price_short;
	        parent.find('.js-price-display').removeAttr('data-hs-effective-price').text(priceLabel).show();
	        parent.find('.js-price-display').attr("content", variant.price_number).data('productPrice', variant.price_number_raw);
            
            parent.find('.js-price-without-taxes').text(variant.price_without_taxes);
            parent.find('.js-price-without-taxes-container').show();
	    } else {
	        parent.find('.js-price-display, .js-price-without-taxes-container').hide();
	    }

	    if ((variant.compare_at_price_short) && !(parent.find(".js-price-display").css("display") == "none")) {
	        var compareRaw = variant.compare_at_price_number != null ? variant.compare_at_price_number : variant.compare_at_price;
	        if (compareRaw != null && !isNaN(Number(compareRaw))) {
	            parent.find('.js-compare-price-display').text(formatMoneyRoundedNumber(compareRaw)).show();
	        } else {
	            parent.find('.js-compare-price-display').text(variant.compare_at_price_short).show();
	        }
	    } else {
	        parent.find('.js-compare-price-display').hide();
	    }

        var $transferRow = parent.find('.js-theme-transfer-computed');
        if ($transferRow.length) {
            var tpct = Number($transferRow.data('transferPct'));
            if (isFinite(tpct) && tpct > 0 && tpct < 100) {
                var pnum = variant.price_number != null && !isNaN(Number(variant.price_number))
                    ? Number(variant.price_number)
                    : NaN;
                var $pd = parent.find('.js-price-display').first();
                if (!isFinite(pnum) && $pd.length) {
                    var c = Number($pd.attr('content'));
                    if (isFinite(c) && c > 0) {
                        pnum = c;
                    }
                }
                if (!isFinite(pnum) && $pd.length) {
                    var dp = $pd.attr('data-product-price');
                    var nFromAttr = dp != null && dp !== '' ? Number(dp) : NaN;
                    if (isFinite(nFromAttr) && nFromAttr > 0) {
                        pnum = nFromAttr;
                    }
                }
                if (!isFinite(pnum) && $pd.length) {
                    var digits = String($pd.text() || '').replace(/\D/g, '');
                    if (digits) {
                        pnum = parseInt(digits, 10);
                    }
                }
                if (isFinite(pnum) && pnum > 0) {
                    var tval = Math.round(pnum * (100 - tpct) / 100);
                    $transferRow.find('.js-theme-transfer-amount').first().text(formatMoneyRoundedNumber(tval));
                }
            }
        }

        var $transferRoot = jQueryNuvem(parent).closest('.js-product-container, .js-quickshop-container, .js-quickshop-modal-shell');
        themeRefreshTransferLines($transferRoot.length ? $transferRoot : parent);

        var button = parent.find('.js-addtocart');
        const quickshopButtonWording = parent.find('.js-open-quickshop-wording');
        const quickshopButtonIcon = parent.find('.js-open-quickshop-icon');
        button.removeClass('cart').removeClass('contact').removeClass('nostock');
        var $product_shipping_calculator = parent.find("#product-shipping-container");

        {# Update CTA wording and status #}

	    {% if not store.is_catalog %}
            if (!variant.available){
                button.val('{{ "Sin stock" | translate }}');
                button.addClass('nostock');
                button.attr('disabled', 'disabled');
                quickshopButtonWording.text('{{ "Sin stock" | translate }}');
                quickshopButtonIcon.addClass("d-none").removeClass("d-md-inline");
                $product_shipping_calculator.hide();
            } else if (variant.contact) {
                button.val('{{ "Consultar precio" | translate }}');
                button.addClass('contact');
                button.removeAttr('disabled');
                quickshopButtonWording.text('{{ "Consultar precio" | translate }}');
                quickshopButtonIcon.addClass("d-none").removeClass("d-md-inline");
                $product_shipping_calculator.hide();
            } else {
                button.val('{{ "Agregar al carrito" | translate }}');
                button.addClass('cart');
                button.removeAttr('disabled');
                var $listRoot = parent.closest(".js-item-product");
                var customCartLabel = ($listRoot.length && $listRoot.attr("data-list-buy-label-cart")) ? String($listRoot.attr("data-list-buy-label-cart")).trim() : "";
                quickshopButtonWording.text(customCartLabel ? customCartLabel : '{{ "Comprar" | translate }}');
                quickshopButtonIcon.addClass("d-md-inline");
                $product_shipping_calculator.show();
            }

	    {% endif %}

        {% if template == 'product' %}
            const base_price = Number(jQueryNuvem("#price_display").attr("content"));
            refreshInstallmentv2(base_price);
        {% endif %}

        {% if settings.last_product %}
            if(variant.stock == 1) {
                parent.find('.js-last-product').show();
            } else {
                parent.find('.js-last-product').hide();
            }
        {% endif %}


        {# Update shipping on variant change #}

        LS.updateShippingProduct();

        zipcode_on_changevariant = jQueryNuvem("#product-shipping-container .js-shipping-input").val();
        jQueryNuvem("#product-shipping-container .js-shipping-calculator-current-zip").text(zipcode_on_changevariant);

        {% if cart.free_shipping.min_price_free_shipping.min_price %}
            {# Updates free shipping bar #}

            LS.freeShippingProgress(true, parent);

        {% endif %}

        LS.subscriptionChangeVariant(variant);
	}

	{# /* // Trigger change variant */ #}

    jQueryNuvem(document).on("change", ".js-variation-option", function(e) {
        var $parent = jQueryNuvem(this).closest(".js-product-variants");
        var $variants_group = jQueryNuvem(this).closest(".js-product-variants-group");
        var $quickshop_parent_wrapper = jQueryNuvem(this).closest(".js-quickshop-container");

        {# If quickshop is used from modal, use quickshop-id from the item that opened it #}

        var quick_id = $quickshop_parent_wrapper.attr("data-quickshop-id");

        if($parent.hasClass("js-product-quickshop-variants")){

            var $quickshop_parent = jQueryNuvem(this).closest(".js-item-product");

            {# Target visible slider item if necessary #}
            
            if($quickshop_parent.hasClass("js-item-slide")){
                var $quickshop_variant_selector = '.js-swiper-slide-visible .js-quickshop-container[data-quickshop-id="'+quick_id+'"]';
            }else{
                var $quickshop_variant_selector = '.js-quickshop-container[data-quickshop-id="'+quick_id+'"]';
            }

            LS.changeVariant(changeVariant, $quickshop_variant_selector);

            {% if settings.product_color_variants or settings.bullet_variants or settings.image_color_variants or (settings.product_listing_variant_images | default(false)) %}
                {# Match selected color variant with selected quickshop variant #}

                var selected_option_id = jQueryNuvem(this).val();
                var $color_parent_to_update = jQueryNuvem('.js-quickshop-container[data-quickshop-id="'+quick_id+'"]');

                {# Update all color buttons on several places (quickshop, item, product detail) #}
                $color_parent_to_update.find('.js-color-variant[data-option="'+selected_option_id+'"]').addClass("selected").siblings().removeClass("selected");
                $color_parent_to_update.find('.js-listing-variant-thumb').attr('aria-pressed', function () {
                    return jQueryNuvem(this).attr('data-option') == selected_option_id ? 'true' : 'false';
                });
                {# Update this specific variant button #}
                $variants_group.find('.js-insta-variant[data-option="'+selected_option_id+'"]').addClass("selected").siblings().removeClass("selected");
            {% endif %}

        } else {
            LS.changeVariant(changeVariant, '#single-product');
        }

        {# Offer and discount labels update #}

        var $this_product_container = jQueryNuvem(this).closest(".js-product-container");

        if($this_product_container.hasClass("js-quickshop-container")){
            var this_quickshop_id = $this_product_container.attr("data-quickshop-id");
            var $this_product_container = jQueryNuvem('.js-product-container[data-quickshop-id="'+this_quickshop_id+'"]');
        }
        var $this_compare_price = $this_product_container.find(".js-compare-price-display");
        var $this_price = $this_product_container.find(".js-price-display");
        var $installment_container = $this_product_container.find(".js-product-payments-container");
        var $installment_text = $this_product_container.find(".js-max-installments-container");
        var $this_add_to_cart = $this_product_container.find(".js-prod-submit-form");

        // Get the current product discount percentage value
        var current_percentage_value = $this_product_container.find(".js-offer-percentage");

        // Get the current product price and promotional price
        var compare_price_value = $this_compare_price.html();
        var price_value = $this_price.html();

        // Calculate new discount percentage based on difference between filtered old and new prices
        const percentageDifference = window.moneyDifferenceCalculator.percentageDifferenceFromString(compare_price_value, price_value);
        if(percentageDifference){
            $this_product_container.find(".js-offer-percentage").text(percentageDifference);
            $this_product_container.find(".js-offer-label").css("display" , "table");
        }

        if ($this_compare_price.css("display") == "none" || !percentageDifference) {
            $this_product_container.find(".js-offer-label").hide();
        }
        if ($this_add_to_cart.hasClass("nostock")) {
            var $stockLabel = $this_product_container.find(".js-stock-label");
            if (!$stockLabel.text().trim()) {
                $stockLabel.text($stockLabel.data('label'));
            }
            $stockLabel.show();
            $this_product_container.find(".js-offer-label").hide();
            $this_product_container.find(".js-shipping-label").hide();
        }
        else {
            $this_product_container.find(".js-stock-label").hide();
            $this_product_container.find(".js-shipping-label").show();
	    }
	    if ($this_price.css('display') == 'none'){
	        $installment_container.hide();
	        $installment_text.hide();
	    }else{
	        $installment_text.show();
	    }
	});

	{# /* // Submit to contact */ #}

	{# Submit to contact form when product has no price #}

    {# Delegado: formularios inyectados (p. ej. carril New Edition) también entran. Con ajax_cart evitamos POST nativo al carrito (redirección). #}
    jQueryNuvem(document).on("submit", ".js-product-form", function (e) {
        var $form = jQueryNuvem(e.currentTarget);
        var sub = e.originalEvent && e.originalEvent.submitter;
        var button = sub ? jQueryNuvem(sub) : $form.find('input.js-addtocart[type="submit"], button.js-addtocart[type="submit"]').first();
        if (!button.length) {
            button = $form.find('input[type="submit"], button[type="submit"]').first();
        }
        if ((button.hasClass('contact')) || (button.hasClass('catalog'))) {
            button.attr('disabled', 'disabled');
            e.preventDefault();
            var product_id = $form.find("input[name='add_to_cart']").val();
            window.location = "{{ store.contact_url | escape('js') }}?product=" + product_id;
            return;
        }
        {% if settings.ajax_cart %}
        if (
            button.hasClass('js-addtocart') &&
            !button.hasClass('contact') &&
            !button.hasClass('catalog') &&
            !button.prop('disabled')
        ) {
            e.preventDefault();
            if ($form.data('jsNuvemAtcFromSubmit')) {
                return false;
            }
            $form.data('jsNuvemAtcFromSubmit', 1);
            window.setTimeout(function () {
                $form.removeData('jsNuvemAtcFromSubmit');
            }, 0);
            button.trigger('click');
            return false;
        }
        {% endif %}
        if (button.hasClass('cart')) {
            button.attr('disabled', 'disabled');
            button.val('{{ "Agregando..." | translate }}');
        }
    });

	{% if template == 'product' or (template == 'home' and sections.featured.products) %}

    {% set native_videos_enabled = false %}
    {% if template == 'product' and product.hasNativeVideos %}
        {% set native_videos_enabled = true %}
    {% endif %}
    {% if template == 'home' and sections.featured.products %}
        {% for product in sections.featured.products %}
            {% if product.hasNativeVideos %}
                {% set native_videos_enabled = true %}
            {% endif %}
        {% endfor %}
    {% endif %}

    {% if native_videos_enabled %}
        var stream_videos = [];
        function initAllVideos(){
            jQueryNuvem(".js-external-video-iframe").each(function($el){
                const player = Stream(document.getElementById($el.id));
                stream_videos.push(player);
            });
        }
        initAllVideos();
        function pauseAllVideos(){
            stream_videos.forEach(function(player){
                player.pause();
            });
        }
        jQueryNuvem(".js-play-native-button").on("click", function($el){
            pauseAllVideos();
            const link = jQueryNuvem(this);
            const id = jQueryNuvem(this).data("video_uid");
            const iframe = jQueryNuvem("#video-" + id);
            const image = jQueryNuvem("img[data-video_uid='" + id + "']");
            const parent = jQueryNuvem(this).parent(".embed-responsive-16by9");
            const container = jQueryNuvem("div[data-video_uid='" + id + "']");
            iframe.attr("src", iframe.data("src"));
            container.show();
            image.hide();
            link.hide().removeClass("d-md-block");
            parent.removeClass("embed-responsive-16by9");
            let allowAttr = iframe.attr("allow");

            if (allowAttr) {
                allowAttr = allowAttr
                    .split(";")
                    .map(item => item.trim())
                    .filter(item => item && item !== "autoplay")
                    .join("; ");

                iframe.attr("allow", allowAttr + ";");
            }
        });
    {% endif %}

        var has_multiple_slides = false;

        {% if template == 'product' and (product.media_count > 1 or product.video_url) %}
            var has_multiple_slides = true;
        {% else %}
            var product_images_amount = jQueryNuvem(".js-swiper-product").attr("data-product-images-amount");
            if(product_images_amount > 1) {
                var has_multiple_slides = true;
            }
        {% endif %}

	    {# /* // Product slider */ #}

        {% if template == 'product' %}

            {% block product_fancybox %}
                Fancybox.bind('[data-fancybox="product-gallery"]', {
                    Toolbar: {
                        items: {
                            close: {
                                html: '<svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#times"/></svg>',
                            },
                            counter: {
                                class: 'pt-2 mt-1',
                                type: 'div',
                                html: '<span data-fancybox-index=""></span>&nbsp;/&nbsp;<span data-fancybox-count=""></span>',
                                position: 'center',
                            },
                        },
                    },
                    Carousel: {
                        Navigation: {
                            classNames: {
                                button: 'btn',
                                next: 'swiper-button-next',
                                prev: 'swiper-button-prev',
                            },
                            prevTpl: '<svg class="icon-inline icon-lg svg-icon-invert icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>',
                            nextTpl: '<svg class="icon-inline icon-lg svg-icon-invert"><use xlink:href="#arrow-long"/></svg>',
                        },
                    },
                    Thumbs: { autoStart: false },
                    on: {
                        shouldClose: (fancybox, slide) => {
                            {% if settings.product_image_format != 'slider' and template != 'product' %}
                                if (window.innerWidth < 768) {
                            {% endif %}
                                {# Update position of the slider #}
                                productSwiper.slideTo( fancybox.getSlide().index, 0 );
                            {% if settings.product_image_format != 'slider' and template != 'product' %}
                                }
                            {% endif %}
                        },
                        {% if native_videos_enabled %}
                            "Carousel.change": (fancybox) => {
                                pauseAllVideos();
                            },
                        {% endif %}
                    },
                });
            {% endblock %}
        {% endif %}

        function productSliderNav(){

            var width = window.innerWidth;

            var productSwiper = null;
            createSwiper(
                '.js-swiper-product', {
                    lazy: true,
                    slidesPerView: 1,
                    threshold: 5,
                    centerInsufficientSlides: {% if template == 'product' %}false{% else %}true{% endif %},
                    watchOverflow: true,
                    {% if template == 'product' %}roundLengths: true,
                    {% endif %}spaceBetween: {% if template == 'product' %}0{% else %}25{% endif %},
                    {% if template == 'product' %}
                    pagination: false,
                    {% else %}
                    pagination: {
                        el: '.js-swiper-product-pagination',
                        type: 'fraction',
                    },
                    {% endif %}
                    navigation: {
                        nextEl: '.js-swiper-product-next',
                        prevEl: '.js-swiper-product-prev',
                    },
                    breakpoints: {
                        768: {
                            slidesPerView: {% if template == 'product' %}1{% else %}'auto'{% endif %},
                            spaceBetween: {% if template == 'product' %}0{% else %}25{% endif %},
                        }
                    },
                    on: {
                        init: function () {
                            jQueryNuvem(".js-product-slider-placeholder").hide();
                            jQueryNuvem(".js-swiper-product").css("visibility", "visible").css("height", "auto");
                            {% if template == 'product' %}
                                this.update();
                            {% endif %}
                            {% if product.video_url and template == 'product' %}
                                if (window.innerWidth < 768) {
                                    productSwiperHeight = jQueryNuvem(".js-swiper-product").height();
                                    jQueryNuvem(".js-product-video-slide").height(productSwiperHeight);
                                }
                            {% endif %}
                        },
                        slideChange: function () {
                            {% if native_videos_enabled %}
                                pauseAllVideos();
                            {% endif %}
                            {% if template == 'product' %}
                                this.update();
                            {% endif %}
                        },
                        {% if template == 'product' %}
                            slideChangeTransitionEnd: function () {
                                this.update();
                                {% if product.video_url %}
                                const $parent = jQueryNuvem(this.el).closest(".js-product-detail");
                                const $labelsFloatingGroup = $parent.find(".js-labels-floating-group");
                                if(jQueryNuvem(".js-product-video-slide").hasClass("swiper-slide-active")){
                                    $labelsFloatingGroup.fadeOut(100);
                                }else{
                                    $labelsFloatingGroup.fadeIn(100);
                                }
                                jQueryNuvem('.js-video').show();
                                jQueryNuvem('.js-video-iframe').hide().find("iframe").remove();
                                {% endif %}
                            },
                        {% endif %}
                    },
                },
                function(swiperInstance) {
                    productSwiper = swiperInstance;
                }
            );

            {% if template == 'product' %}
                {{ block ('product_fancybox') }}
            {% endif %}

            if(has_multiple_slides){
                LS.registerOnChangeVariant(function(variant){
                    var liImage = jQueryNuvem('.js-swiper-product').find("[data-image='"+variant.image+"']");
                    var selectedPosition = liImage.data('imagePosition');
                    var slideToGo = parseInt(selectedPosition);
                    productSwiper.slideTo(slideToGo);
                    jQueryNuvem(".js-product-slide-img").removeClass("js-active-variant");
                    liImage.find(".js-product-slide-img").addClass("js-active-variant");
                });

            }
        }

        productSliderNav()

        {# /* // Pinterest sharing */ #}

        jQueryNuvem('.js-pinterest-share').on("click", function(e){
            e.preventDefault();
            jQueryNuvem(".pinterest-hidden a").get()[0].click();
        });

	{% endif %}

    {# Product quantity #}

    jQueryNuvem(document).on("click", ".js-quantity .js-quantity-up", function (e) {
        $quantity_input = jQueryNuvem(this).closest(".js-quantity").find(".js-quantity-input");
        $quantity_input.val( parseInt($quantity_input.val(), 10) + 1);
    });

    jQueryNuvem(document).on("click", ".js-quantity .js-quantity-down", function (e) {
        $quantity_input = jQueryNuvem(this).closest(".js-quantity").find(".js-quantity-input");
        quantity_input_val = $quantity_input.val();
        if (quantity_input_val>1) {
            $quantity_input.val( parseInt($quantity_input.val(), 10) - 1);
        }
    });


	{#/*============================================================================
	  #Cart
	==============================================================================*/ #}

    {% if cart.free_shipping.min_price_free_shipping.min_price %}

        {# Updates free progress on page load #}

        LS.freeShippingProgress(true);

    {% endif %}

    {# /* // Position of cart page summary */ #}

    var head_height = jQueryNuvem(".js-head-main").outerHeight();

    if (window.innerWidth > 768) {
        {% if settings.head_fix_desktop %}
            jQueryNuvem("#cart-sticky-summary").css("top" , (head_height + 10).toString() + 'px');
        {% else %}
            jQueryNuvem("#cart-sticky-summary").css("top" , "10px");
        {% endif %}
    }


    {# /* // Add to cart */ #}

    function getQuickShopImgSrc(element){
        const image = jQueryNuvem(element).closest('.js-quickshop-container').find('img');
        return String(image.attr('srcset'));
    }

    jQueryNuvem(document).on("click", ".js-addtocart:not(.js-addtocart-placeholder)", function (e) {

        {# Button variables for transitions on add to cart #}

        var $productContainer = jQueryNuvem(this).closest('.js-product-container');
        var $productVariants = $productContainer.find(".js-variation-option");
        var $productButton = $productContainer.find("input[type='submit'].js-addtocart");
        var productButtonWidth = $productButton.first(el => el.offsetWidth);

        {# Define if event comes from quickshop, product page or cross selling #}

        var isQuickShop = $productContainer.hasClass('js-quickshop-container');
        if (isQuickShop) {
            var $productButtonContainer = $productButton.closest(".js-item-submit-container");
        }
        var isCrossSelling = $productContainer.hasClass('js-cross-selling-container');
        var $productButtonPlaceholder = $productContainer.find(".js-addtocart-placeholder");
        var $productButtonText = $productButtonPlaceholder.find(".js-addtocart-text");
        var $productButtonAdding = $productButtonPlaceholder.find(".js-addtocart-adding");
        var $productButtonSuccess = $productButtonPlaceholder.find(".js-addtocart-success");

        {# Added item information for notification #}

        if (isCrossSelling) {
            var imageSrc = $productContainer.find('.js-cross-selling-product-image').attr('src');
            var quantity = $productContainer.data('quantity')
            var name = $productContainer.find('.js-cross-selling-product-name').text();
            var price = $productContainer.find('.js-cross-selling-promo-price').text();
            var addedToCartCopy = $productContainer.data('add-to-cart-translation');
        } else if (!isQuickShop) {
            if(jQueryNuvem(".js-product-slide-img.js-active-variant").length) {
                var $activeVariantImg = $productContainer.find('.js-product-slide-img.js-active-variant');
                var imageSrc = $activeVariantImg.attr('srcset') || $activeVariantImg.data('srcset');
            } else {
                var $defaultImg = $productContainer.find('.js-product-slide-img');
                var imageSrc = $defaultImg.attr('srcset') || $defaultImg.data('srcset');
            }
            
            imageSrc = imageSrc ? imageSrc.split(' ')[0] : '';
            var quantity = $productContainer.find('.js-quantity-input').val();
            var name = $productContainer.find('.js-product-name').text();
            var price = $productContainer.find('.js-price-display').text();
            var addedToCartCopy = "{{ 'Agregar al carrito' | translate }}";
        } else {
            var imageSrc = getQuickShopImgSrc(this);
            var quantity = 1;
            var name = $productContainer.find('.js-item-name').text();
            var price = $productContainer.find('.js-price-display').text().trim();
            var addedToCartCopy = "{{ 'Comprar' | translate }}";
            if ($productContainer.hasClass("js-quickshop-has-variants")) {
                var addedToCartCopy = "{{ 'Agregar al carrito' | translate }}";
            }else{
                var addedToCartCopy = "{{ 'Comprar' | translate }}";
            }
        }

        if (!jQueryNuvem(this).hasClass('contact')) {

            {# Hide real button and show button placeholder during event #}

            $productButton.hide();
            if (isQuickShop) {
                $productButtonContainer.hide();
            }

            $productButtonPlaceholder.width(productButtonWidth).css('display' , 'block');
            $productButtonText.fadeOut();
            $productButtonAdding.addClass("active");

            {# Restore button state in case of error #}

            function restore_button_initial_state(){
                $productButtonAdding.removeClass("active");
                $productButtonText.fadeIn();
                $productButtonPlaceholder.removeAttr("style").hide();
                $productButton.show();
                if (isQuickShop) {
                    $productButtonContainer.show();
                }
            }

            {# Restore button state for subscriptions stock error #}

            var subscription_callback_error = function() {
                setTimeout(function() {
                    restore_button_initial_state();
                }, 500);
            }

            {# Handle subscribable product submit #}

            const subscriptionValidResult = LS.subscriptionSubmit($productContainer, subscription_callback_error, e);
            if (subscriptionValidResult && subscriptionValidResult.changeCartSubmit) {
                return;
            }

            {% if settings.ajax_cart %}

                e.preventDefault();

                var callback_add_to_cart = function(html_notification_related_products, html_notification_cross_selling) {

                    {# Fill notification info #}

                    jQueryNuvem('.js-cart-notification-item-img').attr('srcset', imageSrc);
                    jQueryNuvem('.js-cart-notification-item-name').text(name);
                    jQueryNuvem('.js-cart-notification-item-quantity').text(quantity);
                    jQueryNuvem('.js-cart-notification-item-price').text(price);

                    if($productVariants.length){
                        var output = [];

                        $productVariants.each( function(el){
                            var variants = jQueryNuvem(el);
                            output.push(variants.val());
                        });
                        jQueryNuvem(".js-cart-notification-item-variant-container").show();
                        jQueryNuvem(".js-cart-notification-item-variant").text(output.join(', '))
                    }else{
                        jQueryNuvem(".js-cart-notification-item-variant-container").hide();
                    }

                    {# Set products amount wording visibility #}

                    var cartItemsBadge = jQueryNuvem(".js-cart-widget-amount");
                    var cartItemsMoney = jQueryNuvem(".js-cart-widget-total");
                    var cartItemsAmount = cartItemsBadge.text();

                    cartItemsBadge.removeClass("d-none d-md-inline-block");
                    
                    if (window.innerWidth > 768) {
                        cartItemsMoney.removeClass("d-none d-md-inline-block");
                    }

                    if(cartItemsAmount > 1){
                        jQueryNuvem(".js-cart-counts-plural").show();
                        jQueryNuvem(".js-cart-counts-singular").hide();
                    }else{
                        jQueryNuvem(".js-cart-counts-singular").show();
                        jQueryNuvem(".js-cart-counts-plural").hide();
                    }

                    {# Show button placeholder with transitions #}

                    $productButtonAdding.removeClass("active");
                    $productButtonSuccess.addClass("active");
                    setTimeout(function(){
                        $productButtonSuccess.removeClass("active");
                        $productButtonText.fadeIn();
                    },2000);
                    setTimeout(function(){
                        $productButtonPlaceholder.removeAttr("style").hide();
                        $productButton.show();
                        if (isQuickShop) {
                            $productButtonContainer.show();
                        }
                    },3000);

                    $productContainer.find(".js-added-to-cart-product-message").slideDown();

                    if (isQuickShop) {
                        jQueryNuvem("#quickshop-modal").removeClass('modal-show');
                        jQueryNuvem(".js-modal-overlay[data-modal-id='#quickshop-modal']").hide();
                        jQueryNuvem("body").removeClass("overflow-none");
                        restoreQuickshopForm();
                        if (window.innerWidth < 768) {
                            cleanURLHash();
                        }
                    }

                    let notificationWithRelatedProducts = false;

                    {% if settings.add_to_cart_recommendations %}

                        {# Show added to cart product related products #}

                        function recommendProductsOnAddToCart(){

                            jQueryNuvem('.js-related-products-notification-container').html("");

                            modalOpen('#related-products-notification');

                            jQueryNuvem('.js-related-products-notification-container').html(html_notification_related_products).show();

                            {# Recommendations swiper #}

                            // Set loop for recommended products

                            function calculateRelatedNotificationLoopVal(sectionSelector) {
                                let productsAmount = jQueryNuvem(sectionSelector).attr("data-related-amount");
                                let loopVal = false;
                                const applyLoop = (window.innerWidth < 768 && productsAmount > 2) || (window.innerWidth > 768 && productsAmount > 4);
                                
                                if (applyLoop) {
                                    loopVal = true;
                                }
                                
                                return loopVal;
                            }

                            let cartRelatedLoopVal = calculateRelatedNotificationLoopVal(".js-related-products-notification");

                            // Create new swiper on add to cart

                            createSwiper('.js-swiper-related-products-notification', {
                                lazy: true,
                                loop: cartRelatedLoopVal,
                                watchOverflow: true,
                                threshold: 5,
                                watchSlideProgress: true,
                                watchSlidesVisibility: true,
                                spaceBetween: itemSwiperSpaceBetween,
                                slideVisibleClass: 'js-swiper-slide-visible',
                                slidesPerView: 2.5,
                                navigation: {
                                    nextEl: '.js-swiper-related-products-notification-next',
                                    prevEl: '.js-swiper-related-products-notification-prev',
                                },
                                on: {
                                    afterInit: function () {
                                        hideSwiperControls(".js-swiper-related-products-notification-prev", ".js-swiper-related-products-notification-next");
                                    },
                                },
                                breakpoints: {
                                    768: {
                                        slidesPerView: 4,
                                    }
                                }
                            });
                            {% if has_item_slider %}
                                setTimeout(function () {
                                    if (typeof LS !== 'undefined' && typeof LS.productItemSlider === 'function') {
                                        try {
                                            LS.productItemSlider({ pagination_type: 'bullets' });
                                        } catch (eNotif) {
                                            /* ignore */
                                        }
                                    }
                                }, 120);
                            {% endif %}
                        }
                        
                        notificationWithRelatedProducts = html_notification_related_products != null;

                        if(notificationWithRelatedProducts){
                            if (isQuickShop) {
                                setTimeout(function(){
                                    recommendProductsOnAddToCart();
                                },300);
                            }else{
                                recommendProductsOnAddToCart();
                            }
                        }

                    {% endif %}

                    let shouldShowCrossSellingModal = html_notification_cross_selling != null;

                    if(!notificationWithRelatedProducts){

                        const cartOpenType = jQueryNuvem("#modal-cart").attr('data-cart-open-type');

                        if((cartOpenType === 'show_cart') && !shouldShowCrossSellingModal){

                            {# Open cart on add to cart #}

                            modalOpen('#modal-cart', 'openFullScreenWithoutClick');

                        }else{

                            {# Show added to cart notification #}
                            
                            setTimeout(function(){
                                jQueryNuvem(".js-alert-added-to-cart").show().addClass("notification-visible").removeClass("notification-hidden");
                            },500);

                            if (!cookieService.get('first_product_added_successfully')) {
                                cookieService.set('first_product_added_successfully', 1, 7 );
                            } else{
                                setTimeout(function(){
                                    jQueryNuvem(".js-alert-added-to-cart").removeClass("notification-visible").addClass("notification-hidden");
                                    setTimeout(function(){
                                        jQueryNuvem('.js-cart-notification-item-img').attr('src', '');
                                        jQueryNuvem(".js-alert-added-to-cart").hide();
                                    },2000);
                                },8000);
                            }
                        } 
                    }

                    {# Display cross-selling promotion modal #}

                    if (html_notification_cross_selling != null) {
                        jQueryNuvem('.js-cross-selling-modal-body').html("");
                        modalOpen('#js-cross-selling-modal');
                        jQueryNuvem('.js-cross-selling-modal-body').html(html_notification_cross_selling).show();
                    }

                    {# Change prices on cross-selling promotion modal #}

                    const crossSellingContainer = document.querySelector('.js-cross-selling-container');

                    if (crossSellingContainer) {
                        LS.fillCrossSelling(crossSellingContainer);
                    }

                    {# Update shipping input zipcode on add to cart #}

                    {# Use zipcode from input if user is in product page, or use zipcode cookie if is not #}

                    if (jQueryNuvem("#product-shipping-container .js-shipping-input").val()) {
                        zipcode_on_addtocart = jQueryNuvem("#product-shipping-container .js-shipping-input").val();
                        jQueryNuvem("#cart-shipping-container .js-shipping-input").val(zipcode_on_addtocart);
                        jQueryNuvem(".js-shipping-calculator-current-zip").text(zipcode_on_addtocart);
                    } else if (cookieService.get('calculator_zipcode')){
                        var zipcode_from_cookie = cookieService.get('calculator_zipcode');
                        jQueryNuvem('.js-shipping-input').val(zipcode_from_cookie);
                        jQueryNuvem(".js-shipping-calculator-current-zip").text(zipcode_from_cookie);
                    }


                    {# Update free shipping wording #}

                    jQueryNuvem(".js-fs-add-this-product").hide();
                    jQueryNuvem(".js-fs-add-one-more").show();

                    {# Automatically close the cross-selling modal by triggering its close button #}

                    if (isCrossSelling) {
                        jQueryNuvem('#js-cross-selling-modal .js-modal-close').trigger('click');
                    }
                }
                var callback_error = function(){
                    restore_button_initial_state();
                }
                $prod_form = jQueryNuvem(this).closest("form");
                LS.addToCartEnhanced(
                    $prod_form,
                    addedToCartCopy,
                    '{{ "Agregando..." | translate }}',
                    '{{ "No hay más stock de este producto." | translate }}',
                    {{ store.editable_ajax_cart_enabled ? 'true' : 'false' }},
                        callback_add_to_cart,
                        callback_error
                );
            {% endif %}
        }
    });


    {# /* // Cart quantitiy changes */ #}

    jQueryNuvem(document).on("keypress", ".js-cart-quantity-input", function (e) {
        if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
            return false;
        }
    });

    jQueryNuvem(document).on("focusout", ".js-cart-quantity-input", function (e) {
        var itemID = jQueryNuvem(this).attr("data-item-id");
        var itemVAL = jQueryNuvem(this).val();
        if (itemVAL == 0) {
            var r = confirm("{{ '¿Seguro que quieres borrar este artículo?' | translate }}");
            if (r == true) {
                LS.removeItem(itemID, true);
            } else {
                jQueryNuvem(this).val(1);
            }
        } else {
            LS.changeQuantity(itemID, itemVAL, true);
        }
    });

    {# /* // Empty cart alert */ #}

    jQueryNuvem(".js-trigger-empty-cart-alert").on("click", function (e) {
        e.preventDefault();
        let emptyCartAlert = jQueryNuvem(".js-mobile-nav-empty-cart-alert").fadeIn(100);
        setTimeout(() => emptyCartAlert.fadeOut(500), 1500);
    });

    {# /* // Update amount wording */ #}

    document.addEventListener( 'cart.released', () => {
        const cart_amount = jQueryNuvem(".js-cart-widget-amount").text();
        if(cart_amount == 1) {
            jQueryNuvem(".js-amount-one-item").show();
            jQueryNuvem(".js-amount-many-items").hide();
        }else{
            jQueryNuvem(".js-amount-one-item").hide();
            jQueryNuvem(".js-amount-many-items").show();
        }
    });

    {# /* // Go to checkout */ #}

    {# Clear cart notification cookie after consumers continues to checkout #}

    jQueryNuvem('form[action="{{ store.cart_url | escape('js') }}"]').on("submit", function() {
        cookieService.remove('first_product_added_successfully');
    });


	{#/*============================================================================
	  #Shipping calculator
	==============================================================================*/ #}

    {# /* // Update calculated cost wording */ #}

    {% if settings.shipping_calculator_cart_page %}
        if (jQueryNuvem('.js-selected-shipping-method').length) {
            var shipping_cost = jQueryNuvem('.js-selected-shipping-method').data("cost");
            var $shippingCost = jQueryNuvem("#shipping-cost");
            $shippingCost.text(shipping_cost);
            $shippingCost.removeClass('opacity-40');
        }
    {% endif %}

	{# /* // Select and save shipping function */ #}

    selectShippingOption = function(elem, save_option) {
        jQueryNuvem(".js-shipping-method, .js-branch-method").removeClass('js-selected-shipping-method');
        jQueryNuvem(elem).addClass('js-selected-shipping-method');

        {% if settings.shipping_calculator_cart_page %}

            var shipping_cost = jQueryNuvem(elem).data("cost");
            var shipping_price_clean = jQueryNuvem(elem).data("price");

            if(shipping_price_clean = 0.00){
                var shipping_cost = '{{ Gratis | translate }}'
            }

            // Updates shipping (ship and pickup) cost on cart
            var $shippingCost = jQueryNuvem("#shipping-cost");
            $shippingCost.text(shipping_cost);
            $shippingCost.removeClass('opacity-40');

        {% endif %}

        if (save_option) {
            LS.saveCalculatedShipping(true);
        }
        if (jQueryNuvem(elem).hasClass("js-shipping-method-hidden")) {
            {# Toggle other options visibility depending if they are pickup or delivery for cart and product at the same time #}
            if (jQueryNuvem(elem).hasClass("js-pickup-option")) {
                jQueryNuvem(".js-other-pickup-options, .js-show-other-pickup-options .js-shipping-see-less").show();
                jQueryNuvem(".js-show-other-pickup-options .js-shipping-see-more").hide();
            } else {
                jQueryNuvem(".js-other-shipping-options, .js-show-more-shipping-options .js-shipping-see-less").show();
                jQueryNuvem(".js-show-more-shipping-options .js-shipping-see-more").hide()
            }
        }
    };

    {# Apply zipcode saved by cookie if there is no zipcode saved on cart from backend #}

    if (cookieService.get('calculator_zipcode')) {

        {# If there is a cookie saved based on previous calcualtion, add it to the shipping input to triggert automatic calculation #}

        var zipcode_from_cookie = cookieService.get('calculator_zipcode');

        {% if settings.ajax_cart %}

            {# If ajax cart is active, target only product input to avoid extra calulation on empty cart #}

            jQueryNuvem('#product-shipping-container .js-shipping-input').val(zipcode_from_cookie);

        {% else %}

            {# If ajax cart is inactive, target the only input present on screen #}

            jQueryNuvem('.js-shipping-input').val(zipcode_from_cookie);

        {% endif %}

        jQueryNuvem(".js-shipping-calculator-current-zip").text(zipcode_from_cookie);

        {# Hide the shipping calculator and show spinner  #}

        jQueryNuvem(".js-shipping-calculator-head").addClass("with-zip").removeClass("with-form");
        jQueryNuvem(".js-shipping-calculator-with-zipcode").addClass("transition-up-active");
        jQueryNuvem(".js-shipping-calculator-spinner").show();
    } else {

        {# If there is no cookie saved, show calcualtor #}

        jQueryNuvem(".js-shipping-calculator-form").addClass("transition-up-active");
    }

    {# Remove shipping suboptions from DOM to avoid duplicated modals #}

    removeShippingSuboptions = function(){
        var shipping_suboptions_id = jQueryNuvem(".js-modal-shipping-suboptions").attr("id");
        jQueryNuvem("#" + shipping_suboptions_id).remove();
        jQueryNuvem('.js-modal-overlay[data-modal-id="#' + shipping_suboptions_id + '"').remove();
    };

    {# /* // Calculate shipping function */ #}


    jQueryNuvem(".js-calculate-shipping").on("click", function (e) {
	    e.preventDefault();

        {# Take the Zip code to all shipping calculators on screen #}
        let shipping_input_val = jQueryNuvem(e.currentTarget).closest(".js-shipping-calculator-form").find(".js-shipping-input").val();

        jQueryNuvem(".js-shipping-input").val(shipping_input_val);

        {# Calculate on page load for both calculators: Product and Cart #}

        if (jQueryNuvem(".js-cart-item").length) {
            LS.calculateShippingAjax(
            jQueryNuvem('#cart-shipping-container').find(".js-shipping-input").val(),
            '{{store.shipping_calculator_url | escape('js')}}',
            jQueryNuvem("#cart-shipping-container").closest(".js-shipping-calculator-container") );
        }

        jQueryNuvem(".js-shipping-calculator-current-zip").html(shipping_input_val);
        removeShippingSuboptions();
	});

	{# /* // Calculate shipping by submit */ #}

    jQueryNuvem(".js-shipping-input").on('keydown', function (e) {
	    var key = e.which ? e.which : e.keyCode;
	    var enterKey = 13;
	    if (key === enterKey) {
	        e.preventDefault();
            jQueryNuvem(e.currentTarget).closest(".js-shipping-calculator-form").find(".js-calculate-shipping").trigger('click');
	        if (window.innerWidth < 768) {
                jQueryNuvem(e.currentTarget).trigger('blur');
	        }
	    }
	});

    {# /* // Shipping and branch click */ #}

    jQueryNuvem(document).on("change", ".js-shipping-method, .js-branch-method", function (e) {
        selectShippingOption(this, true);
        jQueryNuvem(".js-shipping-method-unavailable").hide();
    });

    {# /* // Select shipping first option on results */ #}

    jQueryNuvem(document).on('shipping.options.checked', '.js-shipping-method', function (e) {
        let shippingPrice = jQueryNuvem(this).attr("data-price");
        LS.addToTotal(shippingPrice);

        let total = (LS.data.cart.total / 100) + parseFloat(shippingPrice);
        jQueryNuvem(".js-cart-widget-total").html(formatMoneyRoundedNumber(total));

        selectShippingOption(this, false);
    });

    {# /* // Toggle more shipping options */ #}

    jQueryNuvem(document).on("click", ".js-toggle-more-shipping-options", function(e) {
	    e.preventDefault();

        {# Toggle other options depending if they are pickup or delivery for cart and product at the same time #}

        if(jQueryNuvem(this).hasClass("js-show-other-pickup-options")){
            jQueryNuvem(".js-other-pickup-options").slideToggle(600);
            jQueryNuvem(".js-show-other-pickup-options .js-shipping-see-less, .js-show-other-pickup-options .js-shipping-see-more").toggle();
        }else{
            jQueryNuvem(".js-other-shipping-options").slideToggle(600);
            jQueryNuvem(".js-show-more-shipping-options .js-shipping-see-less, .js-show-more-shipping-options .js-shipping-see-more").toggle();
        }
	});

    {# /* // Calculate shipping on page load */ #}

    {# Only shipping input has value, cart has saved shipping and there is no branch selected #}

    calculateCartShippingOnLoad = function() {
        {# Triggers function when a zipcode input is filled #}
        if (jQueryNuvem("#cart-shipping-container .js-shipping-input").val()) {
            // If user already had calculated shipping: recalculate shipping
            setTimeout(function() {
                LS.calculateShippingAjax(
                    jQueryNuvem('#cart-shipping-container').find(".js-shipping-input").val(),
                    '{{store.shipping_calculator_url | escape('js')}}',
                    jQueryNuvem("#cart-shipping-container").closest(".js-shipping-calculator-container") );
                removeShippingSuboptions();
                window.toggleAccordionPrivate("#cart-shipping-container .js-toggle-shipping");
            }, 100);
        }

        if (jQueryNuvem(".js-branch-method").hasClass('js-selected-shipping-method')) {
            {% if store.branches|length > 1 %}
                window.toggleAccordionPrivate("#cart-shipping-container .js-toggle-branches");
            {% endif %}
        }
    };

    {% if cart.has_shippable_products %}
        calculateCartShippingOnLoad();
    {% endif %}

    {# /* // Change CP */ #}

    jQueryNuvem(document).on("click", ".js-shipping-calculator-change-zipcode", function(e) {
        e.preventDefault();
        jQueryNuvem(".js-shipping-calculator-response").fadeOut(100);
        jQueryNuvem(".js-shipping-calculator-head").addClass("with-form").removeClass("with-zip");
        jQueryNuvem(".js-shipping-calculator-with-zipcode").removeClass("transition-up-active");
        jQueryNuvem(".js-shipping-calculator-form").addClass("transition-up-active");
    });

	{# /* // Shipping provinces */ #}

	{% if provinces_json %}
        jQueryNuvem('select[name="country"]').on("change", function (e) {
		    var provinces = {{ provinces_json | default('{}') | raw }};
		    LS.swapProvinces(provinces[jQueryNuvem(e.currentTarget).val()]);
		}).trigger('change');
	{% endif %}


    {# /* // Change store country: From invalid zipcode message */ #}

    jQueryNuvem(document).on("click", ".js-save-shipping-country", function(e) {

        e.preventDefault();

        {# Change shipping country #}

        lang_select_option = jQueryNuvem(this).closest(".js-modal-shipping-country");
        changeLang(lang_select_option);

        jQueryNuvem(this).text('{{ "Aplicando..." | translate }}').addClass("disabled");
    });

    {#/*============================================================================
      #Forms
    ==============================================================================*/ #}

    {# IOS form CSS to avoid autozoom on focus #}

    var isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
    if (isIOS) {
        var ios_input_fields = jQueryNuvem("input[type='text'], input[type='number'], input[type='password'], input[type='tel'], textarea, input[type='search'], input[type='hidden'], input[type='email']");
        ios_input_fields.addClass("form-control-ios");
        jQueryNuvem(".js-quantity").addClass("form-group-quantity-ios");
        jQueryNuvem(".js-cart-quantity-container").addClass("cart-quantity-container-ios");
        jQueryNuvem(".js-search-form").toggleClass("search-form-ios");
        jQueryNuvem(".js-price-filter-btn").addClass("price-btn-ios");
        jQueryNuvem(".js-price-filter-empty").addClass("input-clear-content-ios");
    }

    {#/*============================================================================
      #Brand split video hero (archivos .mp4 / .webm directos)
    ==============================================================================*/ #}

    {% if settings.brand_split_video_enable %}
        (function () {
            var nodes = document.querySelectorAll('.js-brand-split-video-file');
            if (!nodes || !nodes.length) {
                return;
            }
            var tryPlay = function (video) {
                if (!video || typeof video.play !== 'function') {
                    return;
                }
                var p = video.play();
                if (p && typeof p.catch === 'function') {
                    p.catch(function () {});
                }
            };
            for (var i = 0; i < nodes.length; i++) {
                (function (video) {
                    video.addEventListener('loadeddata', function () {
                        tryPlay(video);
                    }, { once: true });
                    tryPlay(video);
                })(nodes[i]);
            }
        })();
    {% endif %}

    {% if settings.brand_category_triptych_enable %}
        if (window.innerWidth < 768 && document.querySelector('.js-swiper-brand-category-triptych')) {
            createSwiper('.js-swiper-brand-category-triptych', {
                slidesPerView: 1.08,
                centeredSlides: true,
                spaceBetween: 10,
                speed: 550,
                watchOverflow: true,
                pagination: {
                    el: '.js-swiper-brand-category-triptych-pagination',
                    clickable: true,
                },
            });
        }
    {% endif %}

    {% if template == 'home' and settings.brand_category_carousel_enable | default(false) %}
        (function () {
            var root = document.querySelector('.js-swiper-brand-category-carousel');
            if (!root || !root.querySelector('.swiper-slide')) {
                return;
            }
            createSwiper('.js-swiper-brand-category-carousel', {
                slidesPerView: 1,
                spaceBetween: 0,
                speed: 520,
                watchOverflow: true,
                grabCursor: true,
                roundLengths: true,
                navigation: {
                    nextEl: '.js-swiper-brand-category-carousel-next',
                    prevEl: '.js-swiper-brand-category-carousel-prev',
                },
                pagination: {
                    el: '.js-swiper-brand-category-carousel-pagination',
                    clickable: true,
                },
                breakpoints: {
                    768: {
                        slidesPerView: 3,
                        spaceBetween: 0,
                    },
                },
            });
        })();
    {% endif %}

    {% if (template == 'home' or template == 'product' or template == 'category') and settings.brand_shoppable_stories_enable | default(false) %}
        (function () {
            var root = document.querySelector('.js-brand-shoppable-stories-root');
            if (!root) {
                return;
            }
            var elSwiper = root.querySelector('.js-swiper-brand-shoppable-stories');
            if (!elSwiper || !elSwiper.querySelector('.swiper-slide')) {
                return;
            }
            var brandShoppableSwiper = null;

            function pauseAllNativeVideos() {
                root.querySelectorAll('.swiper-slide video').forEach(function (v) {
                    try {
                        v.pause();
                    } catch (eV) {}
                });
            }

            {# Sin vid.load(): con el mismo src en varios <video>, load() en uno puede dejar al resto sin decodificar. Solo seek si ya hay datos. #}
            function primeShoppableNativeVideoFrames(visibleSlideEls) {
                var vis = visibleSlideEls && visibleSlideEls.length ? visibleSlideEls : [];
                root.querySelectorAll('.swiper-slide').forEach(function (slide) {
                    var vid = slide.querySelector('video');
                    if (!vid) {
                        return;
                    }
                    if (vis.indexOf(slide) !== -1) {
                        return;
                    }
                    try {
                        vid.muted = true;
                        if (vid.preload !== 'auto') {
                            vid.preload = 'auto';
                        }
                        if (vid.readyState >= 2) {
                            try {
                                if (vid.duration && !isNaN(vid.duration) && vid.duration > 0) {
                                    vid.currentTime = Math.min(0.12, vid.duration * 0.02);
                                } else {
                                    vid.currentTime = 0.001;
                                }
                            } catch (eS) {}
                            try {
                                vid.pause();
                            } catch (eP) {}
                        }
                    } catch (ePrime) {}
                });
            }

            function getSwiperVisibleSlideEls(swiper) {
                var out = [];
                if (!swiper || !swiper.slides || !swiper.slides.length) {
                    return out;
                }
                for (var vi = 0; vi < swiper.slides.length; vi++) {
                    var s = swiper.slides[vi];
                    if (s && s.classList && s.classList.contains('swiper-slide-visible')) {
                        out.push(s);
                    }
                }
                if (!out.length) {
                    var only = getSwiperActiveSlideEl(swiper);
                    if (only) {
                        out.push(only);
                    }
                }
                return out;
            }

            function getSwiperActiveSlideEl(swiper) {
                if (!swiper || !swiper.slides || !swiper.slides.length) {
                    return null;
                }
                var el = swiper.slides[swiper.activeIndex];
                return el && el.nodeType === 1 ? el : null;
            }

            function cacheIframeOriginalSrc() {
                root.querySelectorAll('.brand-shoppable-stories__slide-card .brand-split-video__iframe').forEach(function (ifr) {
                    if (!ifr.getAttribute('data-src-original')) {
                        ifr.setAttribute('data-src-original', ifr.getAttribute('src') || '');
                    }
                });
            }

            function applyIframePlayState(activeSlide) {
                root.querySelectorAll('.brand-shoppable-stories__slide-card .brand-split-video__iframe').forEach(function (ifr) {
                    var slide = ifr.closest('.swiper-slide');
                    var base = ifr.getAttribute('data-src-original') || '';
                    if (!base) {
                        return;
                    }
                    var isActive = activeSlide && slide === activeSlide;
                    try {
                        var u = new URL(base, window.location.origin);
                        var host = u.hostname || '';
                        if (host.indexOf('youtube.com') !== -1) {
                            if (isActive) {
                                u.searchParams.set('autoplay', '1');
                                u.searchParams.set('mute', '1');
                                u.searchParams.set('playsinline', '1');
                            } else {
                                u.searchParams.delete('autoplay');
                                u.searchParams.set('mute', '1');
                            }
                        } else if (host.indexOf('player.vimeo.com') !== -1) {
                            if (isActive) {
                                u.searchParams.set('autoplay', '1');
                                u.searchParams.set('muted', '1');
                                u.searchParams.set('playsinline', '1');
                            } else {
                                u.searchParams.delete('autoplay');
                            }
                        } else if (host.indexOf('tiktok.com') !== -1) {
                            {# Varios embeds TikTok a la vez suelen fallar o congelar el navegador: solo el slide activo carga src. #}
                            if (isActive) {
                                u.searchParams.set('autoplay', '1');
                                ifr.setAttribute('src', u.toString());
                            } else {
                                ifr.removeAttribute('src');
                            }
                            return;
                        }
                        ifr.setAttribute('src', u.toString());
                    } catch (eIframe) {
                        ifr.setAttribute('src', base);
                    }
                });
            }

            function playVisibleNativeVideos(swiper) {
                var visible = getSwiperVisibleSlideEls(swiper);
                var active = getSwiperActiveSlideEl(swiper) || elSwiper.querySelector('.swiper-slide-active');
                var muteCtrl = root.querySelector('.js-brand-story-mute');
                var wantMuted = !muteCtrl || muteCtrl.getAttribute('aria-pressed') === 'true';
                visible.forEach(function (slideEl) {
                    var vid = slideEl.querySelector('video');
                    if (!vid) {
                        return;
                    }
                    try {
                        vid.muted = active && slideEl === active ? wantMuted : true;
                        vid.currentTime = 0;
                    } catch (eCt) {}
                    var p = vid.play();
                    if (p && typeof p.catch === 'function') {
                        p.catch(function () {});
                    }
                });
            }

            function syncVideosFromSwiper(swiper) {
                var active = getSwiperActiveSlideEl(swiper) || elSwiper.querySelector('.swiper-slide-active');
                var visible = getSwiperVisibleSlideEls(swiper);
                pauseAllNativeVideos();
                primeShoppableNativeVideoFrames(visible);
                playVisibleNativeVideos(swiper);
                applyIframePlayState(active);
            }

            cacheIframeOriginalSrc();

            var shoppableLayout = (root.getAttribute('data-shoppable-layout') || 'classic').trim();
            var shoppableSwiperParams = {
                centeredSlides: false,
                speed: 520,
                watchOverflow: true,
                watchSlidesVisibility: true,
                grabCursor: true,
                roundLengths: true,
                pagination: {
                    el: root.querySelector('.js-swiper-brand-shoppable-stories-pagination'),
                    clickable: true,
                },
                on: {
                    init: function () {
                        brandShoppableSwiper = this;
                        syncVideosFromSwiper(this);
                        var self = this;
                        window.setTimeout(function () {
                            syncVideosFromSwiper(self);
                        }, 80);
                    },
                    slideChange: function () {
                        syncVideosFromSwiper(this);
                    },
                    slideChangeTransitionEnd: function () {
                        syncVideosFromSwiper(this);
                    },
                    resize: function () {
                        syncVideosFromSwiper(this);
                    },
                },
            };
            if (shoppableLayout === 'mobile_two_full') {
                shoppableSwiperParams.slidesPerView = 2;
                shoppableSwiperParams.spaceBetween = 8;
                shoppableSwiperParams.breakpoints = {
                    576: {
                        slidesPerView: 2,
                        spaceBetween: 10,
                    },
                    992: {
                        slidesPerView: 3,
                        spaceBetween: 12,
                    },
                };
            } else {
                shoppableSwiperParams.slidesPerView = 1.12;
                shoppableSwiperParams.spaceBetween = 10;
                shoppableSwiperParams.breakpoints = {
                    576: {
                        slidesPerView: 2,
                        spaceBetween: 10,
                    },
                    992: {
                        slidesPerView: 3.15,
                        spaceBetween: 12,
                    },
                };
            }

            createSwiper(
                '.js-swiper-brand-shoppable-stories',
                shoppableSwiperParams,
                function (swiperInstance) {
                    brandShoppableSwiper = swiperInstance;
                }
            );

            var labelMute = root.getAttribute('data-story-aria-mute');
            var labelUnmute = root.getAttribute('data-story-aria-unmute');
            var muteBtn = root.querySelector('.js-brand-story-mute');
            if (muteBtn) {
                muteBtn.addEventListener('click', function () {
                    var active = getSwiperActiveSlideEl(brandShoppableSwiper) || elSwiper.querySelector('.swiper-slide-active');
                    if (!active) {
                        return;
                    }
                    var video = active.querySelector('video');
                    var iframe = active.querySelector('iframe');
                    var muted;

                    if (video) {
                        video.muted = !video.muted;
                        muted = video.muted;
                    } else if (iframe) {
                        var currentlyMuted = muteBtn.getAttribute('aria-pressed') === 'true';
                        muted = !currentlyMuted;
                        try {
                            var src = iframe.getAttribute('src') || '';
                            var u = new URL(src, window.location.origin);
                            if (u.hostname.indexOf('youtube.com') !== -1) {
                                u.searchParams.set('mute', muted ? '1' : '0');
                                iframe.setAttribute('src', u.toString());
                            } else if (u.hostname.indexOf('player.vimeo.com') !== -1) {
                                u.searchParams.set('muted', muted ? '1' : '0');
                                iframe.setAttribute('src', u.toString());
                            } else if (u.hostname.indexOf('tiktok.com') !== -1) {
                                u.searchParams.set('mute', muted ? '1' : '0');
                                iframe.setAttribute('src', u.toString());
                            }
                        } catch (eMute) {}
                    } else {
                        return;
                    }

                    muteBtn.setAttribute('aria-pressed', muted ? 'true' : 'false');
                    muteBtn.classList.toggle('is-muted', muted);
                    muteBtn.classList.toggle('is-unmuted', !muted);
                    if (labelMute && labelUnmute) {
                        muteBtn.setAttribute('aria-label', muted ? labelUnmute : labelMute);
                    }
                });
            }
        })();
    {% endif %}

    {% if (template == 'home' or template == 'product' or template == 'blog' or template == 'blog-post') and settings.brand_routine_showcase_enable | default(false) %}
        (function () {
            var root = document.querySelector('.js-brand-routine-showcase');
            if (!root) {
                return;
            }
            var elJson = root.querySelector('.js-brand-routine-data');
            if (!elJson) {
                return;
            }
            var items;
            try {
                items = JSON.parse(elJson.textContent || '[]');
            } catch (e) {
                return;
            }
            if (!items.length) {
                return;
            }
            var intervalMs = parseInt(root.getAttribute('data-interval') || '6000', 10);
            var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
            var idx = 0;
            var hero = root.querySelector('[data-routine-hero]');
            var thumb = root.querySelector('[data-routine-thumb]');
            var nameEl = root.querySelector('[data-routine-name]');
            var descEl = root.querySelector('[data-routine-desc]');
            var linkEl = root.querySelector('[data-routine-link]');
            var steps = root.querySelectorAll('.js-brand-routine-step');

            function apply(i) {
                var it = items[i];
                if (!it) {
                    return;
                }
                idx = i;
                if (hero) {
                    hero.src = it.hero;
                    hero.alt = it.name || '';
                    if (it.heroLarge) {
                        hero.setAttribute('srcset', it.heroLarge + ' 720w, ' + it.hero + ' 1200w');
                        hero.setAttribute('sizes', '(max-width: 991px) 100vw, 42vw');
                    } else {
                        hero.removeAttribute('srcset');
                        hero.removeAttribute('sizes');
                    }
                }
                if (thumb) {
                    thumb.src = it.thumb;
                    thumb.alt = it.name || '';
                }
                if (nameEl) {
                    nameEl.textContent = it.name || '';
                }
                if (descEl) {
                    descEl.textContent = it.desc || '';
                }
                if (linkEl) {
                    linkEl.setAttribute('href', it.url || '#');
                }
                for (var s = 0; s < steps.length; s++) {
                    var on = s === i;
                    steps[s].classList.toggle('is-active', on);
                    steps[s].setAttribute('aria-pressed', on ? 'true' : 'false');
                }
            }

            function randomNext() {
                if (items.length < 2) {
                    return 0;
                }
                var next = idx;
                var guard = 0;
                while (next === idx && guard < 16) {
                    next = Math.floor(Math.random() * items.length);
                    guard++;
                }
                return next;
            }

            apply(0);

            var timer = null;
            function clearTimer() {
                if (timer) {
                    clearInterval(timer);
                    timer = null;
                }
            }

            function startTimer() {
                clearTimer();
                if (reduceMotion || !intervalMs) {
                    return;
                }
                timer = setInterval(function () {
                    apply(randomNext());
                }, intervalMs);
            }

            startTimer();

            for (var b = 0; b < steps.length; b++) {
                steps[b].addEventListener(
                    'click',
                    (function (stepIndex) {
                        return function () {
                            apply(stepIndex);
                            startTimer();
                        };
                    })(b)
                );
            }

            root.addEventListener('mouseenter', clearTimer);
            root.addEventListener('mouseleave', startTimer);
        })();
    {% endif %}

    {% if settings.brand_category_rail_enable %}
        (function () {
            var copyEmpty = {{ 'No encontramos productos en esta vista.' | translate | json_encode | raw }};
            var copyErr = {{ 'No pudimos cargar los productos. Intentá de nuevo.' | translate | json_encode | raw }};
            var copyLoading = {{ 'Cargando productos…' | translate | json_encode | raw }};
            var copyDotPage = {{ 'Página' | translate | json_encode | raw }};
            var brandRailResizeSeq = 0;
            var railCategoryFetchDoneMarker = {};

            function brandRailLoadMode($root) {
                return String($root.attr('data-rail-load-mode') || 'ajax').toLowerCase();
            }

            function railUrlKey(href) {
                if (!href || typeof href !== 'string') {
                    return '';
                }
                var h = decodeRailUrlEntities(href);
                try {
                    var u = new URL(h, window.location.href);
                    return u.pathname.replace(/\/+$/, '') + (u.search || '');
                } catch (eK) {
                    return h.split('?')[0].replace(/\/+$/, '');
                }
            }

            function brandRailActiveTrack($root) {
                if (brandRailLoadMode($root) === 'panels') {
                    var $tp = $root.find('.js-brand-category-rail-panel.is-active .js-brand-category-rail-track').first();
                    if ($tp.length) {
                        return $tp;
                    }
                }
                return $root.find('.js-brand-category-rail-track').first();
            }

            function brandRailLazyScope($root) {
                if (brandRailLoadMode($root) === 'panels') {
                    var $p = $root.find('.js-brand-category-rail-panel.is-active').first();
                    if ($p.length) {
                        return $p;
                    }
                }
                return $root;
            }

            function railResizeNamespace($root) {
                var ns = $root.data('brandRailResizeNs');
                if (!ns) {
                    brandRailResizeSeq += 1;
                    ns = 'brandRailDots' + String(brandRailResizeSeq);
                    $root.data('brandRailResizeNs', ns);
                }
                return ns;
            }

            function initLazyForRail($root) {
                if (!window.lazySizes) {
                    return;
                }
                if (typeof lazySizes.init === 'function') {
                    lazySizes.init();
                }
                try {
                    if (lazySizes.loader && typeof lazySizes.loader.checkElems === 'function') {
                        lazySizes.loader.checkElems();
                    }
                    if (lazySizes.autoSizer && typeof lazySizes.autoSizer.checkElems === 'function') {
                        lazySizes.autoSizer.checkElems();
                    }
                } catch (eLz) {
                    /* ignore */
                }
                if ($root && $root.length) {
                    brandRailLazyScope($root)
                        .find('.js-brand-category-rail-track .lazyload, .js-brand-category-rail-track .lazyautosizes')
                        .each(function () {
                        try {
                            if (lazySizes.loader && typeof lazySizes.loader.unveil === 'function') {
                                lazySizes.loader.unveil(this);
                            }
                        } catch (eU) {
                            /* ignore */
                        }
                    });
                }
            }

            function destroyRailScrollDots($root) {
                var pendingLazy = $root.data('railDotsLazyT');
                if (pendingLazy) {
                    window.clearTimeout(pendingLazy);
                    $root.removeData('railDotsLazyT');
                }
                var ui = $root.data('railDotsUi');
                $root.find('.js-brand-category-rail-track').off('scroll.railDots');
                var $dots = $root.find('.js-brand-category-rail-dots');
                if (ui) {
                    if (ui.ro) {
                        try {
                            ui.ro.disconnect();
                        } catch (eR) {
                            /* ignore */
                        }
                    }
                    if (ui.onWinResize && ui.resizeNs) {
                        jQueryNuvem(window).off('resize.' + ui.resizeNs, ui.onWinResize);
                    }
                    if (ui.rafScroll) {
                        cancelAnimationFrame(ui.rafScroll);
                    }
                    $root.removeData('railDotsUi');
                }
                $dots.addClass('d-none').empty().removeAttr('data-rail-pages');
            }

            function decodeRailUrlEntities(href) {
                if (!href || typeof href !== 'string' || href.indexOf('&#') === -1) {
                    return href;
                }
                try {
                    var ta = document.createElement('textarea');
                    ta.innerHTML = href;
                    var dec = ta.value;
                    return dec && dec.length ? dec : href;
                } catch (eDec) {
                    return href;
                }
            }

            function normalizeRailFetchUrl(href) {
                if (!href || typeof href !== 'string') {
                    return href;
                }
                href = decodeRailUrlEntities(href);
                try {
                    var u = new URL(href, window.location.href);
                    var uHost = String(u.hostname || '').toLowerCase().replace(/^www\./, '');
                    var wHost = String(window.location.hostname || '').toLowerCase().replace(/^www\./, '');
                    if (uHost && wHost && uHost === wHost) {
                        u.protocol = window.location.protocol;
                        u.host = window.location.host;
                    }
                    return u.toString();
                } catch (eN) {
                    return href;
                }
            }

            function setupRailScrollDots($root) {
                destroyRailScrollDots($root);
                var $track = brandRailActiveTrack($root);
                var $dots = $root.find('.js-brand-category-rail-dots');
                var track = $track[0];
                if (!track || !$dots.length) {
                    return;
                }

                function updateActiveDot() {
                    var pages = parseInt($dots.attr('data-rail-pages') || '0', 10);
                    if (pages < 2) {
                        return;
                    }
                    var maxScroll = Math.max(1, track.scrollWidth - track.clientWidth);
                    var ratio = maxScroll > 1 ? track.scrollLeft / maxScroll : 0;
                    var idx = Math.round(ratio * (pages - 1));
                    if (idx < 0) {
                        idx = 0;
                    }
                    if (idx >= pages) {
                        idx = pages - 1;
                    }
                    $dots.find('.brand-category-rail__dot').removeClass('is-active').eq(idx).addClass('is-active');
                }

                function rebuildDots() {
                    var maxScroll = track.scrollWidth - track.clientWidth;
                    var cardNodes = track.querySelectorAll('.js-item-product');
                    var n = cardNodes.length;
                    var cw = track.clientWidth || 1;
                    var firstCard = cardNodes[0];
                    var estCardW = firstCard && firstCard.offsetWidth ? Math.max(firstCard.offsetWidth, 140) : Math.min(220, cw * 0.42);
                    var perPage = Math.max(1, Math.floor(cw / Math.max(120, estCardW)));
                    var pagesByCount = n > perPage ? Math.ceil(n / perPage) : 1;
                    var pagesByScroll =
                        maxScroll > 4 ? Math.ceil(track.scrollWidth / Math.max(1, cw * 0.88)) : 1;
                    var pages = Math.min(15, Math.max(pagesByCount, pagesByScroll));
                    $dots.empty();
                    if (n < 2 || pages < 2) {
                        $dots.addClass('d-none').removeAttr('data-rail-pages');
                        return;
                    }
                    $dots.removeClass('d-none');
                    $dots.attr('data-rail-pages', String(pages));
                    for (var i = 0; i < pages; i++) {
                        var btn = document.createElement('button');
                        btn.type = 'button';
                        btn.className = 'brand-category-rail__dot' + (i === 0 ? ' is-active' : '');
                        btn.setAttribute('data-rail-dot-i', String(i));
                        btn.setAttribute('aria-label', copyDotPage + ' ' + String(i + 1));
                        $dots.append(btn);
                    }
                    updateActiveDot();
                }

                var ui = { rafScroll: null };
                ui.onScroll = function () {
                    if (ui.rafScroll) {
                        cancelAnimationFrame(ui.rafScroll);
                    }
                    ui.rafScroll = requestAnimationFrame(function () {
                        ui.rafScroll = null;
                        updateActiveDot();
                    });
                };
                $track.on('scroll.railDots', ui.onScroll);

                ui.onWinResize = function () {
                    rebuildDots();
                };
                ui.resizeNs = railResizeNamespace($root);
                jQueryNuvem(window).on('resize.' + ui.resizeNs, ui.onWinResize);

                if (typeof ResizeObserver !== 'undefined') {
                    ui.ro = new ResizeObserver(function () {
                        rebuildDots();
                    });
                    ui.ro.observe(track);
                }

                $root.data('railDotsUi', ui);
                rebuildDots();
            }

            function parseProductRowFromDocument(doc) {
                var root = doc.body || doc;
                if (!root) {
                    return '';
                }
                if (root.querySelector('parsererror')) {
                    return '';
                }

                var listRootEarly = doc.getElementById('catalog-product-list');
                if (listRootEarly) {
                    var listNodes = listRootEarly.querySelectorAll('.js-item-product[data-product-id]');
                    if (listNodes && listNodes.length) {
                        var seenL = Object.create(null);
                        var htmlL = '';
                        for (var li = 0; li < listNodes.length; li++) {
                            var elL = listNodes[li];
                            if (elL.closest('#quickshop-modal') || elL.closest('.quickshop-modal-body')) {
                                continue;
                            }
                            var idL = elL.getAttribute('data-product-id');
                            if (!idL || String(idL).trim() === '' || seenL[idL]) {
                                continue;
                            }
                            seenL[idL] = true;
                            htmlL += elL.outerHTML;
                        }
                        if (htmlL) {
                            return htmlL;
                        }
                    }
                }

                function tableInnerFrom(container) {
                    if (!container) {
                        return '';
                    }
                    var tbl =
                        container.querySelector('.js-product-table.row.row-grid') ||
                        container.querySelector('.js-product-table');
                    if (tbl && tbl.querySelector('.js-item-product[data-product-id]')) {
                        return tbl.innerHTML;
                    }
                    return '';
                }

                var catalogRoot = doc.getElementById('catalog-product-list');
                var tInner = tableInnerFrom(catalogRoot);
                if (tInner) {
                    return tInner;
                }

                var uGrid =
                    doc.querySelector('.category-body .js-user-product-grid') ||
                    doc.querySelector('.js-user-product-grid');
                tInner = tableInnerFrom(uGrid);
                if (tInner) {
                    return tInner;
                }

                function cardsHtmlFrom(container) {
                    if (!container) {
                        return '';
                    }
                    var nodes = container.querySelectorAll('.js-item-product[data-product-id]');
                    if (!nodes || !nodes.length) {
                        return '';
                    }
                    var seen = Object.create(null);
                    var html = '';
                    for (var i = 0; i < nodes.length; i++) {
                        var el = nodes[i];
                        if (el.closest('#quickshop-modal') || el.closest('.quickshop-modal-body')) {
                            continue;
                        }
                        var pid = el.getAttribute('data-product-id');
                        if (!pid || String(pid).trim() === '') {
                            continue;
                        }
                        if (seen[pid]) {
                            continue;
                        }
                        seen[pid] = true;
                        html += el.outerHTML;
                    }
                    return html;
                }

                var ch = cardsHtmlFrom(catalogRoot);
                if (ch) {
                    return ch;
                }
                ch = cardsHtmlFrom(uGrid);
                if (ch) {
                    return ch;
                }

                var mainTable =
                    doc.querySelector('.category-body .js-product-table') ||
                    doc.querySelector('.js-product-table.row.row-grid') ||
                    doc.querySelector('.js-product-table');
                if (mainTable && mainTable.querySelector('.js-item-product[data-product-id]')) {
                    return mainTable.innerHTML;
                }
                var loose = root.querySelectorAll(
                    '.category-body .js-product-table .js-item-product[data-product-id], .js-product-table .js-item-product[data-product-id]'
                );
                if (loose && loose.length) {
                    var seen2 = Object.create(null);
                    var html2 = '';
                    for (var j = 0; j < loose.length; j++) {
                        var el2 = loose[j];
                        if (el2.closest('#quickshop-modal') || el2.closest('.quickshop-modal-body')) {
                            continue;
                        }
                        var id2 = el2.getAttribute('data-product-id');
                        if (!id2 || seen2[id2]) {
                            continue;
                        }
                        seen2[id2] = true;
                        html2 += el2.outerHTML;
                    }
                    if (html2) {
                        return html2;
                    }
                }
                var wide = root.querySelectorAll('.category-body .js-item-product[data-product-id]');
                if (wide && wide.length) {
                    var seen3 = Object.create(null);
                    var html3 = '';
                    for (var k = 0; k < wide.length; k++) {
                        var el3 = wide[k];
                        if (el3.closest('#quickshop-modal') || el3.closest('.quickshop-modal-body')) {
                            continue;
                        }
                        var id3 = el3.getAttribute('data-product-id');
                        if (!id3 || seen3[id3]) {
                            continue;
                        }
                        seen3[id3] = true;
                        html3 += el3.outerHTML;
                    }
                    if (html3) {
                        return html3;
                    }
                }
                var bodyWide = root.querySelectorAll('body .js-item-product[data-product-id]');
                if (bodyWide && bodyWide.length) {
                    var seen4 = Object.create(null);
                    var html4 = '';
                    for (var m = 0; m < bodyWide.length; m++) {
                        var el4 = bodyWide[m];
                        if (el4.closest('#quickshop-modal') || el4.closest('.quickshop-modal-body')) {
                            continue;
                        }
                        var id4 = el4.getAttribute('data-product-id');
                        if (!id4 || seen4[id4]) {
                            continue;
                        }
                        seen4[id4] = true;
                        html4 += el4.outerHTML;
                    }
                    if (html4) {
                        return html4;
                    }
                }
                return '';
            }

            function parseRailInnerFromHtml(html) {
                if (!html || typeof html !== 'string') {
                    return '';
                }
                var t = html.trim();
                if (t.charAt(0) === '{' && t.indexOf('access_token') !== -1) {
                    return '';
                }
                if (t.charAt(0) === '{' && t.indexOf('"errors"') !== -1) {
                    return '';
                }
                var doc = new DOMParser().parseFromString(html, 'text/html');
                return parseProductRowFromDocument(doc);
            }

            function railFetchCategoryHtml(urlNorm, withXhrHeader) {
                var headers = {
                    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                };
                if (withXhrHeader) {
                    headers['X-Requested-With'] = 'XMLHttpRequest';
                }
                // Siempre usar path relativo para evitar problemas CORS/AJAX con URLs absolutas del mismo dominio
                var fetchUrl = urlNorm;
                try {
                    var u = new URL(urlNorm, window.location.href);
                    fetchUrl = u.pathname + u.search;
                } catch(eU) { /* ignore, use urlNorm */ }
                return window.fetch(fetchUrl, {
                    method: 'GET',
                    credentials: 'same-origin',
                    headers: headers,
                    cache: 'default',
                }).then(function(r) {
                    if (!r.ok) { throw new Error('rail_http_' + r.status); }
                    return r.text();
                }).then(function(text) {
                    return typeof text === 'string' ? text : '';
                });
            }


            function railPerspectiveSwiperGo($item, toSecond) {
                var target = toSecond ? 1 : 0;
                function tryOnce() {
                    var swiperHost =
                        $item.find('.item-image-slider.swiper-container').get(0) ||
                        $item.find('.item-image-slider .swiper-container').get(0) ||
                        $item.find('.item-image .swiper-container').get(0);
                    if (swiperHost && swiperHost.swiper && typeof swiperHost.swiper.slideTo === 'function') {
                        try {
                            swiperHost.swiper.slideTo(target, 160);
                        } catch (eS) {
                            /* ignore */
                        }
                        return true;
                    }
                    var $next = $item.find('.item-image-slider .swiper-button-next').first();
                    var $prev = $item.find('.item-image-slider .swiper-button-prev').first();
                    if (toSecond && $next.length && $next[0]) {
                        $next[0].click();
                        return true;
                    }
                    if (!toSecond && $prev.length && $prev[0]) {
                        $prev[0].click();
                        return true;
                    }
                    return false;
                }
                if (!tryOnce()) {
                    window.setTimeout(tryOnce, 90);
                    window.setTimeout(tryOnce, 260);
                }
            }

            function setRailLoading($root, on) {
                var $el = $root.find('.js-brand-category-rail-loading');
                if (on) {
                    $el.removeClass('d-none').addClass('d-flex');
                } else {
                    $el.addClass('d-none').removeClass('d-flex');
                }
            }

            function resetRailPerspective($root) {
                $root.removeClass('brand-category-rail--second-view');
                $root.find('.js-brand-category-rail-perspective').attr('aria-pressed', 'false');
                $root.find('.js-item-product').removeAttr('data-rail-persp-idx');
                $root.find('.js-item-image-flip-wrap').removeClass('is-flipped');
                $root.find('.js-item-flip-photo-root').removeClass('is-flipped');
                $root
                    .find(
                        '.item-image-slider.swiper-container, .item-image-slider .swiper-container, .item-image .swiper-container'
                    )
                    .each(function () {
                        if (this.swiper && typeof this.swiper.slideTo === 'function') {
                            try {
                                this.swiper.slideTo(0, 0);
                            } catch (e0) {
                                /* ignore */
                            }
                        }
                    });
            }

            function loadUrlIntoRail($root, url, opts) {
                opts = opts || {};
                if (brandRailLoadMode($root) !== 'ajax') {
                    return;
                }
                var $track = brandRailActiveTrack($root);
                var $status = $root.find('.js-brand-category-rail-status');
                destroyRailScrollDots($root);
                resetRailPerspective($root);
                if (opts.fromUserTab === true) {
                    $root.removeAttr('data-rail-ssr-preload');
                }
                {# Solo en la primera hidratación automática respetamos SSR si el fetch no parsea; al tocar otra pestaña (fromUserTab === true) hay que reemplazar o mostrar error. #}
                var ssrPreload =
                    opts.fromUserTab !== true &&
                    $root.attr('data-rail-ssr-preload') === '1' &&
                    $track.find('.js-item-product').length > 0;
                setRailLoading($root, !ssrPreload);
                if ($status.length) {
                    if (ssrPreload) {
                        $status.addClass('d-none').text('');
                    } else {
                        $status.removeClass('d-none').text(copyLoading);
                    }
                }
                var urlNorm = normalizeRailFetchUrl(url);

                function applyRailInner(inner) {
                    if (!inner) {
                        return;
                    }
                    $track.html(inner);
                    $track.addClass('brand-category-rail__track--entering');
                    window.setTimeout(function () { $track.removeClass('brand-category-rail__track--entering'); }, 350);
                    $root.removeAttr('data-rail-ssr-preload');
                    var useSlider =
                        String($root.attr('data-product-item-slider')) === '1' &&
                        typeof LS !== 'undefined' &&
                        typeof LS.productItemSlider === 'function';
                    if (useSlider) {
                        try {
                            LS.productItemSlider({ pagination_type: 'bullets' });
                        } catch (e1) {
                            /* ignore */
                        }
                    }
                    initLazyForRail($root);
                }

                {# HTML completo primero (como navegador); XHR solo si hace falta — TN suele devolver el listado completo en category.tpl. #}
                railFetchCategoryHtml(urlNorm, false)
                    .then(function (html) {
                        var inner = parseRailInnerFromHtml(html);
                        if (inner) {
                            applyRailInner(inner);
                            return railCategoryFetchDoneMarker;
                        }
                        return railFetchCategoryHtml(urlNorm, true);
                    })
                    .then(function (html2) {
                        if (html2 === railCategoryFetchDoneMarker) {
                            return;
                        }
                        var inner2 = parseRailInnerFromHtml(html2);
                        if (inner2) {
                            applyRailInner(inner2);
                        } else if (!ssrPreload) {
                            if (window.console && console.warn) {
                                var dbgDoc = null;
                                try {
                                    dbgDoc = new DOMParser().parseFromString(
                                        html2 && typeof html2 === 'string' ? html2 : '',
                                        'text/html'
                                    );
                                } catch (eDbg) {
                                    /* ignore */
                                }
                                console.warn('[brand-category-rail] parse vacío', {
                                    url: urlNorm,
                                    htmlLen: html2 && typeof html2 === 'string' ? html2.length : 0,
                                    hasCatalog: !!(dbgDoc && dbgDoc.getElementById('catalog-product-list')),
                                });
                            }
                            $track.html(
                                '<div class="col-12 py-4 text-center text-muted small">' + copyEmpty + '</div>'
                            );
                        }
                    })
                    .catch(function (err) {
                        if (window.console && console.warn) {
                            console.warn('[brand-category-rail]', urlNorm, err && err.message ? err.message : err);
                        }
                        if (!ssrPreload) {
                            $track.html(
                                '<div class="col-12 py-4 text-center text-muted small">' + copyErr + '</div>'
                            );
                        }
                    })
                    .finally(function () {
                        setRailLoading($root, false);
                        if ($status.length) {
                            $status.addClass('d-none').text('');
                        }
                        setupRailScrollDots($root);
                        initLazyForRail($root);
                    });
            }

            jQueryNuvem(document).on('lazyloaded', '.js-brand-category-rail img', function () {
                var $rail = jQueryNuvem(this).closest('.js-brand-category-rail');
                if (!$rail.length) {
                    return;
                }
                var prevT = $rail.data('railDotsLazyT');
                if (prevT) {
                    window.clearTimeout(prevT);
                }
                $rail.data(
                    'railDotsLazyT',
                    window.setTimeout(function () {
                        $rail.removeData('railDotsLazyT');
                        setupRailScrollDots($rail);
                    }, 140)
                );
            });

            jQueryNuvem(document).on('click', '.js-brand-category-rail-tab', function (e) {
                var $btn = jQueryNuvem(this);
                var $root = $btn.closest('.js-brand-category-rail');
                if (!$root.length) {
                    return;
                }
                var mode = brandRailLoadMode($root);
                if (mode === 'link') {
                    return;
                }
                var href = $btn.attr('data-url');
                if (!href) {
                    return;
                }
                e.preventDefault();
                // Marcar pestaña activa visualmente
                $root.find('.js-brand-category-rail-tab').removeClass('brand-category-rail__tab--active');
                $btn.addClass('brand-category-rail__tab--active');
                // Sincronizar URL del navegador sin recargar la página
                try {
                    if (href && window.history && window.history.pushState) {
                        window.history.pushState({ railTab: href }, '', href);
                    }
                } catch (ePush) { /* ignore */ }
                if (mode === 'panels') {
                    var tabKey = railUrlKey(href);
                    var $activePanel = jQueryNuvem();
                    $root.find('.js-brand-category-rail-panel').removeClass('is-active').addClass('d-none');
                    $root.find('.js-brand-category-rail-panel').each(function () {
                        var raw = jQueryNuvem(this).attr('data-rail-panel-url');
                        if (!raw) {
                            return;
                        }
                        if (railUrlKey(raw) === tabKey) {
                            $activePanel = jQueryNuvem(this);
                            $activePanel.addClass('is-active').removeClass('d-none');
                            return false;
                        }
                    });
                    resetRailPerspective($root);
                    destroyRailScrollDots($root);
                    setupRailScrollDots($root);
                    initLazyForRail($root);
                    if ($activePanel.length) {
                        var $activeTrack = $activePanel.find('.js-brand-category-rail-track').first();
                        var alreadyLoaded = $activeTrack.find('.js-item-product[data-product-id]').length > 0;
                        var alreadyTried = $activePanel.attr('data-rail-panel-fetch-tried') === '1';
                        if (!alreadyLoaded && !alreadyTried) {
                            $activePanel.attr('data-rail-panel-fetch-tried', '1');
                            setRailLoading($root, true);
                            railFetchCategoryHtml(normalizeRailFetchUrl(href), false)
                                .then(function (htmlP) {
                                    var innerP = parseRailInnerFromHtml(htmlP);
                                    if (innerP) {
                                        $activeTrack.html(innerP);
                                        initLazyForRail($root);
                                        setupRailScrollDots($root);
                                        return railCategoryFetchDoneMarker;
                                    }
                                    return railFetchCategoryHtml(normalizeRailFetchUrl(href), true);
                                })
                                .then(function (htmlP2) {
                                    if (htmlP2 === railCategoryFetchDoneMarker) {
                                        return;
                                    }
                                    var innerP2 = parseRailInnerFromHtml(htmlP2);
                                    if (innerP2) {
                                        $activeTrack.html(innerP2);
                                        initLazyForRail($root);
                                        setupRailScrollDots($root);
                                    }
                                })
                                .catch(function () {
                                    /* ignore panel fallback errors */
                                })
                                .finally(function () {
                                    setRailLoading($root, false);
                                });
                        }
                    }
                    return;
                }
                loadUrlIntoRail($root, href, { fromUserTab: true });
            });

            // Al presionar «atrás/adelante» del navegador, reflejar la pestaña correcta sin recargar
            window.addEventListener('popstate', function (ev) {
                var targetUrl = (ev.state && ev.state.railTab) ? ev.state.railTab : window.location.pathname;
                jQueryNuvem('.js-brand-category-rail').each(function () {
                    var $r = jQueryNuvem(this);
                    if (brandRailLoadMode($r) !== 'ajax') { return; }
                    var $tabs = $r.find('.js-brand-category-rail-tab');
                    var matched = false;
                    $tabs.each(function () {
                        var tabUrl = jQueryNuvem(this).attr('data-url');
                        if (tabUrl && railUrlKey(tabUrl) === railUrlKey(targetUrl)) {
                            $tabs.removeClass('brand-category-rail__tab--active');
                            jQueryNuvem(this).addClass('brand-category-rail__tab--active');
                            loadUrlIntoRail($r, tabUrl, { fromUserTab: false });
                            matched = true;
                            return false;
                        }
                    });
                });
            });

            jQueryNuvem(document).on('click', '.js-brand-category-rail-dots .brand-category-rail__dot', function (e) {
                e.preventDefault();
                var $dot = jQueryNuvem(this);
                var $root = $dot.closest('.js-brand-category-rail');
                var $track = brandRailActiveTrack($root);
                var tr = $track[0];
                var $dots = $root.find('.js-brand-category-rail-dots');
                if (!tr || !$dots.length) {
                    return;
                }
                var pages = parseInt($dots.attr('data-rail-pages') || '0', 10);
                if (pages < 2) {
                    return;
                }
                var idx = parseInt($dot.attr('data-rail-dot-i') || '0', 10);
                var maxScroll = Math.max(0, tr.scrollWidth - tr.clientWidth);
                if (maxScroll > 6) {
                    var left = (idx / (pages - 1)) * maxScroll;
                    if (typeof tr.scrollTo === 'function') {
                        tr.scrollTo({ left: left, behavior: 'smooth' });
                    } else {
                        tr.scrollLeft = left;
                    }
                    return;
                }
                var cardNodes = tr.querySelectorAll('.js-item-product');
                var n = cardNodes.length;
                if (!n) {
                    return;
                }
                var target = Math.min(
                    n - 1,
                    Math.round((idx / Math.max(1, pages - 1)) * Math.max(0, n - 1))
                );
                var el = cardNodes[target];
                if (el && typeof el.scrollIntoView === 'function') {
                    el.scrollIntoView({ inline: 'start', behavior: 'smooth', block: 'nearest' });
                }
            });

            jQueryNuvem(document).on('click', '.js-brand-category-rail-perspective', function (e) {
                e.preventDefault();
                var $b = jQueryNuvem(this);
                var $root = $b.closest('.js-brand-category-rail');
                if (!$root.length) {
                    return;
                }
                var on = !$root.hasClass('brand-category-rail--second-view');
                $root.toggleClass('brand-category-rail--second-view', on);
                $b.attr('aria-pressed', on ? 'true' : 'false');
                {# Segunda foto sin slider: CSS .brand-category-rail--second-view en style-async. Con slider: Swiper. #}
                var $items =
                    brandRailLoadMode($root) === 'panels'
                        ? $root.find('.js-brand-category-rail-panel.is-active .js-item-product')
                        : $root.find('.js-brand-category-rail-track .js-item-product');
                $items.each(function () {
                    var $item = jQueryNuvem(this);
                    if ($item.find('.item-image-slider').length) {
                        railPerspectiveSwiperGo($item, on);
                    }
                });
            });

            {# SSR en Twig + fetch: pequeño delay para que el DOM/lazy estén listos antes del primer fetch. #}
            jQueryNuvem('.js-brand-category-rail').each(function () {
                var $r = jQueryNuvem(this);
                if ($r.hasClass('brand-category-rail--empty')) {
                    return;
                }
                setupRailScrollDots($r);
                initLazyForRail($r);
            });
            jQueryNuvem('.js-brand-category-rail').each(function () {
                var $r = jQueryNuvem(this);
                if ($r.hasClass('brand-category-rail--empty')) { return; }
                if (brandRailLoadMode($r) !== 'ajax') { return; }

                var currentPath = window.location.pathname;
                var $tabs = $r.find('.js-brand-category-rail-tab');
                var $matchedTab = jQueryNuvem();

                // Si la URL actual coincide con alguna pestaña, activarla automáticamente
                $tabs.each(function () {
                    var tabUrl = jQueryNuvem(this).attr('data-url');
                    if (tabUrl && railUrlKey(tabUrl) === railUrlKey(currentPath)) {
                        $matchedTab = jQueryNuvem(this);
                        return false;
                    }
                });

                var $first = $matchedTab.length
                    ? $matchedTab
                    : $r.find('.js-brand-category-rail-tab.brand-category-rail__tab--active').first();

                if ($matchedTab.length) {
                    $tabs.removeClass('brand-category-rail__tab--active');
                    $matchedTab.addClass('brand-category-rail__tab--active');
                    // Scroll automático para que la pestaña activa sea visible
                    try {
                        var navEl = $r.find('.brand-category-rail__nav')[0];
                        var btnEl = $matchedTab[0];
                        if (navEl && btnEl) {
                            var navLeft = navEl.getBoundingClientRect().left;
                            var btnLeft = btnEl.getBoundingClientRect().left;
                            navEl.scrollLeft += (btnLeft - navLeft) - 16;
                        }
                    } catch(eScroll) { /* ignore */ }
                }

                if ($first.length) {
                    var firstUrl = $first.attr('data-url');
                    window.setTimeout(function () {
                        loadUrlIntoRail($r, firstUrl);
                    }, 150);
                }
            });

        })();
    {% endif %}

    {# Carrusel nativo TN (product_item_slider): LS.productItemSlider en todas las plantillas; grillas con .js-product-table (listado, home, relacionados, carril, etc.). #}
    {% if has_item_slider %}
        (function themeInitProductItemSlidersGlobal() {
            function run() {
                if (typeof LS === 'undefined' || typeof LS.productItemSlider !== 'function') {
                    return;
                }
                try {
                    LS.productItemSlider({
                        pagination_type: 'bullets',
                    });
                } catch (eRun) {
                    /* ignore */
                }
            }
            run();
            setTimeout(run, 450);
            setTimeout(run, 1400);
            {# Vitrinas / componentes TN que montan el DOM tarde (módulos home, modales, etc.) #}
            setTimeout(run, 3200);
        })();
    {% endif %}

    {#/*============================================================================
      #Footer
    ==============================================================================*/ #}

    {% if settings.footer_menu and settings.footer_menu_show %}
        jQueryNuvem(".js-footer-col-sticky").css("top" , head_height + 40 + 'px');
    {% endif %}

    {% if store.afip %}

        {# Add alt attribute to external AFIP logo to improve SEO #}

        jQueryNuvem('img[src*="www.afip.gob.ar"]').attr('alt', '{{ "Logo de AFIP" | translate }}');

    {% endif %}


    {#/*============================================================================
      #Empty placeholders
    ==============================================================================*/ #}

    {% set show_help = not has_products %}

    {% if template == 'home' and show_help %}

        {# /* // Home slider */ #}

        var width = window.innerWidth;
        if (width > 767) {
            var slider_empty_autoplay = {delay: 6000,};
        } else {
            var slider_empty_autoplay = false;
        }

        window.homeEmptySlider = {
            getAutoRotation: function() {
                return slider_empty_autoplay;
            },
        };
        createSwiper('.js-home-empty-slider', {
            {% if not params.preview %}
            lazy: true,
            {% endif %}
            loop: true,
            autoplay: slider_empty_autoplay,
            navigation: {
                nextEl: '.js-swiper-empty-home-next',
                prevEl: '.js-swiper-empty-home-prev',
            },
            on: {
                init: function () {
                    jQueryNuvem(".js-home-empty-slider").css("visibility", "visible").css("height", "100%");
                },
            },
        });


        {# /* // Banner services slider */ #}
        var width = window.innerWidth;
        if (width < 767) {
            createSwiper('.js-informative-banners', {
                slidesPerView: 1,
                watchOverflow: true,
                centerInsufficientSlides: true,
                pagination: {
                    el: '.js-informative-banners-pagination',
                    clickable: true,
                },
                breakpoints: {
                    640: {
                        slidesPerView: 3,
                    }
                }
            });
        }

    {% endif %}

    {% if template == '404' and show_help %}

        {# /* // Product Related */ #}

        createSwiper('.js-swiper-related', {
            lazy: true,
            loop: true,
            watchOverflow: true,
            slidesPerView: slidesPerViewMobileVal,
            watchSlideProgress: true,
            watchSlidesVisibility: true,
            spaceBetween: itemSwiperSpaceBetween,
            slideVisibleClass: 'js-swiper-slide-visible',
            slidesPerView: 2,
            navigation: {
                nextEl: '.js-swiper-related-next',
                prevEl: '.js-swiper-related-prev',
            },
            pagination: {
                el: '.js-swiper-related-pagination',
                type: 'fraction',
            },
            breakpoints: {
                768: {
                    slidesPerView: 4,
                }
            }
        });

        {# /* // Product slider */ #}

        createSwiper('.js-swiper-product', {
            lazy: true,
            slidesPerView: 'auto',
            watchOverflow: true,
            navigation: {
                nextEl: '.js-swiper-product-next',
                prevEl: '.js-swiper-product-prev',
            },
            spaceBetween: 25,
            pagination: {
                el: '.js-swiper-product-pagination',
                type: 'fraction',
            },
            on: {
                init: function () {
                    jQueryNuvem(".js-product-slider-placeholder").hide();
                    jQueryNuvem(".js-swiper-product").css("visibility", "visible").css("height", "auto");
                },
            },
            breakpoints: {
                768: {
                    slidesPerView: 'auto',
                }
            },
        });

        {# /* 404 handling to show the example product */ #}

        if ( window.location.pathname === "/product/example/" || window.location.pathname === "/br/product/example/" ) {
            document.title = "{{ "Producto de ejemplo" | translate | escape('js') }}";
            jQueryNuvem("#page-error").hide();
            jQueryNuvem("#product-example").show();
        } else {
            jQueryNuvem("#product-example").hide();
        }

    {% endif %}

});
