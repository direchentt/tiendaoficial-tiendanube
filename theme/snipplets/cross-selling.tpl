{# Cross selling promotion form #}

{% if promotion %}
    {{ component(
        'promotions/cross-selling-form', {
            css_classes: {
                main_container: 'm-auto',
                image_container: 'position-relative',
                discount_percentage_label: 'label label-accent position-absolute label-top-left',
                image: 'img-fluid w-100 lazyload product-image-limited',
                form_container: 'px-4 py-3',
                product_name: 'font-big text-center mb-2',
                prices_container: 'price-container text-center mb-3',
                price_wrapper: 'd-inline-block',
                original_price: 'price-compare font-weight-normal mb-0',
                promo_price: 'text-primary mb-0',
                variant_selection_group: 'form-group px-2 mb-2',
                variant_selection_label: 'form-label',
                variant_select: 'form-select',
                variant_select_icon_container: 'form-select-icon mr-1',
                variant_select_icon_image: 'icon-inline icon-w-14 icon-lg',
                add_to_cart_button_container: 'mt-4',
                add_to_cart_button: 'btn btn-primary btn-block'
            },
            icon_config: {
                use_svg_icon: true,
                svg_icon_id: 'chevron-down'
            },
            content: {
                button_placeholder: include('snipplets/placeholders/button-placeholder.tpl')
            }
        })
    }}
{% endif %}