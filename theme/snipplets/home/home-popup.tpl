{% if settings.roulette_enable %}
<style>
    .roulette-wrapper {
        display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 99999;
        align-items: center; justify-content: center; background: rgba(0,0,0,0.7);
        opacity: 0; transition: opacity 0.3s ease; backdrop-filter: blur(5px);
    }
    .roulette-wrapper.modal-show { display: flex !important; opacity: 1; }
    .roulette-content {
        position: relative; background: #fff; border-radius: 20px; box-shadow: 0 20px 50px rgba(0,0,0,0.2); 
        display: flex; flex-direction: column; max-width: 420px; width: 92%; overflow: hidden; padding: 35px 25px; text-align: center;
    }
    .roulette-wheel-container {
        position: relative; width: 280px; height: 280px; margin: 0 auto 20px;
    }
    .roulette-wheel {
        position: absolute; width: 100%; height: 100%; border-radius: 50%;
        background: conic-gradient(from -30deg, #f8fafc 0deg 60deg, #f1f5f9 60deg 120deg, #e2e8f0 120deg 180deg, #cbd5e1 180deg 240deg, #e2e8f0 240deg 300deg, #f1f5f9 300deg 360deg);
        overflow: hidden; border: 4px solid #fff; box-shadow: 0 5px 15px rgba(0,0,0,0.15);
        transition: transform 4s cubic-bezier(0.1, 0.9, 0.2, 1);
    }
    .roulette-slice-text {
        position: absolute; width: 130px; height: 30px; left: 140px; top: 140px; transform-origin: 0 15px; 
        display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 14px; color: #1e293b;
    }
    .roulette-pointer {
        position: absolute; top: -15px; left: 50%; transform: translateX(-50%);
        width: 0; height: 0; border-left: 18px solid transparent; border-right: 18px solid transparent;
        border-top: 35px solid #ef4444; z-index: 10; filter: drop-shadow(0 4px 4px rgba(0,0,0,0.3));
    }
</style>

<div id="home-modal" class="js-modal roulette-wrapper">
    <div class="roulette-content">
        <a href="#" class="js-modal-close" style="position: absolute; top: 15px; right: 15px; color: #aaa; text-decoration: none; font-size: 28px; z-index: 10;">&times;</a>
        
        <h2 style="font-size: 1.6rem; font-weight: 800; margin-bottom: 10px; color: #111; letter-spacing: -0.5px;">{{ settings.roulette_title | default('¡Girada de la Suerte!') }}</h2>
        <p style="font-size: 0.9rem; color: #666; margin-bottom: 25px; line-height: 1.4;">{{ settings.roulette_txt | default('Ingresá tu email para jugar y ganar premios exclusivos.') }}</p>

        <div class="roulette-wheel-container">
            <div class="roulette-pointer"></div>
            <div class="roulette-wheel" id="js-roulette-wheel">
                {% for i in 1..6 %}
                    {% set slice_val = attribute(settings, 'roulette_slice_' ~ i) | default(i * 5 ~ '% OFF') %}
                    <div class="roulette-slice-text" style="transform: rotate({{ (i - 1) * 60 - 90 }}deg) translateX(30px);">
                        {{ slice_val }}
                    </div>
                {% endfor %}
            </div>
        </div>

        <div id="js-roulette-form-view">
            <form id="js-roulette-form" method="post" action="/winnie-pooh">
                <input type="email" name="email" required placeholder="{{ 'Tu mejor email' | translate }}" style="width: 100%; border: 2px solid #e2e8f0; padding: 14px; border-radius: 10px; margin-bottom: 15px; outline: none; font-size: 1rem;">
                
                <div class="winnie-pooh" style="display: none;"><input id="winnie-pooh-newsletter" type="text" name="winnie-pooh"/></div>
                <input type="hidden" name="name" value="Jugador Ruleta" />
                <input type="hidden" name="message" value="Participación en Ruleta" />
                <input type="hidden" name="type" value="newsletter" />
                
                <button type="submit" class="js-roulette-btn" style="width: 100%; background: #000; color: #fff; border: none; padding: 14px; border-radius: 10px; font-weight: 800; font-size: 1rem; cursor: pointer; text-transform: uppercase; letter-spacing: 1px;">
                    Girar Ruleta
                </button>
                <div class="js-roulette-spinner" style="display: none; padding: 10px 0;">
                    <svg class="icon-inline icon-spin" style="width:24px;height:24px;"><use xlink:href="#spinner-third"/></svg>
                </div>
            </form>
        </div>

        <div id="js-roulette-success-view" style="display: none;">
            <h3 style="font-size: 1.6rem; color: #22c55e; font-weight: 800; margin-bottom: 10px;">¡Felicidades!</h3>
            
            {% if settings.roulette_prize_type == 'product' %}
                <p style="font-size: 0.95rem; color: #333; margin-bottom: 15px;">Tu premio exclusivo se está añadiendo a tu carrito automáticamente.</p>
                <div style="background: #f8fafc; border: 2px dashed #94a3b8; padding: 15px; border-radius: 10px; font-weight: 800; font-size: 1.2rem; color: #0f172a; margin-bottom: 20px;">
                    🎁 Producto Gratis en Carrito
                </div>
            {% elseif settings.roulette_prize_type == 'vip' %}
                <p style="font-size: 0.95rem; color: #333; margin-bottom: 15px;">Acá tenés la clave secreta para acceder a nuestra Colección VIP exclusiva.</p>
                <div style="background: #f8fafc; border: 2px dashed #94a3b8; padding: 15px; border-radius: 10px; font-weight: 800; font-size: 1.4rem; letter-spacing: 2px; color: #0f172a; margin-bottom: 20px;">
                    {{ settings.vip_category_password | default('CLAVEVIP') }}
                </div>
            {% else %}
                <p style="font-size: 0.95rem; color: #333; margin-bottom: 15px;">Acá tenés tu código de descuento. Aplicalo en el carrito de compras.</p>
                <div style="background: #f8fafc; border: 2px dashed #94a3b8; padding: 15px; border-radius: 10px; font-weight: 800; font-size: 1.4rem; letter-spacing: 2px; color: #0f172a; margin-bottom: 20px;">
                    {{ settings.roulette_winning_code | default('PROMO10') }}
                </div>
            {% endif %}
            
            <a href="#" class="js-modal-close" style="display: block; width: 100%; background: #000; color: #fff; padding: 14px; border-radius: 10px; font-weight: 800; text-decoration: none; text-transform: uppercase;">Aceptar Premio</a>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var form = document.getElementById('js-roulette-form');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            var btn = form.querySelector('.js-roulette-btn');
            var spinner = form.querySelector('.js-roulette-spinner');
            btn.style.display = 'none';
            spinner.style.display = 'block';

            var formData = new FormData(form);
            fetch('/winnie-pooh', {
                method: 'POST',
                body: formData
            }).then(function() {
                var winningSlice = {{ settings.roulette_winning_slice | default(1) }};
                var baseRotation = 360 * 5; 
                var sliceOffset = 360 - ((winningSlice - 1) * 60);
                var randomOffset = Math.floor(Math.random() * 30) - 15;
                var totalRotation = baseRotation + sliceOffset + randomOffset;

                document.getElementById('js-roulette-wheel').style.transform = 'rotate(' + totalRotation + 'deg)';
                
                setTimeout(function() {
                    document.getElementById('js-roulette-form-view').style.display = 'none';
                    document.getElementById('js-roulette-success-view').style.display = 'block';
                    
                    {% if settings.roulette_prize_type == 'product' and settings.roulette_winning_url %}
                    // Magic: Fetch product page, extract variant_id, and silently add to cart
                    fetch('{{ settings.roulette_winning_url }}')
                        .then(function(res) { return res.text(); })
                        .then(function(html) {
                            var match = html.match(/name="variant_id" value="(\d+)"/);
                            if (match && match[1] && window.LS && window.LS.Cart) {
                                window.LS.Cart.addItem({ variant_id: match[1], quantity: 1 });
                            }
                        })
                        .catch(function(e) { console.warn('Roulette auto-add error', e); });
                    {% endif %}
                }, 4200);
            }).catch(function() {
                btn.style.display = 'block';
                spinner.style.display = 'none';
                alert('Hubo un error. Intentá nuevamente.');
            });
        });
    }
});
</script>
{% else %}
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
{% endif %}