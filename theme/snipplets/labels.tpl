{% set label_accent_classes = 'label label-accent ' ~ (product_detail ? 'label-big ') %}

{{ component(
  'labels', {
    defer_stock_label_text: true,
    prioritize_promotion_over_offer: true,
    offer_negative_discount_percentage: true,
    offer_percentage_wording: true,
    promotion_nxm_long_wording: false,
    labels_classes: {
      group: 'js-labels-floating-group labels ' ~ label_custom_class,
      promotion: label_accent_classes ~ ' mb-2',
      offer: 'js-offer-label mb-2 ' ~ label_accent_classes,
      shipping: label_accent_classes,
      no_stock: 'js-stock-label label label-default mb-2',
    },
  })
}}