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
    const id =
      window.LS?.store?.id?.toString() ||
      window.store_id?.toString() ||
      "";
    return id.trim();
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
    // Método 1: API nativa de Tiendanube (recomendado)
    if (window.LS && window.LS.Cart && typeof window.LS.Cart.addItem === "function") {
      return window.LS.Cart.addItem({
        product_id: productId,
        variant_id: variantId,
        quantity: quantity,
      });
    }
    // Método 2: API REST de Tiendanube (fallback)
    return fetch("/api/storefront/cart/items", {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        add: [{ product_id: productId, variant_id: variantId, quantity: quantity }],
      }),
    }).then(function(r) { return r.json(); });
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
    const path = window.location.pathname;
    if (path.startsWith("/pages/combos") || path.startsWith("/paginas/combos")) return "bundle";
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

  function readCanonicalPriceFromEl(el) {
    const content = el.getAttribute("content");
    if (content != null && content !== "") {
      const n = Number(content);
      if (Number.isFinite(n) && n > 0) return n;
    }
    const dp = el.getAttribute("data-product-price");
    if (dp != null && dp !== "") {
      const n = Number(String(dp).replace(",", "."));
      if (Number.isFinite(n) && n > 0) return n;
    }
    const langEs = (document.documentElement.getAttribute("lang") || "").toLowerCase().startsWith("es");
    return parseLocaleMoneyTextToNumber(el.textContent || "", langEs);
  }

  // ─── MODULE 1: CART GIFT ───────────────────────────────────────────────────

  const CartGiftModule = {
    appliedGiftIds: new Set(),

    async init() {
      await this.check();
      // Re-check on cart change events (Tiendanube fires custom events)
      document.addEventListener("cart:update", () => this.check());
      document.addEventListener("cart:itemAdded", () => this.check());
      document.addEventListener("cart:itemRemoved", () => this.check());
    },

    async check() {
      if (!getStoreId()) return;
      const total = getCartTotal();
      if (total <= 0) return;

      let gifts;
      const cached = lsGet("cart_gifts_" + Math.floor(total / 100)); // check subtotal range
      if (cached) {
        gifts = cached;
      } else {
        try {
          const res = await apiGet(
            `/api/storefront/cart-gifts?storeId=${getStoreId()}&total=${total}`
          );
          gifts = res.gifts || [];
          lsSet("cart_gifts_" + Math.floor(total / 100), gifts, 10 * 1000); // 10 seg cache para desarrollo
        } catch (e) {
          console.warn("[HacheSuite][CartGift]", e);
          return;
        }
      }

      // Check current cart items
      let cartItems = window.LS?.cart?.items || [];
      // Fallback: if LS.cart isn't updated instantly, we might need to rely on the DOM or recent additions
      
      // Apply gifts not yet in cart
      for (const gift of gifts) {
        if (this.appliedGiftIds.has(gift.id)) continue;
        
        let giftInCart = cartItems.find((i) => i.id === gift.giftVariantId || i.product_id === gift.giftProductId);
        if (giftInCart) {
          this.appliedGiftIds.add(gift.id);
          continue;
        }

        try {
          await addToCart(gift.giftProductId, gift.giftVariantId, gift.giftQty);
          this.appliedGiftIds.add(gift.id);
          this.showGiftToast(gift.name || "¡Tu regalo fue agregado al carrito! 🎁");
        } catch (err) {
          console.warn("[HacheSuite][CartGift] Error agregando regalo:", err);
        }
      }
    },

    showGiftToast(message) {
      const toast = document.createElement("div");
      toast.style.cssText = `
        position:fixed;bottom:24px;left:50%;transform:translateX(-50%);
        background:#22c55e;color:#fff;padding:12px 24px;border-radius:99px;
        font-family:inherit;font-size:14px;font-weight:600;z-index:99999;
        box-shadow:0 4px 24px rgba(0,0,0,0.2);transition:opacity 0.5s;
      `;
      toast.textContent = message;
      document.body.appendChild(toast);
      setTimeout(() => {
        toast.style.opacity = "0";
        setTimeout(() => toast.remove(), 500);
      }, 3500);
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

      const overlay = document.createElement("div");
      overlay.id = "hs-gate-overlay";
      overlay.style.cssText = `
        position:fixed;inset:0;z-index:999999;
        display:flex;align-items:center;justify-content:center;
        background:rgba(10,10,15,0.85);backdrop-filter:blur(4px);
      `;

      overlay.innerHTML = `
        <div style="
          background:#12121a;border:1px solid #2a2a3d;border-radius:16px;
          padding:2.5rem;width:100%;max-width:380px;text-align:center;
          box-shadow:0 24px 80px rgba(0,0,0,0.6);
          font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;
        ">
          <div style="font-size:3rem;margin-bottom:1rem;">🔒</div>
          <h2 style="color:#e8e8f0;font-size:1.2rem;font-weight:700;margin-bottom:0.5rem;">
            Contenido exclusivo
          </h2>
          <p style="color:#8888aa;font-size:0.875rem;margin-bottom:1.5rem;line-height:1.5;">
            Esta categoría es de acceso restringido. Ingresá la contraseña para continuar.
          </p>
          <input
            id="hs-gate-input"
            type="password"
            placeholder="Contraseña de acceso"
            style="
              width:100%;padding:12px 16px;background:#1a1a26;color:#e8e8f0;
              border:1px solid #2a2a3d;border-radius:8px;font-size:0.875rem;
              outline:none;box-sizing:border-box;margin-bottom:0.75rem;
              font-family:inherit;
            "
          />
          <div id="hs-gate-error" style="color:#ef4444;font-size:0.8rem;margin-bottom:0.75rem;display:none;">
            Contraseña incorrecta
          </div>
          <button
            id="hs-gate-btn"
            style="
              width:100%;padding:12px;background:linear-gradient(135deg,#7c5cfc,#a78bfa);
              color:#fff;border:none;border-radius:8px;font-size:0.875rem;font-weight:600;
              cursor:pointer;font-family:inherit;
            "
          >
            Acceder
          </button>
        </div>
      `;

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

      var wrapper = document.createElement("span");
      wrapper.style.display = "inline-flex";
      wrapper.style.alignItems = "center";
      wrapper.style.gap = "6px";
      wrapper.style.flexWrap = "wrap";
      wrapper.innerHTML =
        '<span style="font-weight:700;color:#22c55e;">' +
        sym +
        fmtNum(discounted) +
        "</span>" +
        '<span style="text-decoration:line-through;color:#888;font-size:0.85em;">' +
        sym +
        fmtNum(original) +
        "</span>" +
        '<span style="background:rgba(34,197,94,0.15);color:#22c55e;padding:2px 7px;border-radius:99px;font-size:0.7em;font-weight:700;">-' +
        pct +
        "%</span>";

      el.textContent = "";
      el.appendChild(wrapper);
      el.setAttribute("data-hs-effective-price", String(discounted));

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
    async init() {
      const container = document.getElementById("hs-bundles-container");
      if (!container) return;
      if (!getStoreId()) return;

      container.innerHTML = `<p style="color:#888;text-align:center;padding:2rem;">Cargando combos...</p>`;

      let data;
      const cached = lsGet("bundles_temp");
      if (cached) {
        data = cached;
      } else {
        try {
          data = await apiGet(`/api/storefront/bundles?storeId=${getStoreId()}`);
          lsSet("bundles_temp", data, 10 * 1000); // 10 seg cache para desarrollo (forzado a nuevo key)
        } catch (e) {
          container.innerHTML = `<p style="color:#ef4444;text-align:center;">No se pudieron cargar los combos.</p>`;
          return;
        }
      }

      const bundles = data.bundles || [];
      if (bundles.length === 0) {
        container.innerHTML = `<p style="color:#888;text-align:center;padding:2rem;">No hay combos disponibles por el momento.</p>`;
        return;
      }

      container.innerHTML = "";
      const grid = document.createElement("div");
      grid.style.cssText = `
        display:grid;
        grid-template-columns:repeat(auto-fill,minmax(280px,1fr));
        gap:1.5rem;
        padding:1rem 0;
      `;

      for (const bundle of bundles) {
        const card = this.renderCard(bundle);
        grid.appendChild(card);
      }
      container.appendChild(grid);
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
      card.style.cssText = `
        background:#fff;border:1px solid #e5e5e5;border-radius:12px;
        overflow:hidden;display:flex;flex-direction:column;
        box-shadow:0 2px 8px rgba(0,0,0,0.06);
        transition:transform 0.18s,box-shadow 0.18s;
      `;
      card.onmouseenter = () => {
        card.style.transform = "translateY(-3px)";
        card.style.boxShadow = "0 8px 24px rgba(0,0,0,0.12)";
      };
      card.onmouseleave = () => {
        card.style.transform = "";
        card.style.boxShadow = "0 2px 8px rgba(0,0,0,0.06)";
      };

      const imgHtml = bundle.imageUrl
        ? `<img src="${bundle.imageUrl}" alt="${bundle.name}" style="width:100%;height:200px;object-fit:cover;" />`
        : `<div style="width:100%;height:160px;background:linear-gradient(135deg,#f0f0fa,#e0e0f5);display:flex;align-items:center;justify-content:center;font-size:3rem;">📦</div>`;

      const productsHtml = bundle.products
        .map(
          (p) =>
            `<li style="font-size:0.85rem;color:#555;padding:4px 0;display:flex;justify-content:space-between;">
               <span>× ${p.quantity} ${p.productName}</span>
               <span style="color:#999;">$${p.unitPrice.toLocaleString()}</span>
             </li>`
        )
        .join("");

      card.innerHTML = `
        ${imgHtml}
        <div style="padding:1.25rem;flex:1;display:flex;flex-direction:column;">
          <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:0.5rem;margin-bottom:0.5rem;">
            <h3 style="font-size:1rem;font-weight:700;color:#111;line-height:1.3;">${bundle.name}</h3>
            ${saving > 0 ? `<span style="background:#dcfce7;color:#16a34a;padding:3px 10px;border-radius:99px;font-size:0.7rem;font-weight:700;flex-shrink:0;">-${saving}%</span>` : ""}
          </div>
          ${bundle.description ? `<p style="font-size:0.85rem;color:#666;margin-bottom:0.75rem;line-height:1.5;">${bundle.description}</p>` : ""}
          <ul style="list-style:none;padding:0;margin:0 0 1rem;border-top:1px solid #f0f0f0;padding-top:0.75rem;">
            ${productsHtml}
          </ul>
          <div style="margin-top:auto;">
            ${totalOriginal > 0 ? `<div style="font-size:0.85rem;color:#999;text-decoration:line-through;margin-bottom:2px;">$${totalOriginal.toLocaleString()}</div>` : ""}
            <div style="font-size:1.4rem;font-weight:800;color:#111;margin-bottom:0.75rem;">$${bundle.comboPrice.toLocaleString()}</div>
            <button
              data-bundle-id="${bundle.id}"
              style="
                width:100%;padding:12px;background:#111;color:#fff;
                border:none;border-radius:8px;font-size:0.9rem;font-weight:600;
                cursor:pointer;transition:background 0.18s;font-family:inherit;
              "
            >
              Agregar combo al carrito
            </button>
          </div>
        </div>
      `;

      const btn = card.querySelector(`[data-bundle-id="${bundle.id}"]`);
      btn.addEventListener("click", () => this.addBundleToCart(bundle, btn));

      return card;
    },

    async addBundleToCart(bundle, btn) {
      btn.textContent = "Agregando...";
      btn.disabled = true;

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
        btn.style.background = "#22c55e";
        setTimeout(() => {
          btn.textContent = "Agregar combo al carrito";
          btn.style.background = "#111";
          btn.disabled = false;
        }, 2500);
        // Fire cart update event for other modules
        document.dispatchEvent(new CustomEvent("cart:update"));
      } else {
        btn.textContent = "Error — intentá de nuevo";
        btn.style.background = "#ef4444";
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
      const el = document.createElement("div");
      el.setAttribute("role", "status");
      el.style.cssText =
        "position:fixed;bottom:88px;left:50%;transform:translateX(-50%);max-width:min(420px,92vw);" +
        "padding:12px 16px;border-radius:12px;font:600 13px/1.35 system-ui,sans-serif;z-index:99999;" +
        "box-shadow:0 8px 28px rgba(0,0,0,.12);" +
        (isError ? "background:#111;color:#fff;" : "background:#fff;color:#111;border:1px solid rgba(0,0,0,.08);");
      el.textContent = msg;
      document.body.appendChild(el);
      setTimeout(() => {
        el.style.opacity = "0";
        el.style.transition = "opacity .35s ease";
        setTimeout(() => el.remove(), 400);
      }, 3200);
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
          this.wishlistToast(
            data.inWishlist ? "Guardado en favoritos" : "Quitado de favoritos",
            false
          );
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

  const WishlistPageModule = {
    async init() {
      const root = document.getElementById("hs-wishlist-page");
      if (!root || root.getAttribute("data-logged") !== "1") return;

      const customer = WishlistModule.getCustomer();
      if (!customer) return;

      const storeId = getStoreId();
      if (!storeId) {
        const err = root.getAttribute("data-msg-error") || "Error";
        root.innerHTML = '<p class="text-muted text-center py-4">' + escapeHtmlWishlist(err) + "</p>";
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
        const load = root.querySelector(".hs-wishlist-loading");
        if (load) load.remove();
        root.innerHTML = '<p class="text-muted text-center py-4">' + escapeHtmlWishlist(line) + "</p>";
        return;
      }

      const items = Array.isArray(data.items) ? data.items : [];
      const loadEl = root.querySelector(".hs-wishlist-loading");
      if (loadEl) loadEl.remove();

      if (!items.length) {
        const empty = root.getAttribute("data-msg-empty") || "";
        root.innerHTML =
          '<p class="text-muted text-center py-4 mb-0">' + escapeHtmlWishlist(empty) + "</p>";
        return;
      }

      const grid = document.createElement("div");
      grid.className = "row hs-wishlist-grid";

      items.forEach((it) => {
        const col = document.createElement("div");
        col.className = "col-6 col-md-4 col-lg-3 mb-4";
        const href =
          typeof it.url === "string" && it.url && it.url !== "#" ? it.url : "#";
        const name = typeof it.name === "string" ? it.name : "Producto";
        const imgSrc = typeof it.image === "string" && it.image ? it.image : "";

        const card = document.createElement("article");
        card.className = "hs-wishlist-card h-100 border bg-white";

        const link = document.createElement("a");
        link.className = "d-block text-reset text-decoration-none h-100 p-2 p-md-3";
        link.href = href;
        if (href === "#") link.setAttribute("aria-disabled", "true");

        if (imgSrc) {
          const wrap = document.createElement("div");
          wrap.className = "hs-wishlist-card__img-wrap mb-2";
          const img = document.createElement("img");
          img.src = imgSrc;
          img.alt = "";
          img.className = "img-fluid w-100 hs-wishlist-card__img";
          img.loading = "lazy";
          wrap.appendChild(img);
          link.appendChild(wrap);
        }

        const title = document.createElement("h3");
        title.className = "font-small font-weight-semibold mb-0 text-uppercase";
        title.style.letterSpacing = "0.04em";
        title.style.lineHeight = "1.35";
        title.textContent = name;

        link.appendChild(title);
        card.appendChild(link);
        col.appendChild(card);
        grid.appendChild(col);
      });

      root.appendChild(grid);
    },
  };

  // ─── BOOT ──────────────────────────────────────────────────────────────────

  function boot() {
    const run = () => {
      const pageType = getCurrentPageType();
      console.log("[HacheSuite] Iniciando — página:", pageType, "| tienda:", getStoreId() || "(sin id aún)");

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

      // Bundle Page — only on /pages/combos
      if (pageType === "bundle") {
        BundlePageModule.init().catch(console.warn);
      }

      // Wishlist — PDP button + aplicar pendiente tras login en cualquier pagina
      WishlistModule.init().catch(console.warn);

      // Wishlist — pagina institucional (handle configurado en el tema)
      WishlistPageModule.init().catch(console.warn);
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
