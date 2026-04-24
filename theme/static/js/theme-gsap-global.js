/**
 * GSAP global (Tiendanube): ScrollTrigger + reveals suaves en grillas.
 * Requiere gsap.min.js y ScrollTrigger.min.js (CDN en layout.tpl).
 * API: window.themeGsap.refresh() tras filtros / infinite scroll / modales que muevan layout.
 */
(function () {
  "use strict";

  function whenGsapReady(cb) {
    if (typeof window.gsap !== "undefined" && typeof window.ScrollTrigger !== "undefined") {
      cb();
      return;
    }
    var n = 0;
    var id = setInterval(function () {
      n += 1;
      if (typeof window.gsap !== "undefined" && typeof window.ScrollTrigger !== "undefined") {
        clearInterval(id);
        cb();
      } else if (n > 160) {
        clearInterval(id);
      }
    }, 32);
  }

  function prefersReducedMotion() {
    return window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  }

  var CARD_SEL =
    ".theme-brand-phase1.template-category .item-product, .theme-brand-phase1.template-search .item-product";

  function init() {
    if (prefersReducedMotion()) {
      window.themeGsap = { refresh: function () {}, disabled: true };
      return;
    }

    var gsap = window.gsap;
    var ScrollTrigger = window.ScrollTrigger;
    gsap.registerPlugin(ScrollTrigger);

    function bindProductCardReveal() {
      var pending = gsap.utils.toArray(CARD_SEL).filter(function (el) {
        return el.getAttribute("data-gsap-reveal-bound") !== "1";
      });
      if (!pending.length) {
        return;
      }
      pending.forEach(function (el) {
        el.setAttribute("data-gsap-reveal-bound", "1");
      });
      ScrollTrigger.batch(pending, {
        start: "top 92%",
        once: true,
        onEnter: function (batch) {
          gsap.from(batch, {
            autoAlpha: 0.92,
            y: 16,
            duration: 0.44,
            stagger: 0.04,
            ease: "power2.out",
            overwrite: "auto",
            clearProps: "opacity,transform"
          });
        }
      });
      requestAnimationFrame(function () {
        try {
          ScrollTrigger.refresh();
        } catch (e) {}
      });
    }

    bindProductCardReveal();

    if (typeof MutationObserver !== "undefined") {
      var debounceT;
      document.querySelectorAll(".theme-brand-phase1 .js-product-table").forEach(function (tbl) {
        var mo = new MutationObserver(function () {
          clearTimeout(debounceT);
          debounceT = setTimeout(function () {
            bindProductCardReveal();
          }, 60);
        });
        mo.observe(tbl, { childList: true, subtree: true });
      });
    }

    function refresh() {
      try {
        ScrollTrigger.refresh();
      } catch (e) {}
    }

    window.themeGsap = {
      refresh: refresh,
      bindProductCardReveal: bindProductCardReveal,
      gsap: function () {
        return window.gsap;
      },
      ScrollTrigger: function () {
        return window.ScrollTrigger;
      }
    };

    window.addEventListener("load", function () {
      requestAnimationFrame(refresh);
    });

    var resizeTimer;
    window.addEventListener(
      "resize",
      function () {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(refresh, 180);
      },
      { passive: true }
    );
  }

  whenGsapReady(function () {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", init);
    } else {
      init();
    }
  });
})();
