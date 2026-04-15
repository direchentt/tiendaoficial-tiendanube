{# Puente PDP: sincroniza miniaturas con Swiper sin tocar store.js (solo cuando hay thumbs en DOM). #}
<script>
(function () {
  function syncPdpThumbs(root, activeIndex) {
    root.querySelectorAll('.js-pdp-thumb-btn').forEach(function (btn) {
      var idx = parseInt(btn.getAttribute('data-slide-index'), 10);
      var on = idx === activeIndex;
      btn.classList.toggle('is-active', on);
      btn.setAttribute('aria-pressed', on ? 'true' : 'false');
    });
  }

  function attach(root) {
    if (root.getAttribute('data-pdp-thumbs-bound') === '1') {
      return true;
    }
    if (!root.querySelector('.js-pdp-thumb-btn')) {
      return true;
    }
    var swiperEl = root.querySelector('.js-swiper-product');
    if (!swiperEl || !swiperEl.swiper) {
      return false;
    }
    var sw = swiperEl.swiper;
    function onSlideChange() {
      syncPdpThumbs(root, sw.activeIndex);
    }
    sw.on('slideChange', onSlideChange);
    syncPdpThumbs(root, sw.activeIndex);
    root.querySelectorAll('.js-pdp-thumb-btn').forEach(function (btn) {
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        var idx = parseInt(btn.getAttribute('data-slide-index'), 10);
        if (!isNaN(idx)) {
          sw.slideTo(idx);
        }
      });
    });
    root.setAttribute('data-pdp-thumbs-bound', '1');
    return true;
  }

  function tryAll() {
    var roots = document.querySelectorAll('.pdp-gallery-root');
    var pending = false;
    roots.forEach(function (root) {
      if (!root.querySelector('.js-pdp-thumb-btn')) {
        return;
      }
      if (!attach(root)) {
        pending = true;
      }
    });
    return pending;
  }

  function schedule() {
    if (!tryAll()) {
      return;
    }
    if (schedule.attempts >= 120) {
      return;
    }
    schedule.attempts += 1;
    setTimeout(schedule, 50);
  }
  schedule.attempts = 0;

  if (typeof LS !== 'undefined' && LS.ready) {
    LS.ready.then(function () {
      setTimeout(schedule, 0);
    });
  } else if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      setTimeout(schedule, 0);
    });
  } else {
    setTimeout(schedule, 0);
  }
})();
</script>
