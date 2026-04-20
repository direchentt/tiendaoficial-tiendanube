{% if settings.benefit_bar_enabled %}
<style>
.benefit-prog-wrap {
    padding: 10px 15px 30px;
    background: transparent;
    margin-bottom: 10px;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
}
.benefit-prog-title {
    text-align: center;
    font-size: 1rem;
    font-weight: 400;
    margin-bottom: 25px;
    color: #000;
    letter-spacing: -0.01em;
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
    border: 2.5px solid #888;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-size: 0.65rem;
    font-weight: 600;
    letter-spacing: 0.02em;
    padding: 4px;
    line-height: 1.15;
    transition: border-color 0.4s ease, color 0.4s ease;
    z-index: 2;
    min-width: 60px;
    height: 56px;
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
    margin-top: 10px;
    font-size: 0.85rem;
    color: #000;
    font-weight: 600;
    white-space: nowrap;
}
</style>

<div class="benefit-prog-wrap js-benefit-bar" 
     data-fs-min="{{ settings.benefit_bar_fs_min | default('80000') | escape }}" 
     data-inst-min="{{ settings.benefit_bar_inst_min | default('150000') | escape }}"
     data-inst-lbl="{{ settings.benefit_bar_inst_amount | default('6 CUOTAS') | escape }}">
     
    <div class="benefit-prog-title js-benefit-bar-text">
        <!-- JS fills this -->
    </div>
    
    <div class="benefit-prog-track">
        <div class="benefit-prog-fill js-benefit-bar-fill" style="width: 0%; max-width: calc(100% - 3px);"></div>
        
        <div class="benefit-prog-node js-benefit-fs-marker">
            <span style="display:block;">ENVÍO<br>GRATIS</span>
            <div class="benefit-prog-amount js-benefit-fs-val">$80.000</div>
        </div>
        
        <div class="benefit-prog-node js-benefit-inst-marker">
            <span class="js-benefit-inst-text" style="display:block;">{{ settings.benefit_bar_inst_amount | default('6 CUOTAS') | replace({' ': '<br>'}) | raw }}</span>
            <div class="benefit-prog-amount js-benefit-inst-val">$150.000</div>
        </div>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const barContainers = document.querySelectorAll('.js-benefit-bar');
        if (!barContainers.length) return;
        
        function formatMoney(amount) {
            return "$" + Math.round(amount).toLocaleString('es-AR');
        }

        function updateBenefitBars() {
            let subtotal = 0;
            if (window.LS && LS.cart && LS.cart.subtotal) {
                subtotal = LS.cart.subtotal;
            } else if (document.querySelector('.js-cart-subtotal')) {
                let txt = document.querySelector('.js-cart-subtotal').textContent.replace(/\D/g,'');
                if (txt) subtotal = parseInt(txt);
            }

            if (subtotal === 0) {
               let $pdpPrice = document.querySelector('.js-price-display[content]');
               if ($pdpPrice) {
                   subtotal = parseFloat($pdpPrice.getAttribute('content'));
               }
            }
            if (isNaN(subtotal)) subtotal = 0;
            
            barContainers.forEach(container => {
                const fsMinStr = container.getAttribute('data-fs-min').replace(/\D/g,'');
                const instMinStr = container.getAttribute('data-inst-min').replace(/\D/g,'');
                
                let fsMin = fsMinStr ? parseInt(fsMinStr) : 80000;
                let instMin = instMinStr ? parseInt(instMinStr) : 150000;
                let instLbl = container.getAttribute('data-inst-lbl') || '6 CUOTAS';
                
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
            let currentSub = (window.LS && LS.cart && typeof LS.cart.subtotal !== 'undefined') ? LS.cart.subtotal : -2;
            if (currentSub !== lastSubtotal) {
                lastSubtotal = currentSub;
                updateBenefitBars();
            }
        }, 800);
    });
</script>
{% endif %}
