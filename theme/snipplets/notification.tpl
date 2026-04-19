{# Cookie validation #}

{% if show_cookie_banner and not params.preview %}
    <div class="js-notification js-notification-cookie-banner notification notification-cookie-glass notification-fixed-bottom text-left" style="display: none;">
        <div class="notification-cookie-glass__inner">
            <p class="notification-cookie-glass__text mb-0">{{ 'Al navegar por este sitio <strong>aceptás el uso de cookies</strong> para agilizar tu experiencia de compra.' | translate }}</p>
            <a href="#" class="js-notification-close js-acknowledge-cookies notification-cookie-glass__btn" data-amplitude-event-name="cookie_banner_acknowledge_click">{{ "Entendido" | translate }}</a>
        </div>
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
