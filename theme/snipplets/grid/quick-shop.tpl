{% if settings.quick_shop %}
    {# Quick shop editorial: columna única; CTA “Agregar al carrito” visible (misma clase que PDP: brand-pdp-cta). #}
    {% embed "snipplets/modal.tpl" with{
        modal_id: 'quickshop-modal',
        modal_class: 'quickshop bottom modal-overflow-none modal-bottom-sheet modal-right-md quickshop-modal--fashion',
        modal_position: 'bottom',
        modal_position_desktop: 'right',
        modal_footer: false,
        modal_width: 'docked-md',
        modal_transition: 'slide',
        modal_header_class: 'js-quickshop-header d-none',
        modal_body_class: 'modal-scrollable quickshop-fashion__sheet p-0'
    } %}
        {% block modal_body %}
            <div class="js-item-product modal-scrollable modal-scrollable-area quickshop-modal-body quickshop-fashion" data-product-id="">
                <div class="js-product-container js-quickshop-container js-quickshop-modal position-relative" data-variants="" data-quickshop-id="">
                    <header class="quickshop-fashion__bar d-flex justify-content-between align-items-center px-3 pt-3 pb-2">
                        <span class="quickshop-fashion__label text-uppercase small mb-0">{{ 'Compra rápida' | translate }}</span>
                        <a class="js-modal-close modal-close quickshop-fashion__close text-body p-1" href="#" title="{{ 'Cerrar' | translate }}" aria-label="{{ 'Cerrar' | translate }}">
                            <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#times"/></svg>
                        </a>
                    </header>
                    <div class="quickshop-fashion__media px-3">
                        <div class="quickshop-image-container quickshop-image-container--responsive quickshop-fashion__figure">
                            <div class="js-quickshop-image-padding quickshop-image-padding--responsive position-relative">
                                <img srcset="" class="js-item-image js-quickshop-img quickshop-image d-block quickshop-image--responsive img-fluid w-100" alt=""/>
                            </div>
                        </div>
                    </div>
                    <div class="quickshop-fashion__detail px-3 pb-3 pt-2">
                        <div class="js-item-name quickshop-fashion__title text-uppercase mb-2"></div>
                        <div class="quickshop-modal-prices quickshop-fashion__prices mb-3">
                            <span class="js-price-display quickshop-fashion__price"></span>
                            <span class="js-compare-price-display price-compare quickshop-fashion__compare ml-2"></span>
                            {{ component('payment-discount-price', {
                                    visibility_condition: settings.payment_discount_price,
                                    location: 'product',
                                    container_classes: "quickshop-fashion__transfer font-small mt-2 mb-0",
                                })
                            }}
                        </div>
                        <div id="quickshop-form" class="quickshop-fashion__form"></div>
                    </div>
                </div>
            </div>
        {% endblock %}
    {% endembed %}
{% endif %}
