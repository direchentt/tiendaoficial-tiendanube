<style>
    .home-popup-wrapper {
        display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 99999;
        align-items: center; justify-content: center; background: rgba(0,0,0,0.6);
        opacity: 0; transition: opacity 0.3s ease; backdrop-filter: blur(5px);
    }
    .home-popup-wrapper.modal-show { display: flex !important; opacity: 1; }
    .home-popup-glass-content {
        position: relative; background: rgba(60, 70, 85, 0.3); backdrop-filter: blur(25px) saturate(1.2); -webkit-backdrop-filter: blur(25px) saturate(1.2); border: 1px solid rgba(255, 255, 255, 0.15); border-radius: 20px; box-shadow: rgba(0, 0, 0, 0.2) 0px 20px 50px 0px, rgba(255, 255, 255, 0.4) 0px 1px 2px 0px inset; display: flex; max-width: 750px; width: 92%; overflow: hidden;
    }
    .home-popup-wrapper input[type="email"]::placeholder { color: rgba(255,255,255,0.5); }
    .home-popup-glass-img { flex: 1; min-width: 300px; display: none; }
    @media (min-width: 768px) {
        .home-popup-glass-img { display: block; }
    }
</style>

<div id="home-modal" class="js-modal home-popup-wrapper">
    <div class="home-popup-glass-content">
        <a href="#" class="js-modal-close" style="position: absolute; top: 15px; right: 15px; color: #fff; text-decoration: none; font-size: 24px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; background: rgba(255,255,255,0.15); border-radius: 50%; z-index: 10;">
            &times;
        </a>

        <div class="home-popup-glass-text" style="flex: 1; padding: 40px; display: flex; flex-direction: column; justify-content: center;">
            <h2 style="color: #fff; font-size: 1.8rem; font-weight: 500; margin-bottom: 20px; line-height: 1.2;">
                <span style="color: #22c55e;">●</span> {{ settings.home_popup_title | default('10% off your first order') }}
            </h2>
            
            <div class="d-none d-md-flex flex-wrap mb-4" style="gap: 10px;">
                <span style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: #fff; padding: 5px 12px; border-radius: 20px; font-size: 0.75rem;">Exclusive Discounts</span>
                <span style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: #fff; padding: 5px 12px; border-radius: 20px; font-size: 0.75rem;">Early Access</span>
                <span style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: #fff; padding: 5px 12px; border-radius: 20px; font-size: 0.75rem;">News & Special Contents</span>
            </div>

            {% if settings.home_news_box %}
                <div id="news-popup-form-container">
                    <form method="post" action="/winnie-pooh" class="js-news-form" data-store="newsletter-form-popup">
                        <div class="newsletter-form">
                            <input type="email" name="email" class="js-mandatory-field" placeholder="{{ 'Enter your email' | translate }}" aria-label="{{ 'Email' | translate }}" style="width: 100%; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.25); color: #fff; padding: 12px 20px; border-radius: 30px; margin-bottom: 15px; outline: none;">
                            
                            <div class="winnie-pooh" style="display: none;">
                                <label for="winnie-pooh-newsletter">{{ "No completar este campo" | translate }}</label>
                                <input id="winnie-pooh-newsletter" type="text" name="winnie-pooh"/>
                            </div>
                            <input type="hidden" name="name" value="{{ "Sin nombre" | translate }}" />
                            <input type="hidden" name="message" value="{{ "Pedido de inscripción a newsletter" | translate }}" />
                            <input type="hidden" name="type" value="newsletter" />
                            
                            <button type="submit" name="contact" class="js-news-popup-submit" style="width: 100%; background: #fff; color: #000; border: none; padding: 12px 20px; border-radius: 30px; font-weight: 500; font-size: 1rem; cursor: pointer; transition: opacity 0.2s;">
                                {{ settings.home_popup_btn | default('Get 10% off!') }}
                            </button>
                            <span class="js-news-spinner" style="display: none; text-align: center; color: #fff; width: 100%; padding: 10px 0;">
                                <svg class="icon-inline icon-spin"><use xlink:href="#spinner-third"/></svg>
                            </span>
                        </div>
                    </form>
                    <div class="js-news-popup-success alert alert-success mt-3 mb-0" style="display: none; border-radius: 10px;">{{ "¡Gracias por suscribirte!" | translate }}</div>
                    <div class="js-news-popup-failed alert alert-danger mt-3 mb-0" style="display: none; border-radius: 10px;">{{ "Necesitamos tu email." | translate }}</div>
                </div>
            {% endif %}
            
            <p class="d-none d-md-block" style="color: rgba(255,255,255,0.4); font-size: 0.65rem; margin-top: 25px; margin-bottom: 0; text-transform: uppercase; letter-spacing: 0.05em;">® {{ store.name }}</p>
        </div>

        {% if "home_popup_image.jpg" | has_custom_image %}
            <div class="home-popup-glass-img">
                <img src="{{ 'home_popup_image.jpg' | static_url }}" style="width: 100%; height: 100%; object-fit: cover;" alt="Newsletter" />
            </div>
        {% endif %}
    </div>
</div>