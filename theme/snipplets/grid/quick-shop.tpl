{% if settings.quick_shop %}
    {% embed "snipplets/modal.tpl" with{modal_id: 'quickshop-modal', modal_class: 'quickshop bottom modal-overflow-none modal-bottom-sheet', modal_position: 'bottom', modal_transition: 'slide', modal_footer: false, modal_width: 'centered-md modal-centered-medium', modal_header_class: 'js-quickshop-header d-none', modal_body_class: 'modal-scrollable p-0'} %}
        {% block modal_body %}
            <div class="js-item-product modal-scrollable modal-scrollable-area" data-product-id="">
                <div class="js-product-container js-quickshop-container js-quickshop-modal js-quickshop-modal-shell" data-variants="" data-quickshop-id="">
                    <div class="row no-gutters">
                        <div class="col-md-6">
                            <div class="quickshop-image-container d-none d-md-block px-3 px-md-0">
                                <div class="js-quickshop-image-padding">
                                    <img srcset="" class="js-item-image js-quickshop-img quickshop-image d-block img-absolute-centered"/>
                                </div>
                            </div>
                        </div>
                        <div class="js-item-variants col-md-6 p-3 p-md-4 quickshop-info-column">
                            <div class="row no-gutters align-items-start mr-md-1 mb-3 d-flex quickshop-info-header">
                                <div class="col">
                                    <div class="js-item-name h4-huge h3-huge-md mb-2 mb-md-0" data-store="product-item-name-{{ product.id }}"></div>
                                </div>
                                <div class="col-auto">
                                    <a class="js-modal-close modal-close pr-0 py-0">
                                        <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#times"/></svg>
                                    </a>
                                </div>
                            </div>
                            {# Misma envoltura que item.tpl (data-store); precio dinámico Hache: .hs-dyn-price-addon hermano de .js-price-display. #}
                            <div class="quickshop-price-block mb-4 mr-md-1">
                                <div class="item-price-container d-flex flex-column align-items-center align-items-md-start" data-store="product-item-price-{{ product.id }}">
                                    {# Fila única: precio + addon Hache (hermano de .js-price-display) + compare; TN a veces concatena todo en .js-price-display — themeRepairQuickshopPriceLine lo parte. #}
                                    <div class="quickshop-price-line d-flex flex-row flex-wrap align-items-baseline justify-content-center justify-content-md-start">
                                        <span class="js-price-display item-price font-largest font-weight-bold"></span>
                                        <span class="js-compare-price-display price-compare font-big ml-md-2 mt-1 mt-md-0"></span>
                                    </div>
                                    {% if settings.payment_discount_price %}
                                        <div class="w-100 mt-2 pt-1 font-small js-theme-transfer-computed js-theme-transfer-quickshop quickshop-transfer-row" data-transfer-pct="" style="display: none;">
                                            <span class="js-theme-transfer-amount h5 font-big font-family-body text-accent"></span>
                                            <span class="opacity-90 js-theme-transfer-quickshop-label" aria-hidden="true"></span>
                                        </div>
                                    {% endif %}
                                </div>
                            </div>
                            {# Image is hidden but present so it can be used on cart notifiaction #}
                            
                            <div id="quickshop-form" class="mr-md-1 quickshop-form-slot"></div>
                        </div>
                    </div>
                </div>
            </div>
        {% endblock %}
    {% endembed %}
{% endif %}
