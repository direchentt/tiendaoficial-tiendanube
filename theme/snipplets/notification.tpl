{# Cookie validation #}

{% if show_cookie_banner and not params.preview %}
    <div class="js-notification js-notification-cookie-banner notification notification-fixed-bottom notification-primary text-left" style="display: none;">
        {{ 'Al navegar por este sitio <strong>aceptás el uso de cookies</strong> para agilizar tu experiencia de compra.' | translate }}
        <a href="#" class="js-notification-close js-acknowledge-cookies btn btn-link pt-1 pl-1 d-inline-block" data-amplitude-event-name="cookie_banner_acknowledge_click">{{ "Entendido" | translate }}</a>
    </div>
{% endif %}

{% if order_notification and status_page_url_notification %}
    <div class="js-notification js-notification-status-page notification notification-primary notification-order notification-fixed" style="display:none;" data-url="{{ status_page_url_notification }}">
        <div class="font-body">
            <a class="mr-4 d-block" href="{{ status_page_url_notification }}"><span class="btn-link">{{ "Seguí acá" | translate }}</span> {{ "tu última compra" | translate }}</a>
            <a class="js-notification-close js-notification-status-page-close notification-close" href="#">
                <svg class="icon-inline icon-2x"><use xlink:href="#times"/></svg>
            </a>
        </div>
    </div>
{% endif %}
{% if add_to_cart %}
    {% include "snipplets/notification-cart.tpl" %}
{% endif %}
