{% if settings.quick_shop %}
    {# Drawer lateral (desktop) / panel 100% ancho (mobile); precio + color arriba; talles en grid; tap talle = add to cart (JS + quickshop-form--tap-add). #}
    {% embed "snipplets/modal.tpl" with{
        modal_id: 'quickshop-modal',
        modal_class: 'quickshop modal-overflow-none quickshop-drawer modal-docked-md modal-right-md',
        modal_position: 'right',
        modal_position_desktop: 'right',
        modal_footer: false,
        modal_width: 'docked-md',
        modal_transition: 'slide',
        modal_header_class: 'js-quickshop-header d-none',
        modal_body_class: 'modal-scrollable quickshop-drawer__body p-3 p-md-4'
    } %}
        {% block modal_body %}
            <div class="js-item-product modal-scrollable modal-scrollable-area quickshop-drawer__scroll quickshop-modal-body" data-product-id="">
                <div class="js-product-container js-quickshop-container js-quickshop-modal quickshop-drawer__panel position-relative d-flex flex-column" data-variants="" data-quickshop-id="">
                    <div class="d-flex justify-content-end align-items-start flex-shrink-0 mb-2">
                        <a class="js-modal-close modal-close quickshop-drawer__close text-body p-1" href="#" title="{{ 'Cerrar' | translate }}" aria-label="{{ 'Cerrar' | translate }}">
                            <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#times"/></svg>
                        </a>
                    </div>
                    <div class="quickshop-drawer__media flex-shrink-0 mb-3">
                        <div class="quickshop-image-container quickshop-image-container--responsive">
                            <div class="js-quickshop-image-padding quickshop-image-padding--responsive position-relative">
                                <img srcset="" class="js-item-image js-quickshop-img quickshop-image d-block quickshop-image--responsive img-fluid w-100" alt=""/>
                            </div>
                        </div>
                    </div>
                    <div class="quickshop-drawer__meta flex-shrink-0 mb-2">
                        <div class="js-item-name h6 text-uppercase font-weight-bold mb-2"></div>
                        <div class="quickshop-modal-prices">
                            <span class="js-price-display font-weight-bold"></span>
                            <span class="js-compare-price-display price-compare font-small ml-1"></span>
                            {{ component('payment-discount-price', {
                                    visibility_condition: settings.payment_discount_price,
                                    location: 'product',
                                    container_classes: "font-small mt-1 mb-0",
                                })
                            }}
                        </div>
                    </div>
                    <div id="quickshop-form" class="quickshop-form--tap-add quickshop-drawer__variants flex-grow-1 min-w-0"></div>
                </div>
            </div>
        {% endblock %}
    {% endembed %}
{% endif %}
