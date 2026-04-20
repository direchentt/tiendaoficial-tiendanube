{% set show_benefit_bar = false %}
{% if context == 'cart' and settings.benefit_bar_cart_enabled %}
  {% set show_benefit_bar = true %}
{% elseif context == 'pdp' and settings.benefit_bar_pdp_enabled %}
  {% set show_benefit_bar = true %}
{% endif %}

{% if show_benefit_bar %}

{# Extraer el monto de envío gratis directamente desde la tienda para que sea automático #}
{% set dynamic_fs_min_raw = cart.free_shipping.min_price_free_shipping.min_price_raw | default(0) %}
{% set dynamic_fs_min = dynamic_fs_min_raw > 0 ? (dynamic_fs_min_raw / 100) : 0 %}
{% set manual_fs_min = settings.benefit_bar_fs_min | default('80000') %}
{% set final_fs_min = dynamic_fs_min > 0 ? dynamic_fs_min : manual_fs_min %}

<style>
.benefit-prog-wrap {
    padding: 15px 5px 40px 5px; /* Más espacio abajo para los montos y costados para alinear */
    margin-bottom: 20px;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    width: 100%;
}
.benefit-prog-title {
    text-align: center;
    font-size: 1rem;
    font-weight: 400;
    margin-bottom: 25px;
    color: #000;
    letter-spacing: -0.01em;
}
.benefit-prog-inner {
    position: relative;
    padding: 0 35px; /* Margen horizontal para que los globos no toquen el borde de la pantalla */
}
.benefit-prog-track {
    position: relative;
    width: 100%;
    height: 18px;
    border: 1.5px solid #000;
    border-radius: 10px;
    background: transparent;
}
.benefit-prog-fill {
    position: absolute;
    top: 1.5px;
    left: 1.5px;
    height: 12px;
    background: #000;
    border-radius: 20px;
    transition: width 0.4s ease-out;
}
.benefit-prog-node {
    position: absolute;
    top: 50%;
    transform: translate(-50%, -50%);
    background: #fff;
    border: 1.5px solid #888;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.02em;
    padding: 2px 5px;
    line-height: 1.15;
    transition: border-color 0.4s ease, color 0.4s ease;
    z-index: 2;
    min-width: 55px;
    height: 48px;
    color: #000;
}
.benefit-prog-node.reached {
    border-color: #000;
}
.benefit-prog-amount {
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-top: 12px;
    font-size: 13px;
    color: #000;
    font-weight: 600;
    white-space: nowrap;
}
</style>

<div class="benefit-prog-wrap js-benefit-bar" 
     data-fs-min="{{ final_fs_min | escape }}" 
     data-inst-min="{{ settings.benefit_bar_inst_min | default('150000') | escape }}"
     data-inst-lbl="{{ settings.benefit_bar_inst_amount | default('3 cuotas sin interés') | escape }}">
     
    <div class="benefit-prog-title js-benefit-bar-text">
        <!-- JS fills this -->
    </div>
    
    <div class="benefit-prog-inner">
        <div class="benefit-prog-track">
            <div class="benefit-prog-fill js-benefit-bar-fill" style="width: 0%; max-width: calc(100% - 3px);"></div>
            
            <div class="benefit-prog-node js-benefit-inst-marker">
                <span class="js-benefit-inst-text" style="display:block; max-width: 50px; white-space: normal;">{{ settings.benefit_bar_inst_amount | default('3 cuotas sin interés') }}</span>
                <div class="benefit-prog-amount js-benefit-inst-val">$0</div>
            </div>

            <div class="benefit-prog-node js-benefit-fs-marker">
                <span style="display:block;">ENVÍO<br>GRATIS</span>
                <div class="benefit-prog-amount js-benefit-fs-val">$0</div>
            </div>
            
        </div>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        if (window.benefitBarInitialized) return;
        window.benefitBarInitialized = true;

        const formatMoney = function(amount) {
            let n = parseFloat(amount);
            if (isNaN(n)) return "$0";
            return "$" + Math.round(n).toLocaleString('es-AR');
        };

        function getLiveSubtotal() {
            let $node = document.querySelector('.js-cart-subtotal');
            if ($node) {
                let text = $node.textContent;
                // Si viene como $ 120.000,00 nos quedamos con la parte antes de la coma
                let intPart = text.split(',')[0].replace(/\D/g, '');
                if (intPart) return parseInt(intPart);
            }
            // Fallback para página de producto (cuando el carrito recién se abrio o está vacío)
            let $pdpPrice = document.querySelector('.js-price-display[content]');
            if ($pdpPrice) {
               return parseFloat($pdpPrice.getAttribute('content')) || 0;
            }
            return 0;
        }

        function updateBenefitBars() {
            let subtotal = getLiveSubtotal();
            
            const barContainers = document.querySelectorAll('.js-benefit-bar');
            barContainers.forEach(container => {
                const fsMinStr = container.getAttribute('data-fs-min').replace(/\D/g,'');
                const instMinStr = container.getAttribute('data-inst-min').replace(/\D/g,'');
                
                let fsMin = fsMinStr ? parseInt(fsMinStr) : 80000;
                let instMin = instMinStr ? parseInt(instMinStr) : 150000;
                let instLbl = container.getAttribute('data-inst-lbl') || '3 cuotas sin interés';
                
                let milestones = [
                    { name: 'fs', val: fsMin, lbl: 'Envío Gratis', short: 'envío gratuito' },
                    { name: 'inst', val: instMin, lbl: instLbl, short: instLbl.toLowerCase() }
                ].sort((a,b) => a.val - b.val);
                
                let m1 = milestones[0];
                let m2 = milestones[1];
                let max = m2.val > 0 ? m2.val : m1.val;
                if (!max) return;
                
                const $m1 = container.querySelector('.js-benefit-' + m1.name + '-marker');
                const $m2 = container.querySelector('.js-benefit-' + m2.name + '-marker');
                
                let pct1 = Math.min((m1.val / max) * 100, 100);
                let pct2 = Math.min((m2.val / max) * 100, 100);
                
                if ($m1) $m1.style.left = pct1 + '%';
                if ($m2) $m2.style.left = pct2 + '%';
                
                if ($m1) container.querySelector('.js-benefit-' + m1.name + '-val').textContent = formatMoney(m1.val);
                if ($m2) container.querySelector('.js-benefit-' + m2.name + '-val').textContent = formatMoney(m2.val);
                
                const $text = container.querySelector('.js-benefit-bar-text');
                const $fill = container.querySelector('.js-benefit-bar-fill');
                
                let fillPct = (subtotal / max) * 100;
                if (fillPct > 100) fillPct = 100;
                $fill.style.width = 'calc(' + fillPct + '% - 3px)';
                
                if (subtotal >= m2.val) {
                    $text.innerHTML = '¡Ya obtuviste envío gratuito y ' + m2.short + '!';
                    if ($m1) $m1.classList.add('reached');
                    if ($m2) $m2.classList.add('reached');
                } else if (subtotal >= m1.val) {
                    let faltan = m2.val - subtotal;
                    $text.innerHTML = 'Faltan ' + formatMoney(faltan) + ' para obtener ' + m2.short;
                    if ($m1) $m1.classList.add('reached');
                    if ($m2) $m2.classList.remove('reached');
                } else {
                    let faltan = m1.val - subtotal;
                    $text.innerHTML = 'Faltan ' + formatMoney(faltan) + ' para obtener ' + m1.short;
                    if ($m1) $m1.classList.remove('reached');
                    if ($m2) $m2.classList.remove('reached');
                }
            });
        }
        
        updateBenefitBars();
        
        let lastSubtotal = -1;
        setInterval(function() {
            let currentSub = getLiveSubtotal();
            if (currentSub !== lastSubtotal && currentSub > 0) {
                lastSubtotal = currentSub;
                updateBenefitBars();
            }
        }, 800);
    });
</script>
{% endif %}
