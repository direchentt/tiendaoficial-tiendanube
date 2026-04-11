{% if settings.show_instafeed and store.instagram and store.hasInstagramToken() %}
    <section class="section-home section-instafeed-home overflow-none py-2 py-md-4" data-store="home-instagram-feed">
        <div class="container-fluid">
            <div class="row">
                {% set instuser = store.instagram|split('/')|last %}
                <div class="col-md-3 py-3">
                    <a target="_blank" rel="noopener noreferrer" href="{{ store.instagram }}" class="instafeed-title mb-0" aria-label="{{ 'Abrir en una nueva pestaña el Instagram de' | translate }} {{ store.name }}">
                        <h2 class="h3-huge h2-huge-md section-title mb-0">@{{ instuser }}</h2>
                        <p class="btn-link text-transform mt-2 mb-0">{{ 'Seguinos en Instagram' | translate }}</p>
                    </a>
                </div>
                <div class="col-md-9 pr-0 px-md-3">
                    {% if store.hasInstagramToken() %}
                        <div class="js-ig-success js-swiper-instafeed swiper-container">
                            <div class="swiper-wrapper"
                                data-ig-feed
                                data-ig-items-count="6"
                                data-ig-item-class="swiper-slide"
                                data-ig-link-class="instafeed-link m-md-0"
                                data-ig-image-class="instafeed-img w-100 fade-in"
                                data-ig-aria-label="{{ 'Publicación de Instagram de' | translate }} {{ store.name }}"
                                style="display: none;">
                            </div>
                        </div>
                    {% endif %}
                </div>
            </div>
        </div>
    </section>
{% endif %}