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
 */

(function (window) {
  "use strict";

  // ─── CONFIG ────────────────────────────────────────────────────────────────
  const BACKEND_URL =
    window.HACHE_BACKEND_URL ||
    "https://tiendaoficial-tiendanube-production.up.railway.app";

  const STORE_ID =
    window.LS?.store?.id?.toString() ||
    window.store_id?.toString() ||
    "";

  if (!STORE_ID) {
    console.warn("[HacheSuite] storeId no encontrado — módulos deshabilitados.");
    return;
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
    // Tiendanube expone LS.cart.total o en el DOM
    if (window.LS?.cart?.total) return parseFloat(window.LS.cart.total);
    const el = document.querySelector("[data-store-cart-total]");
    if (el) return parseFloat(el.textContent.replace(/[^0-9.]/g, ""));
    return 0;
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
      const total = getCartTotal();
      if (total <= 0) return;

      let gifts;
      const cached = lsGet("cart_gifts_" + Math.floor(total / 1000));
      if (cached) {
        gifts = cached;
      } else {
        try {
          const res = await apiGet(
            `/api/storefront/cart-gifts?storeId=${STORE_ID}&total=${total}`
          );
          gifts = res.gifts || [];
          lsSet("cart_gifts_" + Math.floor(total / 1000), gifts, 5 * 60 * 1000); // 5 min cache
        } catch (e) {
          console.warn("[HacheSuite][CartGift]", e);
          return;
        }
      }

      // Apply gifts not yet in cart
      for (const gift of gifts) {
        if (this.appliedGiftIds.has(gift.id)) continue;
        const sessionKey = `gift_applied_${gift.id}`;
        if (lsGet(sessionKey)) continue;

        try {
          await addToCart(gift.giftProductId, gift.giftVariantId, gift.giftQty);
          this.appliedGiftIds.add(gift.id);
          lsSet(sessionKey, true, 30 * 60 * 1000); // 30 min session
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
            `/api/storefront/category-gate?storeId=${STORE_ID}&categoryId=${categoryId}`
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
            storeId: STORE_ID,
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
          storeId: STORE_ID,
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
      const productIds = this.collectProductIds();
      if (productIds.length === 0) return;

      const visitCount = incrementVisitCount();
      const cacheKey = `dyn_prices_v3_${productIds.sort().join("_")}`;
      let data = lsGet(cacheKey);

      if (!data) {
        try {
          data = await apiGet(
            `/api/storefront/dynamic-prices?storeId=${STORE_ID}&products=${productIds.join(",")}&visitCount=${visitCount}`
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

      container.innerHTML = `<p style="color:#888;text-align:center;padding:2rem;">Cargando combos...</p>`;

      let data;
      const cached = lsGet("bundles");
      if (cached) {
        data = cached;
      } else {
        try {
          data = await apiGet(`/api/storefront/bundles?storeId=${STORE_ID}`);
          lsSet("bundles", data, 30 * 60 * 1000); // 30 min
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

  // ─── BOOT ──────────────────────────────────────────────────────────────────

  function boot() {
    const pageType = getCurrentPageType();
    console.log("[HacheSuite] Iniciando — página:", pageType, "| tienda:", STORE_ID);

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
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})(window);
