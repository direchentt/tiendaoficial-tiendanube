/**
 * Hache Suite — Storefront Engine v2
 * Módulos: CartGift | CategoryGate | DynamicPricing | BundlePage
 *
 * Inyectá este script en tu tema Tiendanube (theme/layouts/layout.html.tpl)
 * antes de </body>:
 *
 *   <script src="{{ static_url('js/hache-suite.js') }}" defer></script>
 *
 * Variables que el tema Tiendanube expone:
 *   LS.store.id       → storeId (tiendanubeUserId)
 *   LS.product.id     → productId en PDP
 *   LS.category.id    → categoryId en PLP
 *   LS.cart           → objeto del carrito
 *
 * Wishlist: requiere cuenta TN; verificacion en backend con API read_customers.
 *
 * CVR (embudo): envía eventos a POST /api/storefront/conversion-events. Desactivar:
 *   window.HACHE_DISABLE_CVR = true;
 */

(function (window) {
  "use strict";

  // ─── CONFIG ────────────────────────────────────────────────────────────────
  const BACKEND_URL = (
    (typeof window.HACHE_BACKEND_URL === "string" && window.HACHE_BACKEND_URL.trim()) ||
    "https://tiendaoficial-tiendanube-production.up.railway.app"
  ).replace(/\/+$/, "");

  /** TN a veces hidrata `LS.store` después del primer paint; no cortar el bundle entero. */
  function getStoreId() {
    var meta =
      typeof document !== "undefined" &&
      document.querySelector('meta[name="hache-store-user-id"]');
    var metaId = meta && meta.getAttribute("content") ? String(meta.getAttribute("content")).trim() : "";
    const id =
      window.LS?.store?.id?.toString() ||
      window.store_id?.toString() ||
      metaId ||
      "";
    return id.trim();
  }

  var HS_CVR = "hs_cvr_";

  function sendConversionEvent(type, extra) {
    if (
      typeof window !== "undefined" &&
      (window.HACHE_DISABLE_CVR === "1" || window.HACHE_DISABLE_CVR === true)
    ) {
      return;
    }
    var sid = getStoreId();
    if (!sid) return;
    var payload = {
      type: type,
      storeId: sid,
      path: (typeof window !== "undefined" && window.location && window.location.pathname) || "",
    };
    if (extra && typeof extra === "object") {
      if (extra.productId != null) payload.productId = extra.productId;
      if (extra.categoryId != null) payload.categoryId = extra.categoryId;
    }
    try {
      fetch(BACKEND_URL + "/api/storefront/conversion-events", {
        method: "POST",
        mode: "cors",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
        keepalive: true,
      }).catch(function () {});
    } catch (_) {}
  }

  /** Una vez por sesión de pestaña (sessionStorage) para vistas de página. */
  function trackConversionPageViewsOnce() {
    try {
      var pt = getCurrentPageType();
      if (pt === "home") {
        if (!sessionStorage.getItem(HS_CVR + "home")) {
          sessionStorage.setItem(HS_CVR + "home", "1");
          sendConversionEvent("home_view", {});
        }
        return;
      }
      if (pt === "category" && window.LS && window.LS.category && window.LS.category.id) {
        var cid = String(window.LS.category.id);
        if (!sessionStorage.getItem(HS_CVR + "cat_" + cid)) {
          sessionStorage.setItem(HS_CVR + "cat_" + cid, "1");
          sendConversionEvent("category_view", { categoryId: window.LS.category.id });
        }
        return;
      }
      if (pt === "product" && window.LS && window.LS.product && window.LS.product.id) {
        var pvId = String(window.LS.product.id);
        if (!sessionStorage.getItem(HS_CVR + "pv_" + pvId)) {
          sessionStorage.setItem(HS_CVR + "pv_" + pvId, "1");
          sendConversionEvent("product_view", { productId: window.LS.product.id });
        }
        return;
      }
      if (pt === "bundle") {
        if (!sessionStorage.getItem(HS_CVR + "bundle")) {
          sessionStorage.setItem(HS_CVR + "bundle", "1");
          sendConversionEvent("bundle_view", {});
        }
      }
    } catch (_) {}
  }

  /** GET/POST wishlist: mismo parseo de JSON + errores que postToggle. */
  async function wishlistRequestJson(url, init) {
    const res = await fetch(url, { mode: "cors", ...init });
    const raw = await res.text();
    let data = {};
    try {
      data = raw ? JSON.parse(raw) : {};
    } catch (_) {
      data = { error: "invalid_response" };
    }
    if (!res.ok) {
      const code =
        typeof data.error === "string" && data.error.trim()
          ? data.error.trim()
          : "http_" + res.status;
      const err = new Error(code);
      err.httpStatus = res.status;
      err.bodyPreview = String(raw).slice(0, 180);
      throw err;
    }
    return data;
  }

  function wishlistUserFacingMessage(code, st, err, opts) {
    const failVerb = (opts && opts.failVerb) || "guardar";
    if (code === "tn_scope") {
      return "El token de la app no puede leer clientes: agregá scope read_customers y volvé a autorizar la app en Tiendanube.";
    }
    if (code === "forbidden") {
      return "El email de la sesión no coincide con el cliente en Tiendanube (o el cliente no existe). Volvé a iniciar sesión.";
    }
    if (code === "tn_misconfigured") {
      return "Wishlist no disponible: falta TN_USER_AGENT o token en el servidor.";
    }
    if (code === "tn_error") {
      return "Tiendanube no respondió al validar el cliente (revisá token y TN_USER_AGENT).";
    }
    if (code === "store_not_found") {
      return "El id de tienda no coincide con el panel: TN_STORE_USER_ID en Railway debe ser el mismo LS.store.id de esta tienda.";
    }
    if (code === "missing_fields" || code === "missing_params" || code === "invalid_product" || code === "invalid_json") {
      return "Datos incompletos al guardar. Recargá la página.";
    }
    if (code === "db_write_failed") {
      return "Error al escribir en la base de datos del panel (¿migraciones aplicadas?).";
    }
    if (code === "invalid_response") {
      return "El servidor respondió algo que no es JSON (¿URL del panel incorrecta?).";
    }
    if (st === 403) {
      return "Acceso denegado (403). Revisá permisos OAuth o sesión.";
    }
    if (code && code.indexOf("http_") === 0) {
      return "Error del servidor (" + code.replace("http_", "HTTP ") + ").";
    }
    if (code === "Failed to fetch" || String(err && err.message) === "Failed to fetch") {
      return "No hay conexión con el panel (CORS, URL o bloqueo). En el administrador del tema: URL del panel Hache, o variable global HACHE_BACKEND_URL.";
    }
    return (
      "No se pudo " +
      failVerb +
      " (" +
      (code || "desconocido") +
      (st ? ", HTTP " + st : "") +
      "). Revisá la consola (F12)."
    );
  }

  const NS = "hs2_"; // localStorage namespace

  var HS_STYLE_ID = "hache-suite-ui-styles";

  function injectHacheSuiteStyles() {
    if (document.getElementById(HS_STYLE_ID)) return;
    var st = document.createElement("style");
    st.id = HS_STYLE_ID;
    st.textContent =
      "@keyframes hs-toast-in{from{opacity:0;transform:translateX(-50%) translateY(12px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}" +
      ".hs-toast{position:fixed;left:50%;bottom:1.35rem;transform:translateX(-50%);max-width:min(28rem,calc(100vw - 2rem));padding:.8rem 1.2rem;border-radius:.75rem;font:600 .8125rem/1.45 system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;z-index:2147483000;box-shadow:0 12px 40px rgba(0,0,0,.2);pointer-events:none;opacity:0;transition:opacity .38s ease,transform .38s ease;text-align:center;letter-spacing:.01em}" +
      ".hs-toast.hs-toast--visible{opacity:1;animation:hs-toast-in .42s ease both}" +
      ".hs-toast--success{background:linear-gradient(145deg,#059669,#10b981);color:#fff}" +
      ".hs-toast--error{background:linear-gradient(145deg,#1f2937,#3f3f46);color:#fafafa}" +
      ".hs-toast--neutral{background:#fff;color:#111;border:1px solid rgba(0,0,0,.08)}" +
      ":root[data-color-scheme='dark'] .hs-toast--neutral{background:rgba(26,26,30,.96);color:#f4f4f5;border-color:rgba(255,255,255,.1)}" +
      ".hs-gate-overlay{position:fixed;inset:0;z-index:2147482000;display:flex;align-items:center;justify-content:center;background:rgba(8,8,12,.88);backdrop-filter:blur(6px);-webkit-backdrop-filter:blur(6px);padding:1rem}" +
      ".hs-gate-card{background:linear-gradient(165deg,#16161c,#12121a);border:1px solid rgba(255,255,255,.1);border-radius:1rem;padding:2rem 1.75rem;width:100%;max-width:22rem;text-align:center;box-shadow:0 24px 80px rgba(0,0,0,.55)}" +
      ".hs-gate-icon{font-size:2.75rem;line-height:1;margin-bottom:.75rem}" +
      ".hs-gate-title{color:#f4f4f5;font-size:1.15rem;font-weight:700;margin:0 0 .4rem;letter-spacing:.02em}" +
      ".hs-gate-text{color:#a1a1b5;font-size:.875rem;margin:0 0 1.25rem;line-height:1.55}" +
      ".hs-gate-input{width:100%;padding:.75rem 1rem;background:rgba(0,0,0,.35);color:#f4f4f5;border:1px solid rgba(255,255,255,.12);border-radius:.5rem;font-size:.875rem;outline:none;box-sizing:border-box;margin-bottom:.5rem;font:inherit}" +
      ".hs-gate-input:focus{border-color:rgba(124,92,252,.55);box-shadow:0 0 0 2px rgba(124,92,252,.2)}" +
      ".hs-gate-err{color:#f87171;font-size:.78rem;margin-bottom:.65rem;display:none}" +
      ".hs-gate-btn{width:100%;padding:.8rem 1rem;background:linear-gradient(135deg,#6d28d9,#7c5cfc);color:#fff;border:none;border-radius:.5rem;font-size:.875rem;font-weight:600;cursor:pointer;font:inherit;transition:opacity .2s,transform .15s}" +
      ".hs-gate-btn:hover{opacity:.95;transform:translateY(-1px)}" +
      ".hs-gate-btn:disabled{opacity:.65;cursor:not-allowed;transform:none}" +
      ".hs-bundle-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(17.5rem,1fr));gap:1.35rem;padding:.5rem 0}" +
      ".hs-bundle-card{background:var(--hs-bundle-bg,var(--main-background,#fff));border:1px solid var(--hs-bundle-border,color-mix(in srgb,var(--accent-color,#6366f1) 18%,transparent));border-radius:1rem;overflow:hidden;display:flex;flex-direction:column;box-shadow:0 4px 20px color-mix(in srgb,var(--accent-color,#6366f1) 8%,transparent);transition:transform .2s,box-shadow .2s}" +
      ":root[data-color-scheme='dark'] .hs-bundle-card{--hs-bundle-bg:#161618;--hs-bundle-border:rgba(255,255,255,.1);box-shadow:0 8px 32px rgba(0,0,0,.35)}" +
      ".hs-bundle-card:hover{transform:translateY(-4px);box-shadow:0 14px 36px rgba(0,0,0,.12)}" +
      ":root[data-color-scheme='dark'] .hs-bundle-card:hover{box-shadow:0 16px 40px rgba(0,0,0,.45)}" +
      ".hs-bundle-body{padding:1.2rem 1.25rem 1.35rem;flex:1;display:flex;flex-direction:column}" +
      ".hs-bundle-title{font-size:1.02rem;font-weight:700;color:var(--hs-bundle-title,#111);line-height:1.3;margin:0}" +
      ":root[data-color-scheme='dark'] .hs-bundle-title{--hs-bundle-title:#f4f4f5}" +
      ".hs-bundle-desc{font-size:.84rem;color:var(--hs-bundle-muted,#666);line-height:1.5;margin:.4rem 0 .75rem}" +
      ":root[data-color-scheme='dark'] .hs-bundle-desc{--hs-bundle-muted:#a3a3b2}" +
      ".hs-bundle-list{list-style:none;padding:.65rem 0 0;margin:0 0 1rem;border-top:1px solid var(--hs-bundle-divider,rgba(0,0,0,.06))}" +
      ":root[data-color-scheme='dark'] .hs-bundle-list{--hs-bundle-divider:rgba(255,255,255,.08)}" +
      ".hs-bundle-row{display:flex;align-items:center;gap:.55rem;font-size:.82rem;padding:.32rem 0;color:var(--hs-bundle-row,#444);min-height:2rem}" +
      ":root[data-color-scheme='dark'] .hs-bundle-row{--hs-bundle-row:#d4d4e0}" +
      ".hs-bundle-row-thumb{width:28px;height:28px;border-radius:.35rem;object-fit:cover;flex-shrink:0;background:color-mix(in srgb,var(--accent-color,#6366f1) 12%,#f0f0f5)}" +
      ":root[data-color-scheme='dark'] .hs-bundle-row-thumb{background:color-mix(in srgb,var(--accent-color,#818cf8) 18%,#252528)}" +
      ".hs-bundle-row-thumb--ph{display:block}" +
      ".hs-bundle-row-main{flex:1;display:flex;justify-content:space-between;align-items:center;gap:.65rem;min-width:0}" +
      ".hs-bundle-row-name{min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}" +
      ".hs-bundle-row-price{color:var(--hs-bundle-dim,#999);font-variant-numeric:tabular-nums;flex-shrink:0}" +
      ":root[data-color-scheme='dark'] .hs-bundle-row-price{--hs-bundle-dim:#9ca3af}" +
      ".hs-bundle-price-old{font-size:.84rem;color:var(--hs-bundle-dim,#999);text-decoration:line-through}" +
      ".hs-bundle-price-new{font-size:1.45rem;font-weight:800;color:var(--hs-bundle-title,#111);margin-bottom:.75rem;letter-spacing:-.02em}" +
      ".hs-bundle-btn{width:100%;padding:.75rem 1rem;background:var(--accent-color,#111);color:var(--accent-btn-text,#fff);border:none;border-radius:.5rem;font-size:.88rem;font-weight:600;cursor:pointer;font:inherit;transition:opacity .2s,transform .15s,box-shadow .2s;box-shadow:0 2px 12px color-mix(in srgb,var(--accent-color,#6366f1) 35%,transparent)}" +
      ".hs-bundle-btn:hover{transform:translateY(-1px);opacity:.95}" +
      ".hs-bundle-btn--ok{background:linear-gradient(145deg,#059669,#10b981)}" +
      ".hs-bundle-btn--err{background:linear-gradient(145deg,#b91c1c,#ef4444)}" +
      ".hs-bundle-media{width:100%;height:12.5rem;object-fit:cover;display:block;background:linear-gradient(135deg,#f0f0fa,#e8e8f4)}" +
      ":root[data-color-scheme='dark'] .hs-bundle-media{background:linear-gradient(135deg,#252528,#1a1a1e)}" +
      ".hs-bundle-placeholder{width:100%;height:11rem;display:flex;align-items:center;justify-content:center;font-size:2.75rem;background:linear-gradient(135deg,#f0f0fa,#e4e4f0)}" +
      ":root[data-color-scheme='dark'] .hs-bundle-placeholder{background:linear-gradient(135deg,#2a2a30,#1f1f24)}" +
      ".hs-bundle-badge{align-self:flex-start;background:rgba(16,185,129,.15);color:#059669;padding:.2rem .55rem;border-radius:999px;font-size:.68rem;font-weight:700}" +
      ":root[data-color-scheme='dark'] .hs-bundle-badge{color:#4ade80;background:rgba(74,222,128,.12)}" +
      ".hs-bundle-state{text-align:center;padding:2rem 1rem;font:.9rem/1.5 system-ui,sans-serif;color:var(--hs-state,#888)}" +
      ".hs-bundle-state--err{color:#dc2626}" +
      ":root[data-color-scheme='dark'] .hs-bundle-state{--hs-state:#a1a1aa}" +
      ".hs-dyn-wrap,.hs-dyn-price-addon{display:inline-flex;align-items:center;gap:6px;flex-wrap:wrap;vertical-align:middle}" +
      ".hs-dyn-new{font-weight:700;color:#059669}" +
      ":root[data-color-scheme='dark'] .hs-dyn-new{color:#4ade80}" +
      ".hs-dyn-old{text-decoration:line-through;color:#888;font-size:.85em}" +
      ":root[data-color-scheme='dark'] .hs-dyn-old{color:#737373}" +
      ".hs-dyn-badge{background:rgba(16,185,129,.14);color:#059669;padding:2px 7px;border-radius:999px;font-size:.68rem;font-weight:700}" +
      ":root[data-color-scheme='dark'] .hs-dyn-badge{color:#4ade80;background:rgba(74,222,128,.14)}" +
      "@keyframes hs-gift-pop{0%{opacity:0;transform:scale(.94) translateY(8px)}100%{opacity:1;transform:scale(1) translateY(0)}}" +
      ".hs-gift-modal-overlay{position:fixed;inset:0;z-index:2147482500;display:flex;align-items:center;justify-content:center;padding:1rem;background:color-mix(in srgb,var(--accent-color,#6366f1) 12%,rgba(8,8,12,.82));backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px)}" +
      ".hs-gift-modal-card{width:100%;max-width:26rem;border-radius:1.15rem;overflow:hidden;background:var(--main-background,#fff);color:var(--main-foreground,#111);box-shadow:0 24px 64px rgba(0,0,0,.28),0 0 0 1px color-mix(in srgb,var(--accent-color,#6366f1) 22%,transparent);animation:hs-gift-pop .38s ease both}" +
      ":root[data-color-scheme='dark'] .hs-gift-modal-card{background:#141416;color:#f4f4f5;box-shadow:0 28px 72px rgba(0,0,0,.55),0 0 0 1px rgba(255,255,255,.08)}" +
      ".hs-gift-modal-ribbon{height:5px;background:linear-gradient(90deg,var(--accent-color,#7c5cfc),color-mix(in srgb,var(--accent-color,#a78bfa) 70%,#34d399))}" +
      ".hs-gift-modal-inner{padding:1.35rem 1.4rem 1.25rem}" +
      ".hs-gift-modal-icon{font-size:2.5rem;line-height:1;text-align:center;margin-bottom:.35rem}" +
      ".hs-gift-modal-title{font-size:1.12rem;font-weight:800;margin:0 0 .65rem;letter-spacing:-.02em;line-height:1.25;text-align:center;color:inherit}" +
      ".hs-gift-modal-body{font-size:.9rem;line-height:1.55;margin:0 0 1.1rem;color:color-mix(in srgb,currentColor 78%,transparent);text-align:center}" +
      ".hs-gift-modal-meta{font-size:.72rem;text-transform:uppercase;letter-spacing:.06em;font-weight:700;color:var(--accent-color,#7c5cfc);text-align:center;margin-bottom:.85rem}" +
      ":root[data-color-scheme='dark'] .hs-gift-modal-meta{color:color-mix(in srgb,var(--accent-color,#a5b4fc) 85%,#fff)}" +
      ".hs-gift-modal-btn{width:100%;padding:.72rem 1rem;border:none;border-radius:.65rem;font-size:.88rem;font-weight:700;cursor:pointer;font:inherit;background:var(--accent-color,#111);color:var(--accent-btn-text,#fff);transition:opacity .2s,transform .15s;box-shadow:0 4px 18px color-mix(in srgb,var(--accent-color,#6366f1) 38%,transparent)}" +
      ".hs-gift-modal-btn:hover{opacity:.95;transform:translateY(-1px)}" +
      ".hs-cart-gift-line{position:relative;border-radius:.5rem!important;outline:2px solid color-mix(in srgb,var(--accent-color,#6366f1) 35%,transparent);outline-offset:2px;background:color-mix(in srgb,var(--accent-color,#6366f1) 6%,transparent)!important}" +
      ":root[data-color-scheme='dark'] .hs-cart-gift-line{background:color-mix(in srgb,var(--accent-color,#818cf8) 10%,transparent)!important;outline-color:color-mix(in srgb,var(--accent-color,#a5b4fc) 40%,transparent)}" +
      ".hs-cart-gift-badge{display:inline-flex;align-items:center;gap:.25rem;padding:.12rem .45rem;border-radius:999px;font-size:.62rem;font-weight:800;letter-spacing:.04em;text-transform:uppercase;background:color-mix(in srgb,var(--accent-color,#6366f1) 18%,transparent);color:var(--accent-color,#4f46e5);margin-bottom:.35rem}" +
      ":root[data-color-scheme='dark'] .hs-cart-gift-badge{color:color-mix(in srgb,var(--accent-color,#c7d2fe) 90%,#fff);background:color-mix(in srgb,var(--accent-color,#6366f1) 22%,transparent)}";
    document.head.appendChild(st);
  }

  function hsToast(message, variant) {
    injectHacheSuiteStyles();
    var v = variant === "error" ? "error" : variant === "success" ? "success" : "neutral";
    var el = document.createElement("div");
    el.className = "hs-toast hs-toast--" + v;
    el.setAttribute("role", "status");
    el.textContent = message;
    document.body.appendChild(el);
    requestAnimationFrame(function () {
      el.classList.add("hs-toast--visible");
    });
    setTimeout(function () {
      el.classList.remove("hs-toast--visible");
      setTimeout(function () {
        if (el.parentNode) el.parentNode.removeChild(el);
      }, 420);
    }, 3600);
  }

  // ─── UTILS ─────────────────────────────────────────────────────────────────

  function lsGet(key) {
    try {
      const raw = localStorage.getItem(NS + key);
      if (!raw) return null;
      const parsed = JSON.parse(raw);
      if (parsed.exp && Date.now() > parsed.exp) {
        localStorage.removeItem(NS + key);
        return null;
      }
      return parsed.val;
    } catch (_) {
      return null;
    }
  }

  function lsSet(key, val, ttlMs) {
    try {
      localStorage.setItem(
        NS + key,
        JSON.stringify({ val, exp: ttlMs ? Date.now() + ttlMs : null })
      );
    } catch (_) {}
  }

  function apiGet(path) {
    return fetch(BACKEND_URL + path, { mode: "cors" }).then((r) => {
      if (!r.ok) throw new Error("HTTP " + r.status);
      return r.json();
    });
  }

  function apiPost(path, body) {
    return fetch(BACKEND_URL + path, {
      method: "POST",
      mode: "cors",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    }).then((r) => r.json());
  }

  /**
   * Agrega un item al carrito usando la API nativa de Tiendanube.
   * LS.Cart.addItem() es la forma oficial documentada por TN.
   * Fallback a fetch REST si LS.Cart no está disponible.
   */
  function addToCart(productId, variantId, quantity) {
    quantity = quantity || 1;
    function trackAddToCartOk() {
      try {
        var pid = parseInt(String(productId), 10);
        if (Number.isFinite(pid) && pid > 0) {
          sendConversionEvent("add_to_cart", { productId: pid });
        }
      } catch (_) {}
    }
    // Método 1: API nativa de Tiendanube (recomendado)
    if (window.LS && window.LS.Cart && typeof window.LS.Cart.addItem === "function") {
      return Promise.resolve(
        window.LS.Cart.addItem({
          product_id: productId,
          variant_id: variantId,
          quantity: quantity,
        })
      ).then(
        function (res) {
          trackAddToCartOk();
          return res;
        },
        function (err) {
          return Promise.reject(err);
        }
      );
    }
    // Método 2: API REST de Tiendanube (fallback)
    return fetch("/api/storefront/cart/items", {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        add: [{ product_id: productId, variant_id: variantId, quantity: quantity }],
      }),
    }).then(function (r) {
      return r.json().then(function (data) {
        if (r.ok) trackAddToCartOk();
        return data;
      });
    });
  }

  function getCartTotal() {
    let sub = 0;
    if (window.LS && window.LS.cart && typeof window.LS.cart.subtotal !== 'undefined') {
       sub = window.LS.cart.subtotal;
    } 
    if (!sub || sub <= 0) {
      const el = document.querySelector(".js-cart-subtotal, [data-store-cart-total]");
      if (el) {
        let text = el.textContent;
        let intPart = text.split(',')[0].replace(/\D/g, '');
        if (intPart) sub = parseInt(intPart, 10);
      }
    }
    return sub || 0;
  }

  function getCurrentPageType() {
    const path = (window.location && window.location.pathname) || "/";
    if (
      /^\/combos(\/|$)/i.test(path) ||
      /^\/pages\/combos(\/|$)/i.test(path) ||
      /^\/paginas\/combos(\/|$)/i.test(path)
    ) {
      return "bundle";
    }
    if (window.LS?.product?.id) return "product";
    if (window.LS?.category?.id) return "category";
    if (path === "/" || path === "") return "home";
    return "other";
  }

  function incrementVisitCount() {
    const current = lsGet("visit_count") || 0;
    const next = current + 1;
    lsSet("visit_count", next, null); // no TTL
    return next;
  }

  /** AR: "68.000" es miles; parseFloat lo lee como 68. */
  function parseLocaleMoneyTextToNumber(text, langEs) {
    const cleaned = String(text || "")
      .replace(/[^\d.,]/g, "")
      .trim();
    if (!cleaned) return NaN;
    if (langEs) {
      // "43.080.000": miles (43.080) con grupo ".000" fantasma (no es 43 M). Centena "06–09" evita 35.050.000 (35 M).
      const milesGhost000 = cleaned.match(/^(\d{2})\.(0[6-9]\d)\.000$/);
      if (milesGhost000) {
        const head = parseInt(milesGhost000[1], 10);
        if (head >= 35 && head <= 99) {
          return parseInt(milesGhost000[1] + milesGhost000[2], 10);
        }
      }
      if (/^\d{1,3}(\.\d{3})+$/.test(cleaned)) {
        return parseInt(cleaned.replace(/\./g, ""), 10);
      }
      if (/^\d{1,3}(\.\d{3})+,\d{1,2}$/.test(cleaned)) {
        return parseFloat(cleaned.replace(/\./g, "").replace(",", "."));
      }
      if (cleaned.includes(",") && !cleaned.includes(".")) {
        return parseFloat(cleaned.replace(",", "."));
      }
    }
    const digits = cleaned.replace(/[^\d]/g, "");
    if (digits) return parseInt(digits, 10);
    return NaN;
  }

  /** `content` / `data-product-price` pueden venir como "38.820" (miles): Number() daría 38.82. */
  function parseMoneyAttr(raw, langEs) {
    if (raw == null || raw === "") return NaN;
    const cleaned = String(raw)
      .trim()
      .replace(/[^\d.,]/g, "");
    if (!cleaned) return NaN;
    const viaLocale = parseLocaleMoneyTextToNumber(cleaned, langEs);
    if (Number.isFinite(viaLocale) && viaLocale > 0) return viaLocale;
    const n = Number(cleaned.replace(",", "."));
    return Number.isFinite(n) && n > 0 ? n : NaN;
  }

  /**
   * TN / tema a veces dejan enteros ×1000 con "centavos" en los últimos 3 dígitos (39116640 → ~39117).
   * Solo aplica a valores grandes; no toca precios < 1M.
   */
  function normalizeTnPesosCanonical(n) {
    const x = Math.round(Number(n));
    if (!Number.isFinite(x) || x < 1_000_000) return n;
    if (x % 1000 !== 0) {
      const d = Math.round(x / 1000);
      if (d >= 800 && d <= 2_000_000) return d;
    }
    return n;
  }

  function readCanonicalPriceFromEl(el) {
    const langEs = (document.documentElement.getAttribute("lang") || "").toLowerCase().startsWith("es");

    const content = el.getAttribute("content");
    let fromContent = NaN;
    if (content != null && content !== "") {
      fromContent = parseMoneyAttr(content, langEs);
    }
    const dpRaw = el.getAttribute("data-product-price");
    let fromDp = NaN;
    if (dpRaw != null && dpRaw !== "") {
      fromDp = parseMoneyAttr(dpRaw, langEs);
    }
    const fromText = parseLocaleMoneyTextToNumber(el.textContent || "", langEs);

    const maxAttr = Math.max(
      Number.isFinite(fromContent) && fromContent > 0 ? fromContent : 0,
      Number.isFinite(fromDp) && fromDp > 0 ? fromDp : 0,
    );

    // Listado: `content` y `data-product-price` a veces vienen ×1000 (p. ej. 38820836) y el HTML
    // visible sigue siendo "$38.820" → priorizar el texto parseado.
    if (Number.isFinite(fromText) && fromText > 0 && maxAttr > 0) {
      const r = maxAttr / fromText;
      if (r >= 50 && r <= 5000) {
        return normalizeTnPesosCanonical(Math.round(fromText));
      }
    }

    // TN a veces expone `content` (price_number) o el texto ya formateado leído mal
    // (p. ej. "38.772.000" → 38772000). `data-product-price` suele coincidir con el precio de catálogo.
    if (Number.isFinite(fromDp) && fromDp > 0) {
      if (Number.isFinite(fromContent) && fromContent / fromDp >= 80) {
        return normalizeTnPesosCanonical(fromDp);
      }
      if (Number.isFinite(fromText) && fromText / fromDp >= 80) {
        return normalizeTnPesosCanonical(fromDp);
      }
    }

    let out = NaN;
    if (Number.isFinite(fromContent) && fromContent > 0) out = fromContent;
    else if (Number.isFinite(fromDp) && fromDp > 0) out = fromDp;
    else if (Number.isFinite(fromText)) out = Math.round(fromText);
    return normalizeTnPesosCanonical(out);
  }

  function hsEscapeHtml(str) {
    return String(str || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function hsFormatGiftMoney(n) {
    var x = Number(n);
    if (!Number.isFinite(x)) return String(n);
    try {
      return x.toLocaleString("es-AR", { maximumFractionDigits: 0 });
    } catch (_) {
      return String(Math.round(x));
    }
  }

  function cartItemMatchesGift(item, gift) {
    if (!item || !gift) return false;
    var pid = item.product_id != null ? item.product_id : item.productId;
    var vid = item.variant_id != null ? item.variant_id : item.variantId;
    if (pid == null || vid == null) return false;
    return Number(pid) === Number(gift.giftProductId) && Number(vid) === Number(gift.giftVariantId);
  }

  function cartHasGiftLine(gift) {
    var items = (window.LS && window.LS.cart && window.LS.cart.items) || [];
    for (var i = 0; i < items.length; i++) {
      if (cartItemMatchesGift(items[i], gift)) return true;
    }
    return false;
  }

  function showGiftBenefitModal(rule) {
    injectHacheSuiteStyles();
    var old = document.getElementById("hs-gift-modal-overlay");
    if (old && old.parentNode) old.parentNode.removeChild(old);
    var title =
      (rule.publicBenefitTitle && String(rule.publicBenefitTitle).trim()) ||
      (rule.name && String(rule.name).trim()) ||
      "¡Tenés un regalo!";
    var rawMsg = rule.publicBenefitMessage && String(rule.publicBenefitMessage).trim();
    var bodyInner;
    if (rawMsg) {
      bodyInner = hsEscapeHtml(rawMsg).replace(/\r\n|\r|\n/g, "<br />");
    } else {
      bodyInner =
        "Tu compra alcanzó <strong>$" +
        hsFormatGiftMoney(rule.minTotal) +
        "</strong> y sumamos tu regalo al carrito.";
    }
    var overlay = document.createElement("div");
    overlay.id = "hs-gift-modal-overlay";
    overlay.className = "hs-gift-modal-overlay";
    overlay.setAttribute("role", "dialog");
    overlay.setAttribute("aria-modal", "true");
    overlay.setAttribute("aria-labelledby", "hs-gift-modal-title");
    overlay.innerHTML =
      '<div class="hs-gift-modal-card">' +
      '<div class="hs-gift-modal-ribbon"></div>' +
      '<div class="hs-gift-modal-inner">' +
      '<div class="hs-gift-modal-icon" aria-hidden="true">🎁</div>' +
      '<p class="hs-gift-modal-meta">Beneficio activado</p>' +
      '<h2 id="hs-gift-modal-title" class="hs-gift-modal-title">' +
      hsEscapeHtml(title) +
      "</h2>" +
      '<div class="hs-gift-modal-body">' +
      bodyInner +
      "</div>" +
      '<button type="button" class="hs-gift-modal-btn" id="hs-gift-modal-close">Genial, gracias</button>' +
      "</div></div>";
    document.body.appendChild(overlay);
    function closeModal() {
      document.removeEventListener("keydown", onKey);
      if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
    }
    function onKey(e) {
      if (e.key === "Escape") closeModal();
    }
    document.addEventListener("keydown", onKey);
    overlay.addEventListener("click", function (e) {
      if (e.target === overlay) closeModal();
    });
    var btn = document.getElementById("hs-gift-modal-close");
    if (btn) btn.addEventListener("click", closeModal);
  }

  function decorateGiftCartLines(applicableRules) {
    var allRows = document.querySelectorAll(".js-cart-item");
    for (var a = 0; a < allRows.length; a++) {
      allRows[a].classList.remove("hs-cart-gift-line");
      var oldBadge = allRows[a].querySelector(".hs-cart-gift-badge");
      if (oldBadge && oldBadge.parentNode) oldBadge.parentNode.removeChild(oldBadge);
    }
    if (!applicableRules || !applicableRules.length) return;
    for (var j = 0; j < applicableRules.length; j++) {
      var rule = applicableRules[j];
      if (!cartHasGiftLine(rule)) continue;
      var pid = rule.giftProductId;
      var el = document.querySelector('.js-cart-item[data-store="cart-item-' + pid + '"]');
      if (!el) {
        var inner = document.querySelector('[data-store="cart-item-' + pid + '"]');
        el = inner && inner.closest ? inner.closest(".js-cart-item") : null;
      }
      if (!el) continue;
      el.classList.add("hs-cart-gift-line");
      var nameWrap =
        el.querySelector(".cart-item-name-container") ||
        el.querySelector(".cart-item-name") ||
        el.querySelector(".col.pl-3");
      if (nameWrap && !nameWrap.querySelector(".hs-cart-gift-badge")) {
        var badge = document.createElement("span");
        badge.className = "hs-cart-gift-badge";
        badge.textContent = "Regalo";
        nameWrap.insertBefore(badge, nameWrap.firstChild);
      }
    }
  }

  // ─── MODULE 1: CART GIFT ───────────────────────────────────────────────────

  const CartGiftModule = {
    _addingSet: new Set(),
    _debounceTimer: null,

    scheduleCheck() {
      if (this._debounceTimer) clearTimeout(this._debounceTimer);
      const self = this;
      this._debounceTimer = setTimeout(function () {
        self._debounceTimer = null;
        self.check().catch(function () {});
      }, 320);
    },

    async init() {
      await this.check();
      document.addEventListener("cart:update", () => this.scheduleCheck());
      document.addEventListener("cart:itemAdded", () => this.scheduleCheck());
      document.addEventListener("cart:itemRemoved", () => this.scheduleCheck());
    },

    async check() {
      if (!getStoreId()) return;
      const total = getCartTotal();
      if (total <= 0) return;

      let gifts;
      const cacheKey = "cart_gifts_v2_" + Math.floor(total / 100);
      const cached = lsGet(cacheKey);
      if (cached) {
        gifts = cached;
      } else {
        try {
          const res = await apiGet(
            `/api/storefront/cart-gifts?storeId=${getStoreId()}&total=${total}`
          );
          gifts = res.gifts || [];
          lsSet(cacheKey, gifts, 10 * 1000);
        } catch (e) {
          console.warn("[HacheSuite][CartGift]", e);
          return;
        }
      }

      const applicable = gifts.filter((g) => Number(g.minTotal) <= total);

      for (const gift of gifts) {
        if (Number(gift.minTotal) > total) continue;
        if (cartHasGiftLine(gift)) continue;
        if (this._addingSet.has(gift.id)) continue;
        try {
          this._addingSet.add(gift.id);
          await addToCart(
            gift.giftProductId,
            gift.giftVariantId,
            gift.giftQty && gift.giftQty > 0 ? gift.giftQty : 1
          );
          showGiftBenefitModal(gift);
        } catch (err) {
          console.warn("[HacheSuite][CartGift] Error agregando regalo:", err);
        } finally {
          this._addingSet.delete(gift.id);
        }
      }

      decorateGiftCartLines(applicable);
      setTimeout(function () {
        decorateGiftCartLines(applicable);
      }, 600);
    },
  };

  // ─── MODULE 2: CATEGORY GATE ───────────────────────────────────────────────

  const CategoryGateModule = {
    async init() {
      if (!getStoreId()) return;
      const categoryId = window.LS?.category?.id;
      if (!categoryId) return;

      // Check if this category is locked
      let status;
      const cacheKey = `gate_${categoryId}`;
      const cached = lsGet(cacheKey);
      if (cached !== null) {
        status = cached;
      } else {
        try {
          status = await apiGet(
            `/api/storefront/category-gate?storeId=${getStoreId()}&categoryId=${categoryId}`
          );
          lsSet(cacheKey, status, 60 * 60 * 1000); // 1h cache
        } catch (e) {
          console.warn("[HacheSuite][CategoryGate]", e);
          return;
        }
      }

      if (!status.locked) return;

      // Check if user has a valid access token
      const accessKey = `gate_access_${categoryId}`;
      const accessData = lsGet(accessKey);
      if (accessData?.token && accessData?.expiresAt && Date.now() < new Date(accessData.expiresAt).getTime()) {
        return; // Access granted
      }

      // Block page and show modal
      this.showGateModal(categoryId, status.ttlHours);
    },

    showGateModal(categoryId, ttlHours) {
      // Hide page content
      document.body.style.filter = "blur(8px)";
      document.body.style.pointerEvents = "none";

      injectHacheSuiteStyles();
      const overlay = document.createElement("div");
      overlay.id = "hs-gate-overlay";
      overlay.className = "hs-gate-overlay";

      overlay.innerHTML =
        '<div class="hs-gate-card">' +
        '<div class="hs-gate-icon" aria-hidden="true">🔒</div>' +
        '<h2 class="hs-gate-title">Contenido exclusivo</h2>' +
        '<p class="hs-gate-text">Esta categoría es de acceso restringido. Ingresá la contraseña para continuar.</p>' +
        '<input id="hs-gate-input" class="hs-gate-input" type="password" placeholder="Contraseña de acceso" autocomplete="current-password" />' +
        '<div id="hs-gate-error" class="hs-gate-err">Contraseña incorrecta</div>' +
        '<button type="button" id="hs-gate-btn" class="hs-gate-btn">Acceder</button>' +
        "</div>";

      document.body.appendChild(overlay);
      document.body.style.pointerEvents = "";
      document.getElementById("hs-gate-input").focus();

      const unlock = async () => {
        const password = document.getElementById("hs-gate-input").value;
        const btn = document.getElementById("hs-gate-btn");
        if (!password) return;

        btn.textContent = "Verificando...";
        btn.disabled = true;

        try {
          const res = await apiPost("/api/storefront/category-gate", {
            storeId: getStoreId(),
            categoryId: parseInt(categoryId),
            password,
          });

          if (res.success) {
            lsSet(`gate_access_${categoryId}`, { token: res.token, expiresAt: res.expiresAt }, null);
            overlay.remove();
            document.body.style.filter = "";
          } else {
            document.getElementById("hs-gate-error").style.display = "block";
            document.getElementById("hs-gate-input").value = "";
            document.getElementById("hs-gate-input").focus();
            btn.textContent = "Acceder";
            btn.disabled = false;
          }
        } catch (_) {
          btn.textContent = "Acceder";
          btn.disabled = false;
        }
      };

      document.getElementById("hs-gate-btn").addEventListener("click", unlock);
      document.getElementById("hs-gate-input").addEventListener("keydown", (e) => {
        if (e.key === "Enter") unlock();
      });
    },
  };

  // ─── MODULE 3: DYNAMIC PRICING ─────────────────────────────────────────────

  var hsCommitClickHookInstalled = false;

  function installDynamicPriceCommitHook() {
    if (hsCommitClickHookInstalled) return;
    hsCommitClickHookInstalled = true;
    document.addEventListener("click", hsOnAddToCartCapture, true);
  }

  async function hsOnAddToCartCapture(e) {
    if (!DynamicPricingModule.commitOnAddToCart) return;
    var btn = e.target && e.target.closest && e.target.closest(".js-addtocart:not(.js-addtocart-placeholder)");
    if (!btn || btn.disabled) return;
    if (btn.getAttribute("data-hs-bypass-dynamic-commit") === "1") {
      btn.removeAttribute("data-hs-bypass-dynamic-commit");
      return;
    }
    if (!e.isTrusted) return;

    var item = btn.closest(".js-item-product");
    var form = btn.closest("form.js-product-form, form#product_form");
    var productId = null;
    if (item && item.dataset.productId) productId = parseInt(item.dataset.productId, 10);
    if (!productId && form) {
      var addH = form.querySelector('[name="add_to_cart"]');
      if (addH && addH.value) productId = parseInt(addH.value, 10);
    }
    if (!Number.isFinite(productId) || productId <= 0) return;

    var variantId = null;
    var ship = document.getElementById("shipping-variant-id");
    if (ship && ship.value) {
      var vs = parseInt(ship.value, 10);
      if (Number.isFinite(vs) && vs > 0) variantId = vs;
    }
    var vidInput = form && form.querySelector('input[name="variant_id"]');
    if (!variantId && vidInput && vidInput.value) {
      var vi = parseInt(vidInput.value, 10);
      if (Number.isFinite(vi) && vi > 0) variantId = vi;
    }

    e.preventDefault();
    if (typeof e.stopPropagation === "function") e.stopPropagation();
    if (typeof e.stopImmediatePropagation === "function") e.stopImmediatePropagation();

    var visitCount = lsGet("visit_count") || 1;
    try {
      var res = await fetch(BACKEND_URL + "/api/storefront/dynamic-price-commit", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        mode: "cors",
        body: JSON.stringify({
          storeId: getStoreId(),
          productId: productId,
          variantId: variantId || undefined,
          visitCount: visitCount,
        }),
      });
      if (!res.ok) {
        var err = await res.json().catch(function () {
          return {};
        });
        console.warn("[HacheSuite][DynamicPricing][commit]", res.status, err);
      }
    } catch (err) {
      console.warn("[HacheSuite][DynamicPricing][commit]", err);
    } finally {
      btn.setAttribute("data-hs-bypass-dynamic-commit", "1");
      queueMicrotask(function () {
        btn.click();
      });
    }
  }

  const DynamicPricingModule = {
    priceMap: {},
    commitOnAddToCart: false,

    async init() {
      if (!getStoreId()) return;
      const productIds = this.collectProductIds();
      if (productIds.length === 0) return;

      const visitCount = incrementVisitCount();
      const cacheKey = `dyn_prices_v3_${productIds.sort().join("_")}`;
      let data = lsGet(cacheKey);

      if (!data) {
        try {
          data = await apiGet(
            `/api/storefront/dynamic-prices?storeId=${getStoreId()}&products=${productIds.join(",")}&visitCount=${visitCount}`
          );
          if (data.enabled) {
            lsSet(cacheKey, data, (data.cacheTtlHours || 4) * 60 * 60 * 1000);
          }
        } catch (e) {
          console.warn("[HacheSuite][DynamicPricing]", e);
          return;
        }
      }

      if (!data || !data.enabled) return;
      this.priceMap = data.prices || {};
      this.commitOnAddToCart = Boolean(data.commitOnAddToCart);
      this.applyPrices();
      if (this.commitOnAddToCart) {
        installDynamicPriceCommitHook();
      }
    },

    collectProductIds() {
      const ids = new Set();
      if (window.LS?.product?.id) ids.add(String(window.LS.product.id));
      document.querySelectorAll("[data-product-id]").forEach((el) => {
        ids.add(el.dataset.productId);
      });
      return [...ids].filter(Boolean);
    },

    applyPrices() {
      document.querySelectorAll("[data-product-id]").forEach((el) => {
        const pid = el.dataset.productId;
        const priceData = this.priceMap[pid];
        if (!priceData) return;

        const priceEl = el.querySelector("[data-product-price], .js-price-display, .price");
        if (!priceEl) return;

        const original = readCanonicalPriceFromEl(priceEl);
        if (!Number.isFinite(original) || original <= 0) return;

        const discounted = Math.round(original * priceData.multiplier);
        this.injectDynamicPrice(priceEl, original, discounted, priceData.pct);
      });

      if (window.LS?.product?.id) {
        const pid = String(window.LS.product.id);
        const priceData = this.priceMap[pid];
        if (priceData) {
          document.querySelectorAll(".js-price-display, [itemprop='price'], .product-price").forEach((el) => {
            const original = readCanonicalPriceFromEl(el);
            if (!Number.isFinite(original) || original <= 0) return;
            const discounted = Math.round(original * priceData.multiplier);
            this.injectDynamicPrice(el, original, discounted, priceData.pct);
          });
        }
      }

      if (typeof window.themeRefreshTransferLines === "function" && window.jQueryNuvem) {
        try {
          window.themeRefreshTransferLines(window.jQueryNuvem(document));
        } catch (_) {}
      }
    },

    injectDynamicPrice(el, original, discounted, pct) {
      if (el.dataset.hsProcessed) return;
      el.dataset.hsProcessed = "1";

      var sym =
        window.LS && LS.currency && LS.currency.display_short
          ? LS.currency.display_short
          : (el.textContent.match(/[^0-9.,\s]+/) || ["$"])[0].trim();
      var lang = (document.documentElement.getAttribute("lang") || "").toLowerCase();
      var locale = lang.indexOf("es") === 0 ? "es-AR" : undefined;
      var fmtNum = function (v) {
        return Math.round(Number(v)).toLocaleString(locale || "es-AR", {
          maximumFractionDigits: 0,
          minimumFractionDigits: 0,
        });
      };

      injectHacheSuiteStyles();
      /* Solo el precio efectivo dentro de .js-price-display: TN fillQuickshop / .text() concatenan
         todo el texto de los hijos y rompen compra rápida. Tachado + badge van como hermano (.hs-dyn-price-addon). */
      while (el.firstChild) {
        el.removeChild(el.firstChild);
      }
      el.textContent = sym + fmtNum(discounted);
      el.setAttribute("data-hs-effective-price", String(discounted));

      var addon = document.createElement("span");
      addon.className = "hs-dyn-price-addon hs-dyn-wrap";
      addon.innerHTML =
        '<span class="hs-dyn-old">' +
        sym +
        fmtNum(original) +
        "</span>" +
        '<span class="hs-dyn-badge">-' +
        pct +
        "%</span>";
      if (el.parentNode) {
        el.parentNode.insertBefore(addon, el.nextSibling);
      }

      var root = el.closest(".js-item-product, .js-product-container, #single-product, .js-price-container");
      if (root) {
        var row = root.querySelector(".js-theme-transfer-computed");
        if (row) {
          var tpct = Number(row.getAttribute("data-transfer-pct"));
          if (isFinite(tpct) && tpct > 0 && tpct < 100) {
            var tval = Math.round((discounted * (100 - tpct)) / 100);
            var amt = row.querySelector(".js-theme-transfer-amount");
            if (amt) {
              amt.textContent = sym + fmtNum(tval);
            }
          }
        }
      }
    },
  };

  // ─── MODULE 4: BUNDLE PAGE ─────────────────────────────────────────────────

  const BundlePageModule = {
    _loadStarted: false,

    async init() {
      const container = document.getElementById("hs-bundles-container");
      if (!container) return;

      injectHacheSuiteStyles();

      if (!getStoreId()) {
        container.innerHTML =
          '<p class="hs-bundle-state">Conectando con la tienda…</p>';
        let tries = 0;
        const timer = window.setInterval(() => {
          tries += 1;
          if (getStoreId()) {
            window.clearInterval(timer);
            this._loadStarted = false;
            this.init();
            return;
          }
          if (tries >= 50) {
            window.clearInterval(timer);
            container.innerHTML =
              '<p class="hs-bundle-state hs-bundle-state--err">No se detectó el id de la tienda (LS.store.id). Agregá en el tema la meta <code>&lt;meta name="hache-store-user-id" content="TU_ID"&gt;</code> con el mismo número que en el panel (TN_STORE_USER_ID), o recargá la página.</p>';
          }
        }, 200);
        return;
      }

      if (this._loadStarted) return;
      this._loadStarted = true;

      container.innerHTML = '<p class="hs-bundle-state">Cargando combos…</p>';

      let data;
      const cached = lsGet("bundles_v3");
      if (cached && (cached.bundles || []).length > 0) {
        data = cached;
      } else {
        try {
          data = await apiGet(
            `/api/storefront/bundles?storeId=${encodeURIComponent(getStoreId())}`
          );
          if ((data.bundles || []).length > 0) {
            lsSet("bundles_v3", data, 30 * 1000);
          }
        } catch (e) {
          this._loadStarted = false;
          container.innerHTML =
            '<p class="hs-bundle-state hs-bundle-state--err">No se pudieron cargar los combos. Revisá la consola (F12) y que HACHE_BACKEND_URL / CORS apunten al panel.</p>';
          return;
        }
      }

      const bundles = data.bundles || [];
      if (bundles.length === 0) {
        this._loadStarted = false;
        try {
          localStorage.removeItem(NS + "bundles_v3");
        } catch (_) {}
        container.innerHTML =
          '<p class="hs-bundle-state">No hay combos publicados todavía. Creálos en el panel Hache (Bundles) y marcá <strong>activo</strong>; el id de tienda en el servidor debe coincidir con esta tienda.</p>';
        return;
      }

      container.innerHTML = "";
      const grid = document.createElement("div");
      grid.className = "hs-bundle-grid";

      for (const bundle of bundles) {
        const card = this.renderCard(bundle);
        grid.appendChild(card);
      }
      container.appendChild(grid);
      this._loadStarted = false;
    },

    renderCard(bundle) {
      const totalOriginal = bundle.products.reduce(
        (acc, p) => acc + p.unitPrice * p.quantity,
        0
      );
      const saving = totalOriginal > 0
        ? Math.round((1 - bundle.comboPrice / totalOriginal) * 100)
        : 0;

      const card = document.createElement("div");
      card.className = "hs-bundle-card";

      const imgHtml = bundle.imageUrl
        ? `<img class="hs-bundle-media" src="${bundle.imageUrl}" alt="${bundle.name.replace(/"/g, "&quot;")}" loading="lazy" />`
        : '<div class="hs-bundle-placeholder" aria-hidden="true">📦</div>';

      const productsHtml = bundle.products
        .map(function (p) {
          var thumb = p.thumbnailUrl
            ? '<img class="hs-bundle-row-thumb" src="' +
              String(p.thumbnailUrl).replace(/"/g, "") +
              '" alt="" width="28" height="28" loading="lazy" />'
            : '<span class="hs-bundle-row-thumb hs-bundle-row-thumb--ph" aria-hidden="true"></span>';
          return (
            '<li class="hs-bundle-row">' +
            thumb +
            '<span class="hs-bundle-row-main"><span class="hs-bundle-row-name">× ' +
            p.quantity +
            " " +
            String(p.productName).replace(/</g, "&lt;") +
            '</span><span class="hs-bundle-row-price">$' +
            p.unitPrice.toLocaleString() +
            "</span></span></li>"
          );
        })
        .join("");

      const descHtml = bundle.description
        ? '<p class="hs-bundle-desc">' + String(bundle.description).replace(/</g, "&lt;") + "</p>"
        : "";

      card.innerHTML =
        imgHtml +
        '<div class="hs-bundle-body">' +
        '<div style="display:flex;align-items:flex-start;justify-content:space-between;gap:.5rem;margin-bottom:.35rem">' +
        "<h3 class=\"hs-bundle-title\">" +
        String(bundle.name).replace(/</g, "&lt;") +
        "</h3>" +
        (saving > 0 ? '<span class="hs-bundle-badge">-' + saving + "%</span>" : "") +
        "</div>" +
        descHtml +
        '<ul class="hs-bundle-list">' +
        productsHtml +
        "</ul>" +
        '<div style="margin-top:auto">' +
        (totalOriginal > 0
          ? '<div class="hs-bundle-price-old">$' + totalOriginal.toLocaleString() + "</div>"
          : "") +
        '<div class="hs-bundle-price-new">$' +
        bundle.comboPrice.toLocaleString() +
        "</div>" +
        '<button type="button" class="hs-bundle-btn" data-bundle-id="' +
        bundle.id +
        '">Agregar combo al carrito</button>' +
        "</div></div>";

      const btn = card.querySelector(`[data-bundle-id="${bundle.id}"]`);
      btn.addEventListener("click", () => this.addBundleToCart(bundle, btn));

      return card;
    },

    async addBundleToCart(bundle, btn) {
      btn.textContent = "Agregando...";
      btn.disabled = true;
      btn.classList.remove("hs-bundle-btn--ok", "hs-bundle-btn--err");

      let allOk = true;
      for (const p of bundle.products) {
        try {
          await addToCart(p.productId, p.variantId || undefined, p.quantity);
        } catch (err) {
          console.warn("[HacheSuite][Bundle] Error agregando producto:", p.productName, err);
          allOk = false;
        }
      }

      if (allOk) {
        btn.textContent = "✓ Agregado al carrito";
        btn.classList.add("hs-bundle-btn--ok");
        setTimeout(() => {
          btn.textContent = "Agregar combo al carrito";
          btn.classList.remove("hs-bundle-btn--ok");
          btn.disabled = false;
        }, 2500);
        document.dispatchEvent(new CustomEvent("cart:update"));
      } else {
        btn.textContent = "Error — intentá de nuevo";
        btn.classList.add("hs-bundle-btn--err");
        btn.disabled = false;
      }
    },
  };

  // ─── Wishlist (PDP; anonimos -> login TN) ─────────────────────────────────

  let wishlistClickDelegationBound = false;

  const WishlistModule = {
    pendingKey() {
      return NS + "wishlist_pending";
    },
    getPendingProductId() {
      try {
        const v = localStorage.getItem(this.pendingKey());
        if (!v) return null;
        const id = parseInt(v, 10);
        return id > 0 ? id : null;
      } catch (_) {
        return null;
      }
    },
    setPendingProductId(id) {
      try {
        localStorage.setItem(this.pendingKey(), String(id));
      } catch (_) {}
    },
    clearPending() {
      try {
        localStorage.removeItem(this.pendingKey());
      } catch (_) {}
    },

    getCustomer() {
      let rawId;
      let rawEmail;
      const c = window.__HACHE_CUSTOMER__;
      if (c && (c.email != null || c.Email != null)) {
        rawId = c.id;
        rawEmail = c.email != null ? c.email : c.Email;
      } else {
        const mId = document.querySelector('meta[name="x-hache-customer-id"]');
        const mEm = document.querySelector('meta[name="x-hache-customer-email"]');
        if (!mId || !mEm) return null;
        rawId = mId.getAttribute("content");
        rawEmail = mEm.getAttribute("content");
      }
      const id = typeof rawId === "number" ? rawId : parseInt(String(rawId), 10);
      const email = String(rawEmail ?? "").trim();
      if (!Number.isFinite(id) || id <= 0 || !email) return null;
      return { id, email };
    },

    loginUrl() {
      const u = window.__HACHE_LOGIN_URL__;
      return typeof u === "string" && u.trim() ? u.trim() : "/account/login/";
    },

    setButtonState(btn, inList) {
      btn.classList.toggle("is-active", Boolean(inList));
      btn.setAttribute("aria-pressed", inList ? "true" : "false");
      const addLabel = btn.getAttribute("data-wishlist-label-add") || "Save to wishlist";
      const removeLabel = btn.getAttribute("data-wishlist-label-remove") || "Remove from wishlist";
      const label = inList ? removeLabel : addLabel;
      btn.setAttribute("aria-label", label);
      const hidden = btn.querySelector(".visually-hidden");
      if (hidden) hidden.textContent = label;
    },

    wishlistToast(msg, isError) {
      hsToast(msg, isError ? "error" : "neutral");
    },

    handleWishlistButtonClick(btn) {
      const productId = parseInt(btn.getAttribute("data-product-id") || "", 10);
      if (!productId) return;
      if (!getStoreId()) {
        this.wishlistToast("Tienda no lista aún. Recargá la página en unos segundos.", true);
        console.warn("[HacheSuite][Wishlist] Sin store id");
        return;
      }

      const customer = this.getCustomer();
      if (!customer) {
        this.setPendingProductId(productId);
        window.location.href = this.loginUrl();
        return;
      }

      const prev = btn.classList.contains("is-active");
      this.setButtonState(btn, !prev);
      this.postToggle(customer, productId)
        .then((data) => {
          this.setButtonState(btn, Boolean(data.inWishlist));
          hsToast(data.inWishlist ? "Guardado en favoritos" : "Quitado de favoritos", "success");
        })
        .catch((err) => {
          this.setButtonState(btn, prev);
          const code = err && typeof err.message === "string" ? err.message : "";
          const st = err && typeof err.httpStatus === "number" ? err.httpStatus : 0;
          this.wishlistToast(wishlistUserFacingMessage(code, st, err), true);
          console.warn("[HacheSuite][Wishlist]", code, st, err && err.bodyPreview, err);
        });
    },

    attachClickDelegation() {
      if (wishlistClickDelegationBound) return;
      wishlistClickDelegationBound = true;
      /* capture=true: corre antes que handlers en burbuja que hagan stopPropagation (TN / jQuery). */
      document.addEventListener(
        "click",
        (ev) => {
          const btn = ev.target.closest(".js-wishlist-toggle");
          if (!btn) return;
          ev.preventDefault();
          WishlistModule.handleWishlistButtonClick(btn);
        },
        true
      );
    },

    async fetchList(customer) {
      const q = new URLSearchParams({
        storeId: getStoreId(),
        customerId: String(customer.id),
        email: customer.email,
      });
      const data = await wishlistRequestJson(BACKEND_URL + "/api/storefront/wishlist?" + q.toString(), {});
      return Array.isArray(data.productIds) ? data.productIds : [];
    },

    async postToggle(customer, productId) {
      return wishlistRequestJson(BACKEND_URL + "/api/storefront/wishlist", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          storeId: getStoreId(),
          customerId: customer.id,
          customerEmail: customer.email,
          productId,
        }),
      });
    },

    async syncInitialState(buttons) {
      if (!getStoreId()) return;
      const customer = this.getCustomer();
      if (!customer || !buttons.length) return;
      let ids = [];
      try {
        ids = await this.fetchList(customer);
      } catch (e) {
        console.warn("[HacheSuite][Wishlist] No se pudo leer la lista", e);
        return;
      }
      const set = new Set(ids.map(Number));
      buttons.forEach((btn) => {
        const id = parseInt(btn.getAttribute("data-product-id") || "", 10);
        if (!id) return;
        this.setButtonState(btn, set.has(id));
      });
    },

    async refreshAllWishlistButtons() {
      const buttons = Array.from(document.querySelectorAll(".js-wishlist-toggle"));
      if (!buttons.length) return;
      await this.syncInitialState(buttons);
    },

    async consumePending() {
      if (!getStoreId()) return;
      const customer = this.getCustomer();
      const pending = this.getPendingProductId();
      if (!customer || !pending) return;
      this.clearPending();
      try {
        await this.postToggle(customer, pending);
      } catch (e) {
        const code = e && typeof e.message === "string" ? e.message : "";
        const st = e && typeof e.httpStatus === "number" ? e.httpStatus : 0;
        this.wishlistToast(wishlistUserFacingMessage(code, st, e), true);
        console.warn("[HacheSuite][Wishlist] Pendiente no aplicado", e);
        return;
      }
      document.querySelectorAll(".js-wishlist-toggle").forEach((btn) => {
        const id = parseInt(btn.getAttribute("data-product-id") || "", 10);
        if (id === pending) this.setButtonState(btn, true);
      });
    },

    async init() {
      this.attachClickDelegation();
      await this.consumePending();
      await this.refreshAllWishlistButtons();
      setTimeout(() => {
        WishlistModule.refreshAllWishlistButtons().catch(console.warn);
      }, 1200);
    },
  };

  /* No esperar LS.ready: si esa promesa no resuelve, igual el PDP debe poder guardar favoritos. */
  try {
    WishlistModule.attachClickDelegation();
  } catch (e) {
    console.warn("[HacheSuite][Wishlist] attach inmediato", e);
  }
  setTimeout(() => {
    WishlistModule.init().catch(console.warn);
  }, 350);

  // ─── Wishlist pagina (ruta /SLUG, ej. /my-wishlist) ────────────────────────

  function escapeHtmlWishlist(s) {
    return String(s ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function formatWishlistMoney(n) {
    if (!Number.isFinite(n)) return "";
    var sym =
      window.LS && LS.currency && LS.currency.display_short
        ? LS.currency.display_short
        : "$";
    var lang = (document.documentElement.getAttribute("lang") || "").toLowerCase();
    var loc = lang.indexOf("es") === 0 ? "es-AR" : undefined;
    return sym + Math.round(n).toLocaleString(loc || "es-AR", { maximumFractionDigits: 0 });
  }

  const WishlistPageModule = {
    async init() {
      const root = document.getElementById("hs-wishlist-page");
      if (!root || root.getAttribute("data-logged") !== "1") return;

      const customer = WishlistModule.getCustomer();
      if (!customer) return;

      const storeId = getStoreId();
      if (!storeId) {
        const err = root.getAttribute("data-msg-error") || "Error";
        while (root.firstChild) root.removeChild(root.firstChild);
        var errBox = document.createElement("div");
        errBox.className = "hs-wl-error font-small text-muted text-center py-5";
        errBox.textContent = err;
        root.appendChild(errBox);
        return;
      }

      const q = new URLSearchParams({
        storeId,
        customerId: String(customer.id),
        email: customer.email,
        details: "1",
      });

      let data;
      try {
        data = await wishlistRequestJson(BACKEND_URL + "/api/storefront/wishlist?" + q.toString(), {});
      } catch (e) {
        console.warn("[HacheSuite][WishlistPage]", e);
        const code = e && typeof e.message === "string" ? e.message : "";
        const st = e && typeof e.httpStatus === "number" ? e.httpStatus : 0;
        const line = wishlistUserFacingMessage(code, st, e, { failVerb: "cargar favoritos" });
        const load = root.querySelector(".hs-wishlist-loading-state");
        if (load) load.remove();
        while (root.firstChild) root.removeChild(root.firstChild);
        var errP = document.createElement("div");
        errP.className = "hs-wl-error font-small text-muted text-center py-5 px-3";
        errP.textContent = line;
        root.appendChild(errP);
        return;
      }

      const items = Array.isArray(data.items) ? data.items : [];
      const loadEl = root.querySelector(".hs-wishlist-loading-state");
      if (loadEl) loadEl.remove();

      function renderEmptyWishlist() {
        while (root.firstChild) root.removeChild(root.firstChild);
        const emptyTitle = root.getAttribute("data-msg-empty") || "";
        const emptyLead = root.getAttribute("data-msg-empty-lead") || "";
        const cta = root.getAttribute("data-wl-empty-cta") || "";
        var wrap = document.createElement("div");
        wrap.className = "hs-wl-empty";
        wrap.innerHTML =
          '<div class="hs-wl-empty__card">' +
          '<div class="hs-wl-empty__icon" aria-hidden="true">✦</div>' +
          '<p class="hs-wl-empty__title"></p>' +
          '<p class="hs-wl-empty__lead"></p>' +
          '<a class="hs-wl-empty__cta" href="/"></a>' +
          "</div>";
        wrap.querySelector(".hs-wl-empty__title").textContent = emptyTitle;
        wrap.querySelector(".hs-wl-empty__lead").textContent = emptyLead;
        var a = wrap.querySelector(".hs-wl-empty__cta");
        a.textContent = cta;
        a.setAttribute("href", "/");
        root.appendChild(wrap);
      }

      if (!items.length) {
        renderEmptyWishlist();
        return;
      }

      injectHacheSuiteStyles();

      const labelView = root.getAttribute("data-label-view") || "Ver producto";
      const labelRemove = root.getAttribute("data-label-remove") || "Quitar";
      const labelRemoved = root.getAttribute("data-label-removed") || "Quitado";
      const labelBuy = root.getAttribute("data-label-buy") || "Repetir compra";
      const labelBuyDis = root.getAttribute("data-label-buy-disabled") || "";
      const toastOk = root.getAttribute("data-toast-cart-ok") || "";
      const toastFail = root.getAttribute("data-toast-cart-fail") || "";
      const statNoun = root.getAttribute("data-wl-stat-noun") || "";

      var shell = document.createElement("div");
      shell.className = "hs-wl-shell";

      var hero = document.createElement("div");
      hero.className = "hs-wl-hero";
      hero.innerHTML =
        '<div class="hs-wl-hero__glow" aria-hidden="true"></div>' +
        '<div class="hs-wl-hero__content">' +
        '<div class="hs-wl-hero__stat" aria-live="polite">' +
        '<span class="hs-wl-hero__stat-num"></span>' +
        '<span class="hs-wl-hero__stat-label"></span>' +
        "</div></div>";
      hero.querySelector(".hs-wl-hero__stat-num").textContent = String(items.length);
      hero.querySelector(".hs-wl-hero__stat-label").textContent = statNoun;
      shell.appendChild(hero);

      const grid = document.createElement("div");
      grid.className = "hs-wl-grid";

      items.forEach((it) => {
        const pid = Number(it.productId);
        if (!Number.isFinite(pid) || pid <= 0) return;
        const href =
          typeof it.url === "string" && it.url && it.url !== "#" ? it.url : "#";
        const name = typeof it.name === "string" ? it.name : "Producto";
        const imgSrc = typeof it.image === "string" && it.image ? it.image : "";
        const excerpt = typeof it.excerpt === "string" ? it.excerpt : "";
        const variantId =
          it.variantId != null && Number.isFinite(Number(it.variantId))
            ? Number(it.variantId)
            : null;
        const sale =
          it.salePrice != null && Number.isFinite(Number(it.salePrice))
            ? Number(it.salePrice)
            : null;
        const list =
          it.listPrice != null && Number.isFinite(Number(it.listPrice))
            ? Number(it.listPrice)
            : null;

        const col = document.createElement("article");
        col.className = "hs-wl-card hs-wishlist-native-item";
        col.setAttribute("data-product-id", String(pid));

        const media = document.createElement("a");
        media.className = "hs-wl-card__media";
        media.href = href;
        media.setAttribute("title", name);
        if (href === "#") media.setAttribute("aria-disabled", "true");
        const pad = document.createElement("div");
        pad.className =
          "hs-wl-card__imgpad" + (imgSrc ? "" : " hs-wl-card__imgpad--empty");
        if (imgSrc) {
          const img = document.createElement("img");
          img.src = imgSrc;
          img.alt = name;
          img.className = "hs-wl-card__img";
          img.loading = "lazy";
          img.decoding = "async";
          pad.appendChild(img);
        }
        media.appendChild(pad);
        col.appendChild(media);

        const body = document.createElement("div");
        body.className = "hs-wl-card__body";

        const titleA = document.createElement("a");
        titleA.href = href;
        titleA.className = "hs-wl-card__titlelink";
        const h = document.createElement("h2");
        h.className = "hs-wl-card__title";
        h.textContent = name;
        titleA.appendChild(h);
        body.appendChild(titleA);

        if (excerpt) {
          const ex = document.createElement("p");
          ex.className = "hs-wl-card__excerpt";
          ex.textContent = excerpt;
          body.appendChild(ex);
        }

        const priceRow = document.createElement("div");
        priceRow.className = "hs-wl-card__prices";
        if (list != null && sale != null && list > sale) {
          var oldP = document.createElement("span");
          oldP.className = "hs-wl-card__price hs-wl-card__price--old";
          oldP.textContent = formatWishlistMoney(list);
          priceRow.appendChild(oldP);
        }
        if (sale != null) {
          var newP = document.createElement("span");
          newP.className = "hs-wl-card__price hs-wl-card__price--sale";
          newP.textContent = formatWishlistMoney(sale);
          priceRow.appendChild(newP);
        } else if (list != null) {
          var onlyP = document.createElement("span");
          onlyP.className = "hs-wl-card__price";
          onlyP.textContent = formatWishlistMoney(list);
          priceRow.appendChild(onlyP);
        } else {
          var ask = document.createElement("span");
          ask.className = "hs-wl-card__price hs-wl-card__price--muted";
          ask.textContent = "—";
          priceRow.appendChild(ask);
        }
        body.appendChild(priceRow);

        const actions = document.createElement("div");
        actions.className = "hs-wl-card__actions";

        const buy = document.createElement("button");
        buy.type = "button";
        buy.className = "hs-wl-card__btn hs-wl-card__btn--primary";
        buy.textContent = labelBuy;
        if (variantId) {
          buy.addEventListener("click", function () {
            buy.disabled = true;
            Promise.resolve(addToCart(pid, variantId, 1))
              .then(function () {
                hsToast(toastOk || "OK", "success");
              })
              .catch(function () {
                hsToast(toastFail || "Error", "error");
              })
              .finally(function () {
                buy.disabled = false;
              });
          });
        } else {
          buy.classList.add("hs-wl-card__btn--ghost");
          buy.disabled = true;
          buy.title = labelBuyDis;
        }

        const viewA = document.createElement("a");
        viewA.href = href;
        viewA.className = "hs-wl-card__btn hs-wl-card__btn--secondary";
        viewA.textContent = labelView;

        const rm = document.createElement("button");
        rm.type = "button";
        rm.className = "js-wishlist-page-remove hs-wl-card__iconbtn";
        rm.setAttribute("data-product-id", String(pid));
        rm.setAttribute("aria-label", labelRemove);
        rm.innerHTML = '<span class="hs-wl-card__heart" aria-hidden="true">♥</span>';

        actions.appendChild(buy);
        actions.appendChild(viewA);
        actions.appendChild(rm);
        body.appendChild(actions);

        col.appendChild(body);
        grid.appendChild(col);
      });

      shell.appendChild(grid);
      root.appendChild(shell);

      grid.addEventListener("click", (ev) => {
        const btn = ev.target.closest(".js-wishlist-page-remove");
        if (!btn) return;
        ev.preventDefault();
        ev.stopPropagation();
        const id = parseInt(btn.getAttribute("data-product-id") || "", 10);
        if (!id) return;
        const cust = WishlistModule.getCustomer();
        if (!cust) return;
        btn.disabled = true;
        WishlistModule.postToggle(cust, id)
          .then((d) => {
            if (d && d.inWishlist) return;
            const card = btn.closest(".hs-wishlist-native-item");
            if (card && card.parentNode) card.parentNode.removeChild(card);
            hsToast(labelRemoved, "success");
            var numEl = root.querySelector(".hs-wl-hero__stat-num");
            var left = grid.querySelectorAll(".hs-wishlist-native-item").length;
            if (numEl) numEl.textContent = String(left);
            if (!left) {
              var sh = root.querySelector(".hs-wl-shell");
              if (sh && sh.parentNode === root) root.removeChild(sh);
              renderEmptyWishlist();
            }
          })
          .catch((err) => {
            btn.disabled = false;
            const code = err && typeof err.message === "string" ? err.message : "";
            const st = err && typeof err.httpStatus === "number" ? err.httpStatus : 0;
            WishlistModule.wishlistToast(wishlistUserFacingMessage(code, st, err), true);
          });
      });
    },
  };

  // ─── Header: campana novedades + favoritos (Twig) ───────────────────────────
  // Panel dentro de #nav-hamburger queda bajo transform del modal: fixed no cubre la pantalla.
  const notifyPanelToWrap = new WeakMap();
  const notifyPanelToBackdrop = new WeakMap();

  const HeaderHacheModule = {
    _items: [],
    _loaded: false,
    _open: false,
    _openBtn: null,
    _openPanel: null,
    _inited: false,

    escape(s) {
      return String(s ?? "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;");
    },

    setBadge(badge, n, badgeAlways) {
      if (!badge) return;
      if (badgeAlways) {
        const v = n > 0 ? Math.min(99, n) : 1;
        badge.textContent = String(v);
        badge.classList.remove("d-none");
        return;
      }
      if (n > 0) {
        badge.textContent = String(Math.min(99, n));
        badge.classList.remove("d-none");
      } else {
        badge.textContent = "";
        badge.classList.add("d-none");
      }
    },

    renderList(listEl, items, emptyMsg, labelNew) {
      if (!listEl) return;
      listEl.innerHTML = "";
      if (!items.length) {
        listEl.innerHTML =
          '<p class="font-small text-muted mb-0 px-2 py-3 text-center">' + this.escape(emptyMsg) + "</p>";
        return;
      }
      items.forEach((it) => {
        const href = typeof it.url === "string" && it.url ? it.url : "#";
        const name = typeof it.name === "string" ? it.name : "Producto";
        const img = typeof it.image === "string" && it.image ? it.image : "";
        const row = document.createElement("a");
        row.href = href;
        row.className =
          "hache-notify-row d-flex align-items-center text-decoration-none text-reset py-2 px-2 rounded";
        if (href === "#") row.setAttribute("aria-disabled", "true");
        const thumb = document.createElement("div");
        thumb.className = "hache-notify-row__thumb flex-shrink-0 mr-2";
        if (img) {
          const im = document.createElement("img");
          im.src = img;
          im.alt = "";
          im.className = "rounded";
          im.loading = "lazy";
          thumb.appendChild(im);
        }
        const text = document.createElement("div");
        text.className = "min-w-0 flex-grow-1";
        const title = document.createElement("div");
        title.className = "font-weight-semibold font-small text-truncate";
        title.textContent = name;
        const sub = document.createElement("div");
        sub.className = "text-muted text-uppercase";
        sub.style.fontSize = "0.65rem";
        sub.style.letterSpacing = "0.06em";
        sub.textContent = labelNew;
        text.appendChild(title);
        text.appendChild(sub);
        row.appendChild(thumb);
        row.appendChild(text);
        listEl.appendChild(row);
      });
    },

    _backdropFor(panel) {
      if (!panel) return null;
      const fromMap = notifyPanelToBackdrop.get(panel);
      if (fromMap) return fromMap;
      const wrap = panel.closest(".hache-notify-wrap");
      return wrap ? wrap.querySelector(".js-hache-notify-backdrop") : null;
    },

    closePanel(btn, panel) {
      if (!panel) return;
      const bd = this._backdropFor(panel);
      panel.hidden = true;
      if (bd) {
        bd.hidden = true;
        bd.setAttribute("aria-hidden", "true");
      }
      if (panel.dataset.hachePortaled === "1" && btn) {
        if (bd) btn.after(bd, panel);
        else btn.after(panel);
        delete panel.dataset.hachePortaled;
      }
      this._open = false;
      if (this._openPanel === panel) {
        this._openBtn = null;
        this._openPanel = null;
      }
      if (btn) {
        btn.setAttribute("aria-expanded", "false");
      }
    },

    openPanel(btn, panel) {
      if (!panel) return;
      const bd = this._backdropFor(panel);
      const openFromHamburger = btn && btn.closest("#nav-hamburger");
      if (openFromHamburger && panel.dataset.hachePortaled !== "1") {
        panel.dataset.hachePortaled = "1";
        if (bd) document.body.appendChild(bd);
        document.body.appendChild(panel);
      }
      if (bd) {
        bd.hidden = false;
        bd.setAttribute("aria-hidden", "false");
      }
      panel.hidden = false;
      this._open = true;
      this._openBtn = btn;
      this._openPanel = panel;
      if (btn) btn.setAttribute("aria-expanded", "true");
      const listEl = panel.querySelector(".js-hache-notify-list");
      this.renderList(
        listEl,
        this._items,
        (btn && btn.getAttribute("data-empty")) || "",
        (btn && btn.getAttribute("data-label-new")) || "Nuevo"
      );
    },

    closeAllPanels() {
      document.querySelectorAll(".js-hache-notify-panel").forEach((panel) => {
        const wrap = notifyPanelToWrap.get(panel);
        const btn = wrap ? wrap.querySelector(".js-hache-notify-toggle") : null;
        this.closePanel(btn, panel);
      });
    },

    init() {
      if (this._inited) return;
      const wraps = document.querySelectorAll(".hache-notify-wrap");
      if (!wraps.length) return;

      wraps.forEach((wrap) => {
        const p = wrap.querySelector(".js-hache-notify-panel");
        const bdrop = wrap.querySelector(".js-hache-notify-backdrop");
        if (p) {
          notifyPanelToWrap.set(p, wrap);
          wrap._hacheNotifyPanelEl = p;
        }
        if (p && bdrop) notifyPanelToBackdrop.set(p, bdrop);
      });

      const firstBtn = wraps[0].querySelector(".js-hache-notify-toggle");
      const firstPanel = wraps[0]._hacheNotifyPanelEl || wraps[0].querySelector(".js-hache-notify-panel");
      if (!firstBtn || !firstPanel) return;

      const days = parseInt(firstBtn.getAttribute("data-notify-days") || "30", 10) || 30;
      const limit = parseInt(firstBtn.getAttribute("data-notify-limit") || "10", 10) || 10;
      const badgeAlways = firstBtn.getAttribute("data-badge-always") === "1";

      const allBadges = () => Array.from(wraps).map((w) => w.querySelector(".js-hache-notify-badge"));

      allBadges().forEach((badge) => {
        if (badge) this.setBadge(badge, 0, badgeAlways);
      });

      const refresh = () => {
        const sid = getStoreId();
        if (!sid) {
          allBadges().forEach((badge) => this.setBadge(badge, 0, badgeAlways));
          return Promise.resolve();
        }
        const url =
          BACKEND_URL +
          "/api/storefront/recent-products?storeId=" +
          encodeURIComponent(sid) +
          "&days=" +
          encodeURIComponent(String(days)) +
          "&limit=" +
          encodeURIComponent(String(limit));
        return fetch(url, { mode: "cors" })
          .then((r) => r.json())
          .then((data) => {
            const items = Array.isArray(data.items) ? data.items : [];
            this._items = items;
            this._loaded = true;
            allBadges().forEach((badge) => this.setBadge(badge, items.length, badgeAlways));
            const activePanel = this._openPanel;
            if (this._open && activePanel) {
              const listEl = activePanel.querySelector(".js-hache-notify-list");
              const b = this._openBtn;
              this.renderList(
                listEl,
                items,
                (b && b.getAttribute("data-empty")) || "",
                (b && b.getAttribute("data-label-new")) || "Nuevo"
              );
            }
          })
          .catch(() => {
            this._items = [];
            this._loaded = true;
            if (badgeAlways) {
              allBadges().forEach((badge) => {
                if (!badge) return;
                badge.textContent = "!";
                badge.classList.remove("d-none");
              });
            }
          });
      };

      wraps.forEach((wrap) => {
        const btn = wrap.querySelector(".js-hache-notify-toggle");
        const panel = wrap._hacheNotifyPanelEl || wrap.querySelector(".js-hache-notify-panel");
        if (!btn || !panel) return;

        btn.addEventListener("click", (ev) => {
          ev.preventDefault();
          ev.stopPropagation();
          if (!panel.hidden) {
            this.closePanel(btn, panel);
            return;
          }
          wraps.forEach((w) => {
            if (w === wrap) return;
            const ob = w.querySelector(".js-hache-notify-toggle");
            const op = w._hacheNotifyPanelEl || w.querySelector(".js-hache-notify-panel");
            this.closePanel(ob, op);
          });
          const open = () => {
            window.requestAnimationFrame(() => this.openPanel(btn, panel));
          };
          if (!this._loaded) {
            refresh().catch(() => {}).finally(open);
          } else {
            open();
          }
        });
      });

      document.addEventListener(
        "click",
        (ev) => {
          if (!this._open || !this._openPanel || this._openPanel.hidden) return;
          const t = ev.target;
          if (t && t.closest && t.closest(".js-hache-notify-backdrop")) {
            this.closeAllPanels();
            return;
          }
          if (this._openBtn && this._openBtn.contains(t)) return;
          if (this._openPanel && this._openPanel.contains(t)) return;
          this.closeAllPanels();
        },
        true
      );

      document.addEventListener("keydown", (ev) => {
        if (ev.key === "Escape") this.closeAllPanels();
      });

      setTimeout(refresh, 600);
      setTimeout(refresh, 3500);

      this._inited = true;
    },
  };

  // ─── BOOT ──────────────────────────────────────────────────────────────────

  function boot() {
    const run = () => {
      injectHacheSuiteStyles();
      const pageType = getCurrentPageType();
      if (typeof window !== "undefined" && window.HACHE_DEBUG) {
        console.log("[HacheSuite] Iniciando — página:", pageType, "| tienda:", getStoreId() || "(sin id aún)");
      }

      trackConversionPageViewsOnce();

      // Cart Gifts — run on all pages except bundle page
      if (pageType !== "bundle") {
        CartGiftModule.init().catch(console.warn);
      }

      // Category Gate — only on category pages
      if (pageType === "category") {
        CategoryGateModule.init().catch(console.warn);
      }

      // Dynamic Pricing — on product and category pages
      if (pageType === "product" || pageType === "category" || pageType === "home") {
        DynamicPricingModule.init().catch(console.warn);
      }

      // Bundle Page — /combos, /pages/combos, /paginas/combos
      if (pageType === "bundle") {
        BundlePageModule.init().catch(console.warn);
      }

      // Wishlist — PDP button + aplicar pendiente tras login en cualquier pagina
      WishlistModule.init().catch(console.warn);

      // Wishlist — pagina institucional (handle configurado en el tema)
      WishlistPageModule.init().catch(console.warn);

      // Header: campana novedades (Twig)
      try {
        HeaderHacheModule.init();
      } catch (e) {
        console.warn("[HacheSuite][Header]", e);
      }
      window.setTimeout(() => {
        try {
          HeaderHacheModule.init();
        } catch (e) {
          console.warn("[HacheSuite][Header reintento]", e);
        }
      }, 1200);
    };

    if (window.LS && window.LS.ready && typeof window.LS.ready.then === "function") {
      window.LS.ready.then(run).catch(run);
    } else {
      run();
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})(window);
