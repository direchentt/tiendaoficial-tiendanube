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

{# Color base del administrador #}
{% set bb_color = settings.benefit_bar_color | default('#000000') %}

<style>
.benefit-prog-wrap {
    padding: 10px 5px 35px 5px; 
    margin-bottom: 20px;
    width: 100%;
}
.benefit-prog-title {
    text-align: center;
    font-size: 0.8em;
    font-weight: 500;
    margin-bottom: 20px;
    color: {{ bb_color }};
}
.benefit-prog-inner {
    position: relative;
    padding: 0 40px; 
}
.benefit-prog-track {
    position: relative;
    width: 100%;
    height: 16px;
    border: 1.5px solid {{ bb_color }};
    border-radius: 10px;
    background: transparent;
}
.benefit-prog-fill {
    position: absolute;
    top: 1.5px;
    left: 1.5px;
    height: 10px;
    background: {{ bb_color }};
    border-radius: 20px;
    transition: width 0.4s ease-out;
}
.benefit-prog-node {
    position: absolute;
    top: 50%;
    transform: translate(-50%, -50%);
    background: #fff;
    border: 1.5px solid {{ bb_color }};
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-size: 10px;
    font-weight: 600;
    letter-spacing: 0.02em;
    padding: 2px 4px;
    line-height: 1.1;
    transition: border-color 0.4s ease, color 0.4s ease;
    z-index: 2;
    min-width: 50px;
    height: 44px;
    color: {{ bb_color }};
    opacity: 0.6; /* Slight transparency for unreached */
}
.benefit-prog-node.reached {
    opacity: 1; /* Fully opaque on reach */
}
.benefit-prog-amount {
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-top: 10px;
    font-size: 12px;
    color: {{ bb_color }};
    font-weight: 600;
    white-space: nowrap;
}
</style>

<div class="benefit-prog-wrap js-benefit-bar" 
     data-fs-min="{{ final_fs_min | escape }}" 
     data-inst-min="{{ settings.benefit_bar_inst_min | default('150000') | escape }}"
     data-inst-lbl="{{ settings.benefit_bar_inst_amount | default('3 cuotas sin interés') | escape }}">
     
    <div class="benefit-prog-title js-benefit-bar-text h6">
        <!-- JS fills this -->
    </div>
    
    <div class="benefit-prog-inner">
        <div class="benefit-prog-track">
            <div class="benefit-prog-fill js-benefit-bar-fill" style="width: 0%; max-width: calc(100% - 3px);"></div>
            
            <div class="benefit-prog-node js-benefit-inst-marker">
                <span class="js-benefit-inst-text" style="display:block; max-width: 45px; white-space: normal;">{{ settings.benefit_bar_inst_amount | default('3 cuotas sin interés') }}</span>
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
                let intPart = text.split(',')[0].replace(/\D/g, '');
                if (intPart) return parseInt(intPart);
            }
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
                    { name: 'fs', val: fsMin, lbl: 'Envío Gratis', short: 'envío gratis' },
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
                    $text.innerHTML = '¡Ya alcanzaste cuotas sin interés y envío gratis!';
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
