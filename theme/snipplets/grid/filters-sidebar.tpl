{% if has_applied_filters %}
  <div class="col-12 mb-3 mb-md-4 visible-when-content-ready {% if products %}d-none{% endif %} {% if not settings.filters_desktop_modal %}d-md-block{% endif %}">
    {{ component(
      'filters/remove-filters',{
        filter_classes: {
          applied_filters_label: "font-body font-weight-bold mb-2",
          remove: "chip",
          remove_icon: "chip-remove-icon",
          remove_all: "btn-link d-inline-block mt-1 mt-md-0 font-small",
        },
        remove_filter_svg_id: 'times',
      }) 
    }}
  </div>
{% endif %}
{% if not settings.filters_desktop_modal %} 
  <div class="col-md-auto filters-sidebar d-none d-md-block visible-when-content-ready">
    {% if products %}

      {{ component(
        'sort-by',{
          sort_by_classes: {
            container: 'mb-4 pb-2',
            select_group: "d-inline-block w-auto mb-0",
            select_label: "h2 font-extra-large mb-3 d-block",
            select: "form-select-small",
            select_svg: "icon-inline icon-xs icon-w-14",
          },
          select_svg_id: 'chevron-down'
        }) 
      }}

      {{ component(
        'filters/filters',{
          container_classes: {
            filters_container: "visible-when-content-ready",
          },
          filter_classes: {
            parent_category_link: "d-block",
            parent_category_link_icon: "icon-inline icon-flip-horizontal mr-2 svg-icon-text",
            list: "mb-4 pb-2 list-unstyled",
            list_item: "mb-2",
            list_link: "font-small",
            list_title: "h2 font-extra-large mb-4",
            show_more_link: "d-inline-block btn-link font-small mt-1",
            checkbox_last: "m-0",
            price_group: 'price-filter-container filter-accordion mb-4 pb-2',
            price_title: 'font-weight-bold mb-4 font-body',
            price_submit: 'btn btn-default d-inline-block',
            price_title: 'h2 font-extra-large mb-4',
            price_submit: 'btn btn-default btn-small'
          },
        }) 
      }}
    {% endif %}
  </div>
{% endif %}