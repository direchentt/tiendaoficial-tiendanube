{% if products or has_filters_available %}
  {# En móvil el dock (catalog-top-bar) abre los modales; en escritorio con filtros en modal el trigger vive en catalog-top-bar (una sola barra con pastillas de orden). #}
  {% set _filters_modal_desktop = settings.filters_desktop_modal | default(false) %}
  <section class="js-category-controls category-controls visible-when-content-ready {% if _filters_modal_desktop %}d-none d-md-block{% if products and has_filters_available %} category-controls--toolbar-inline-md{% endif %}{% else %}d-none{% endif %}">
    <div class="container-fluid category-controls-container">
      <div class="category-controls-row py-3 py-md-0">
        {% if products and not has_filters_available %}
          <div class="category-control-item">
            <a href="#" role="button" class="js-modal-open btn-link text-transform{% if _filters_modal_desktop %} d-md-none{% endif %}" data-toggle="#sort-by" aria-haspopup="dialog">
              {{ 'Ordenar' | t }}
            </a>
            {% embed "snipplets/modal.tpl" with{modal_id: 'sort-by', modal_class: 'bottom modal-centered modal-bottom-sheet modal-right-md', modal_position: 'bottom', modal_position_desktop: 'right', modal_width: 'docked-md', modal_transition: 'slide', modal_header_title: true} %}
              {% block modal_body %}
                {{ component(
                  'sort-by',{
                    list: true,
                    sort_by_classes: {
                      group: 'filter-accordion filter-accordion--catalog-sort',
                      list_title: 'h1 font-huge mb-0',
                      list: 'radio-button-container list-unstyled my-3',
                      list_item: 'radio-button-item',
                      radio_button: "radio-button",
                      radio_button_content: "radio-button-content",
                      radio_button_icons_container: "radio-button-icons-container",
                      radio_button_icon: "radio-button-icon",
                      radio_button_label: "radio-button-label",
                      applying_feedback_message: 'font-big mr-2',
                      applying_feedback_icon: 'icon-inline font-big icon-spin svg-icon-text',
                    },
                    applying_feedback_svg_id: 'spinner-third',
                  }) 
                }}
              {% endblock %}
            {% endembed %}
          </div>
        {% endif %}
        {% if products and has_filters_available %}
          <div class="visible-when-content-ready category-control-item">
            <a href="#" role="button" class="js-modal-open{% if _filters_modal_desktop %} d-md-none{% endif %}" data-toggle="#nav-filters" data-component="filter-button" aria-haspopup="dialog">
              <span class="btn-link text-transform mr-1">{{ 'Filtrar y ordenar' | t }}</span>
              {% if has_applied_filters %}
                (<span class="js-filters-total-badge"></span>)
              {% endif %}
            </a>
            {% embed "snipplets/modal.tpl" with{modal_id: 'nav-filters', modal_class: 'filters modal-docked-md', modal_body_class: 'h-100 p-0', modal_position: 'right', modal_position_desktop: 'right', modal_transition: 'slide', modal_header_title: true, modal_width: 'docked-md' } %}
              {% block modal_body %}
                {% if has_filters_available %}
                  {{ component(
                    'filters/remove-filters',{
                      container_classes: {
                        filters_container: "px-3 mt-4 mb-2",
                      },
                      filter_classes: {
                        applied_filters_label: "font-body font-weight-bold mb-2",
                        remove: "chip",
                        remove_icon: "js-remove-filter-chip chip-remove-icon",
                        remove_all: "btn-link d-inline-block mt-1 mt-md-0 font-small",
                      },
                      remove_filter_svg_id: 'times',
                    }) 
                  }}
                {% endif %}
                {{ component(
                  'sort-by',{
                    accordion: true,
                    list: true,
                    sort_methods: sort_methods,
                    sort_by: sort_by,
                    accordion_classes: {
                      title_container: "row no-gutters align-items-center",
                      title_col: "col my-1 pr-3 d-flex align-items-center",
                      title: "h1 font-huge mb-0",
                      actions_col: "col-auto my-1",
                      title_icon: "icon-inline svg-icon-text icon-xs mr-1"
                    },
                    sort_by_classes: {
                      group: 'filter-accordion filter-accordion--catalog-sort',
                      list: 'radio-button-container list-unstyled my-3',
                      list_item: 'radio-button-item',
                      radio_button: "radio-button",
                      radio_button_content: "radio-button-content",
                      radio_button_icons_container: "radio-button-icons-container",
                      radio_button_icon: "radio-button-icon",
                      radio_button_label: "radio-button-label",
                      applying_feedback_message: 'font-big mr-2',
                      applying_feedback_icon: 'icon-inline font-big icon-spin svg-icon-text',
                    },
                    accordion_show_svg_id: 'chevron',
                    accordion_hide_svg_id: 'chevron-down',
                    applying_feedback_svg_id: 'spinner-third',
                  }) 
                }}
                <div class="js-sorting-overlay filters-overlay" style="display: none;">
                  <div class="filters-updating-message">
                    <span class="h5 mr-2">{{ 'Ordenando productos' | translate }}</span>
                    <span>
                      <svg class="icon-inline h5 icon-spin svg-icon-text"><use xlink:href="#spinner-third"/></svg>
                    </span>
                  </div>
                </div>
                {% if has_filters_available %}

                  {{ component(
                    'filters/filters',{
                      accordion: true,
                      parent_category_link: false,
                      applied_filters_badge: true,
                      container_classes: {
                        filters_container: "visible-when-content-ready",
                      },
                      accordion_classes: {
                        title_container: "row no-gutters align-items-center",
                        title_col: "col my-1 pr-3 d-flex align-items-center",
                        title: "h1 font-huge mb-0",
                        actions_col: "col-auto my-1",
                        title_icon: "icon-inline svg-icon-text icon-xs mr-1"
                      },
                      filter_classes: {
                        list: "list-unstyled my-3",
                        list_item: "mb-2",
                        list_link: "font-small",
                        badge: "h1 ml-1",
                        show_more_link: "d-inline-block btn-link font-small mt-1",
                        checkbox_last: "m-0",
                        price_group: 'price-filter-container filter-accordion',
                        price_title: 'h1 font-huge mb-4',
                        price_submit: 'btn btn-default d-inline-block',
                        applying_feedback_message: 'font-big mr-2',
                        applying_feedback_icon: 'icon-inline font-big icon-spin svg-icon-text'
                      },
                      accordion_show_svg_id: 'chevron',
                      accordion_hide_svg_id: 'chevron-down',
                      applying_feedback_svg_id: 'spinner-third'
                    }) 
                  }}

                {% endif %}
              {% endblock %}
            {% endembed %}
          </div>
        {% endif %}
      </div>
    </div>
  </section>
  <section class="js-category-controls-prev category-controls-sticky-detector"></section>
{% endif %}