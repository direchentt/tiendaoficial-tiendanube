{% set product_view_box = '0 0 1000 1000' %}

<div class="section-home" data-store="home-product-main">
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-auto product-image-column pb-4">
                <div class="swiper-buttons p-0 mr-2">
                    <div class="js-swiper-product-prev-demo swiper-button-prev svg-icon-text">
                        <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
                    </div>
                    <div class="js-swiper-product-next-demo swiper-button-next svg-icon-text">
                        <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
                    </div>
                </div>
                <div class="js-swiper-product-pagination-demo swiper-pagination d-inline-block w-auto position-relative pt-3 text-left"></div>
                <div class="js-swiper-product-demo swiper-container">
                    <div class="labels">
                        <div class="label label-accent mb-2 label-big">
                            {{ "Envío gratis" | translate }}
                        </div>
                        <div class="label label-accent mb-2 label-big">
                            -35% OFF
                        </div>
                    </div>
                    <div class="swiper-wrapper">
                         <div class="js-product-slide swiper-slide product-slide slider-slide" data-image="0" data-image-position="0">
                            <a href="{{ image | product_image_url('huge') }}" data-fancybox="product-gallery" class="d-block p-relative">
                                <svg viewBox='{{ product_view_box }}'><use xlink:href="#item-product-placeholder-3"/></svg>
                            </a>
                         </div>
                         <div class="js-product-slide swiper-slide product-slide slider-slide" data-image="1" data-image-position="1">
                            <a href="{{ image | product_image_url('huge') }}" data-fancybox="product-gallery" class="d-block p-relative">
                                <svg viewBox='{{ product_view_box }}'><use xlink:href="#product-image-green-placeholder"/></svg>
                            </a>
                         </div>
                         <div class="js-product-slide swiper-slide product-slide slider-slide" data-image="2" data-image-position="2">
                            <a href="{{ image | product_image_url('huge') }}" data-fancybox="product-gallery" class="d-block p-relative">
                                <svg viewBox='{{ product_view_box }}'><use xlink:href="#product-image-red-placeholder"/></svg>
                            </a>
                         </div>
                    </div>
                </div>
            </div>
            <div class="col-md-auto product-info-column">
                <div class="pt-md-3">
                    <h1 class="h3-huge h2-huge-md mb-3">{{ "Producto de ejemplo" | translate }}</h1>

                    {# Product price #}

                    {% set product_can_show_installments = product.show_installments and product.display_price %}

                    {% if store.country == 'BR' %}
                        <div class="price-container mb-3">
                            <span class="d-inline-block">
                                <div class="js-price-display h3 font-family-body" id="price_display">{{"18200" | money_nocents }}</div>
                            </span>
                            <span class="d-inline-block font-big">
                               <div id="compare_price_display" class="js-compare-price-display price-compare" style="display:block;">{{"28000" | money_nocents }}</div>
                            </span>
                        </div>
                    {% else %}
                        <div class="price-container mb-3">
                            <span class="d-inline-block">
                                <div class="js-price-display h3 font-family-body" id="price_display">{{"182000" | money_nocents }}</div>
                            </span>
                            <span class="d-inline-block font-big">
                               <div id="compare_price_display" class="js-compare-price-display price-compare" style="display:block;">{{"280000" | money_nocents }}</div>
                            </span>
                        </div>
                    {% endif %}

                    {# Product installments #}

                    <div class="mb-3">{{ "Hasta 12 cuotas" | translate }}</div>

                    {# Product form, includes: Variants, CTA and Shipping calculator #}

                    <form id="product_form" class="js-product-form overflow-none" method="post" action="">
                        <input type="hidden" name="add_to_cart" value="2243561" />

                        <div class="js-product-variants row mb-2">
                            <div class="col-12">
                                <div class="form-group">
                                    <label class="form-label" for="variation_1">{{ "Color" | translate }}</label>
                                    <select id="variation_1" class="form-select js-variation-option js-refresh-installment-data  " name="variation[0]">
                                        <option value="{{ "Verde" | translate }}">{{ "Verde" | translate }}</option>
                                        <option value="{{ "Rojo" | translate }}">{{ "Rojo" | translate }}</option>
                                    </select>
                                    <div class="form-select-icon">
                                        <svg class="icon-inline icon-w-14"><use xlink:href="#chevron-down"/></svg>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row mb-4 mb-md-3">
                            <div class="col-4">
                                {% embed "snipplets/forms/form-input.tpl" with{
                                type_number: true, input_value: '1', 
                                input_name: 'quantity' ~ item.id, 
                                input_custom_class: 'js-quantity-input form-control-big form-control-inline', 
                                input_label: false, 
                                input_append_content: true, 
                                input_group_custom_class: 'js-quantity form-quantity', 
                                form_control_container_custom_class: 'col px-0', 
                                form_control_quantity: true,
                                input_min: '1'} %}
                                    {% block input_prepend_content %}
                                    <div class="form-row m-0 align-items-center">
                                        <span class="js-quantity-down form-quantity-icon icon-30px font-small">
                                            <svg class="icon-inline"><use xlink:href="#minus"/></svg>
                                        </span>
                                    {% endblock input_prepend_content %}
                                    {% block input_append_content %}
                                        <span class="js-quantity-up form-quantity-icon icon-30px font-small">
                                            <svg class="icon-inline"><use xlink:href="#plus"/></svg>
                                        </span>
                                    </div>
                                    {% endblock input_append_content %}
                                {% endembed %}
                            </div>
                            <div class="col-8 pl-0">
                                <input type="submit" class="js-addtocart js-prod-submit-form btn btn-primary btn-big btn-block cart" value="{{ 'Agregar al carrito' | translate }}" />
                            </div>
                        </div>

                    </form>

                    {# Product description #}

                    <div class="font-small mb-3">{{ "Descripción" | translate }}</div>

                    <div class="user-content font-small mb-4">
                        <p>{{ "¡Este es un producto de ejemplo! Para poder probar el proceso de compra, debes" | translate }}
                            <a href="/admin/products" target="_top">{{ "agregar tus propios productos." | translate }}</a>
                        </p>
                    </div>

                </div>                
            </div>
        </div>
    </div>  
</div>