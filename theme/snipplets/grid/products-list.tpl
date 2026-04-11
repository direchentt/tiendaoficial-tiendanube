{% set list_data_store = template == 'category' ? 'category-grid-' ~ category.id : 'search-grid' %}
{% set noFilterResult = "No tenemos resultados para tu búsqueda. Por favor, intentá con otros filtros." %}

{% if products %}
<div class="col" data-store={{ list_data_store }}>
{% endif %}
  {% if products %}
    <div class="js-product-table row row-grid">
      {% include 'snipplets/product_grid.tpl' %}
    </div>
    {% set pagination_type_val = (settings.pagination == 'infinite') %}
    {% include "snipplets/grid/pagination.tpl" with { infinite_scroll: pagination_type_val } %}
  {% else %}
    {% set empty_message_classes = has_applied_filters or template == 'category' ? "font-big py-5 text-center" : "my-4" %}
    <div class="{{ empty_message_classes }}" data-component="filter.message">
      {% if template =='search' %}
            {{ has_applied_filters and query ? (noFilterResult| translate): ("Escribilo de otra forma y volvé a intentar." | translate) }}
      {% elseif template == 'category' %}
          {{(has_filters_enabled ? noFilterResult : "Próximamente") | translate}}
      {% endif %}
    </div>
  {% endif %}
{% if products %}
</div>
{% endif %}