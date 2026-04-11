<section class="pdp-section pdp-section--promos" aria-label="{{ 'Promociones' | translate }}">
{{ component('promotions-details', {
    promotions_details_classes: {
        container: 'js-product-promo-container pdp-promo-stack px-0 mb-2' ~ (not home_main_product ? ' col-md-8' : ''),
        promotion_title: 'font-large mb-1 mt-4 text-accent',
        valid_scopes: 'font-small mb-0',
        categories_combinable: 'font-small mb-0',
        not_combinable: 'font-small opacity-60 mb-0',
        progressive_discounts_table: 'table mb-2 mt-3',
        progressive_discounts_show_more_link: 'btn-link btn-link-primary mb-4',
        progressive_discounts_show_more_icon: 'icon-inline',
        progressive_discounts_hide_icon: 'icon-inline icon-flip-vertical',
        progressive_discounts_promotion_quantity: 'font-weight-light text-lowercase'
    },
    accordion_show_svg_id: 'chevron-down',
    accordion_hide_svg_id: 'chevron-down',
}) }}
</section>
