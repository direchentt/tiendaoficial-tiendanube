"use client";

import { TnProductPicker } from "@/components/admin/TnProductPicker";
import type { TNProduct, TNVariant } from "@/components/admin/tn-product-picker-utils";
import { variantLabel } from "@/components/admin/tn-product-picker-utils";
import { adminFetch } from "@/lib/admin-fetch";
import { useCallback, useEffect, useState } from "react";

type Landing = {
  id: string;
  slug: string;
  title: string;
  intro: string | null;
  enabled: boolean;
  _count?: { bundles: number };
};

type BundleProduct = {
  id: string;
  productId: number;
  variantId: number;
  customerPicksVariant?: boolean;
  productName: string;
  unitPrice: number;
  quantity: number;
  thumbnailUrl?: string | null;
};

type Bundle = {
  id: string;
  name: string;
  comboPrice: number;
  enabled: boolean;
  products: BundleProduct[];
};

type ProductRow = {
  id: string;
  productId: number;
  variantId: number;
  customerPicksVariant: boolean;
  productName: string;
  unitPrice: string;
  quantity: string;
  thumbnailUrl?: string;
};

export default function BundlesV2Page() {
  const [landings, setLandings] = useState<Landing[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [bundles, setBundles] = useState<Bundle[]>([]);
  const [loadingBundles, setLoadingBundles] = useState(false);

  const [lpSlug, setLpSlug] = useState("");
  const [lpTitle, setLpTitle] = useState("");
  const [lpIntro, setLpIntro] = useState("");
  const [lpSaving, setLpSaving] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  const [formName, setFormName] = useState("");
  const [formPrice, setFormPrice] = useState("");
  const [formDesc, setFormDesc] = useState("");
  const [formImg, setFormImg] = useState("");
  const [products, setProducts] = useState<ProductRow[]>([]);
  const [comboSaving, setComboSaving] = useState(false);

  const selected = landings.find((l) => l.id === selectedId) ?? null;

  const loadLandings = useCallback(async () => {
    const r = await adminFetch("/api/admin/combo-landings");
    if (r.ok) setLandings(await r.json());
    setLoading(false);
  }, []);

  useEffect(() => {
    loadLandings();
  }, [loadLandings]);

  useEffect(() => {
    if (!selectedId) {
      setBundles([]);
      return;
    }
    let cancelled = false;
    (async () => {
      setLoadingBundles(true);
      const r = await adminFetch("/api/admin/bundles?landingPageId=" + encodeURIComponent(selectedId));
      if (!cancelled && r.ok) setBundles(await r.json());
      if (!cancelled) setLoadingBundles(false);
    })();
    return () => {
      cancelled = true;
    };
  }, [selectedId]);

  async function createLanding(e: React.FormEvent) {
    e.preventDefault();
    setLpSaving(true);
    setMsg(null);
    const r = await adminFetch("/api/admin/combo-landings", {
      method: "POST",
      body: JSON.stringify({
        slug: lpSlug.trim().toLowerCase(),
        title: lpTitle.trim(),
        intro: lpIntro.trim() || null,
        enabled: true,
      }),
    });
    setLpSaving(false);
    if (!r.ok) {
      const err = await r.json().catch(() => ({}));
      setMsg(typeof err.error === "string" ? err.error : JSON.stringify(err));
      return;
    }
    const row = await r.json();
    setLpSlug("");
    setLpTitle("");
    setLpIntro("");
    await loadLandings();
    setSelectedId(row.id);
    setMsg("Página creada. En Tiendanube creá una página institucional con el mismo handle (slug) para verla en la tienda.");
  }

  async function deleteLanding(id: string) {
    if (!confirm("¿Eliminar esta página y desvincular sus combos?")) return;
    await adminFetch("/api/admin/combo-landings/" + id, { method: "DELETE" });
    if (selectedId === id) setSelectedId(null);
    loadLandings();
  }

  function addProductFromTn(p: TNProduct, v: TNVariant) {
    const thumb = p.images[0] ?? "";
    setProducts((prev) => [
      ...prev,
      {
        id: Math.random().toString(36).slice(2),
        productId: p.id,
        variantId: v.id,
        customerPicksVariant: false,
        productName: p.name + (p.variants.length > 1 ? ` (${variantLabel(v)})` : ""),
        unitPrice: v.price,
        quantity: "1",
        thumbnailUrl: thumb || undefined,
      },
    ]);
  }

  function addProductFromTnCustomerChoice(p: TNProduct) {
    if (p.variants.length === 0) return;
    const first = p.variants[0];
    const nums = p.variants.map((v) => {
      const n = parseFloat(String(v.price).replace(/\s/g, "").replace(",", "."));
      return Number.isFinite(n) ? n : 0;
    });
    const minP = nums.length ? Math.min(...nums) : parseFloat(String(first.price).replace(",", ".")) || 0;
    const multi = p.variants.length > 1;
    const thumb = p.images[0] ?? "";
    setProducts((prev) => [
      ...prev,
      {
        id: Math.random().toString(36).slice(2),
        productId: p.id,
        variantId: first.id,
        customerPicksVariant: multi,
        productName: multi ? `${p.name} (cliente elige variante)` : p.name,
        unitPrice: String(multi ? minP : parseFloat(String(first.price).replace(",", ".")) || 0),
        quantity: "1",
        thumbnailUrl: thumb || undefined,
      },
    ]);
  }

  async function createComboOnLanding(e: React.FormEvent) {
    e.preventDefault();
    if (!selectedId) return;
    setComboSaving(true);
    setMsg(null);
    const valid = products.filter((p) => p.productId > 0);
    if (valid.length === 0) {
      setMsg("Agregá al menos un producto al combo.");
      setComboSaving(false);
      return;
    }
    const total = valid.reduce(
      (acc, p) => acc + (parseFloat(p.unitPrice) || 0) * (parseInt(p.quantity) || 1),
      0
    );
    const parsedPrice = parseFloat(formPrice);
    const r = await adminFetch("/api/admin/bundles", {
      method: "POST",
      body: JSON.stringify({
        name: formName.trim(),
        description: formDesc.trim() || undefined,
        comboPrice: !isNaN(parsedPrice) && parsedPrice > 0 ? parsedPrice : total,
        imageUrl: formImg.trim() || undefined,
        enabled: true,
        landingPageId: selectedId,
        products: valid.map((p) => ({
          productId: p.productId,
          variantId: p.variantId,
          customerPicksVariant: p.customerPicksVariant,
          productName: p.productName,
          unitPrice: parseFloat(p.unitPrice) || 0,
          quantity: parseInt(p.quantity, 10) || 1,
          thumbnailUrl: p.thumbnailUrl || null,
        })),
      }),
    });
    setComboSaving(false);
    if (!r.ok) {
      const err = await r.json().catch(() => ({}));
      setMsg(JSON.stringify(err, null, 2));
      return;
    }
    setFormName("");
    setFormPrice("");
    setFormDesc("");
    setFormImg("");
    setProducts([]);
    setMsg("Combo creado en esta página.");
    const br = await adminFetch("/api/admin/bundles?landingPageId=" + encodeURIComponent(selectedId));
    if (br.ok) setBundles(await br.json());
  }

  async function toggleBundle(b: Bundle) {
    await adminFetch("/api/admin/bundles/" + b.id, {
      method: "PATCH",
      body: JSON.stringify({ enabled: !b.enabled }),
    });
    const br = await adminFetch("/api/admin/bundles?landingPageId=" + encodeURIComponent(selectedId!));
    if (br.ok) setBundles(await br.json());
  }

  async function deleteBundle(id: string) {
    if (!confirm("¿Eliminar este combo?")) return;
    await adminFetch("/api/admin/bundles/" + id, { method: "DELETE" });
    const br = await adminFetch("/api/admin/bundles?landingPageId=" + encodeURIComponent(selectedId!));
    if (br.ok) setBundles(await br.json());
  }

  return (
    <div>
      <div style={{ marginBottom: "1.5rem" }}>
        <h1 style={{ display: "flex", alignItems: "center", gap: "0.5rem" }}>
          <span>📄</span> Combos v2 — páginas
        </h1>
        <p style={{ color: "var(--text-muted)", fontSize: "0.875rem", maxWidth: "56rem", lineHeight: 1.6 }}>
          Cada <strong>página</strong> tiene un <code>slug</code> igual al <strong>handle</strong> de la página en Tiendanube
          (ej. <code>bundle</code> → URL <code>/bundle/</code>). Los combos que crees acá solo se muestran en esa URL; el
          tema llama a <code>GET /api/storefront/bundles/v2?storeId=…&amp;slug=…</code> con el mismo valor. La grilla en
          la tienda mantiene el look Pas Normal.
        </p>
      </div>

      {msg && (
        <div
          style={{
            marginBottom: "1rem",
            padding: "0.75rem 1rem",
            background: "rgba(124,92,252,0.12)",
            border: "1px solid rgba(124,92,252,0.35)",
            borderRadius: 8,
            fontSize: "0.85rem",
            whiteSpace: "pre-wrap",
          }}
        >
          {msg}
        </div>
      )}

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "minmax(0, 1fr) minmax(0, 1.1fr)",
          gap: "1.25rem",
          alignItems: "start",
        }}
      >
        <div style={card}>
          <h2 style={{ marginBottom: "0.75rem" }}>Nueva página</h2>
          <form onSubmit={createLanding} style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
            <label style={lab}>
              Slug (handle TN)
              <input
                required
                placeholder="bundle"
                value={lpSlug}
                onChange={(e) => setLpSlug(e.target.value)}
                pattern="[a-z0-9]+(-[a-z0-9]+)*"
                title="minúsculas, números y guiones"
              />
            </label>
            <label style={lab}>
              Título (encabezado en la tienda)
              <input required placeholder="Bundles & combos" value={lpTitle} onChange={(e) => setLpTitle(e.target.value)} />
            </label>
            <label style={lab}>
              Intro (texto plano, opcional)
              <textarea rows={3} value={lpIntro} onChange={(e) => setLpIntro(e.target.value)} style={{ resize: "vertical" }} />
            </label>
            <button type="submit" disabled={lpSaving} style={btnPrimary}>
              {lpSaving ? "Guardando…" : "Crear página"}
            </button>
          </form>

          <h3 style={{ margin: "1.5rem 0 0.75rem", fontSize: "0.95rem" }}>Páginas</h3>
          {loading ? (
            <p style={{ color: "var(--text-muted)", fontSize: "0.85rem" }}>Cargando…</p>
          ) : landings.length === 0 ? (
            <p style={{ color: "var(--text-muted)", fontSize: "0.85rem" }}>Todavía no hay páginas v2.</p>
          ) : (
            <ul style={{ listStyle: "none", padding: 0, margin: 0, display: "flex", flexDirection: "column", gap: "0.5rem" }}>
              {landings.map((l) => (
                <li key={l.id}>
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedId(l.id);
                      setMsg(null);
                    }}
                    style={{
                      ...card,
                      width: "100%",
                      textAlign: "left",
                      cursor: "pointer",
                      border: selectedId === l.id ? "2px solid var(--accent)" : "1px solid var(--border)",
                      padding: "0.75rem 1rem",
                      background: selectedId === l.id ? "rgba(124,92,252,0.08)" : "var(--surface2)",
                    }}
                  >
                    <div style={{ fontWeight: 600, fontSize: "0.9rem" }}>/{l.slug}/</div>
                    <div style={{ fontSize: "0.8rem", color: "var(--text-muted)" }}>{l.title}</div>
                    <div style={{ fontSize: "0.72rem", color: "var(--text-muted)", marginTop: "0.25rem" }}>
                      {l._count?.bundles ?? 0} combo{(l._count?.bundles ?? 0) !== 1 ? "s" : ""}
                    </div>
                  </button>
                  <button type="button" onClick={() => deleteLanding(l.id)} style={{ ...btnDanger, marginTop: "0.35rem", fontSize: "0.75rem" }}>
                    Eliminar página
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>

        <div style={card}>
          {!selected ? (
            <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>Seleccioná una página a la izquierda para crear combos en ella.</p>
          ) : (
            <>
              <h2 style={{ marginBottom: "0.5rem" }}>Combos en «{selected.slug}»</h2>
              <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", marginBottom: "1rem" }}>
                API tienda:{" "}
                <code style={{ fontSize: "0.72rem" }}>
                  /api/storefront/bundles/v2?storeId=…&amp;slug={selected.slug}
                </code>
              </p>

              {loadingBundles ? (
                <p style={{ color: "var(--text-muted)", fontSize: "0.85rem" }}>Cargando combos…</p>
              ) : (
                <ul style={{ listStyle: "none", padding: 0, margin: "0 0 1.25rem", display: "flex", flexDirection: "column", gap: "0.5rem" }}>
                  {bundles.map((b) => (
                    <li
                      key={b.id}
                      style={{
                        display: "flex",
                        justifyContent: "space-between",
                        alignItems: "center",
                        padding: "0.6rem 0.75rem",
                        background: "var(--surface2)",
                        borderRadius: 8,
                        border: "1px solid var(--border)",
                        fontSize: "0.82rem",
                      }}
                    >
                      <span>
                        {b.name}{" "}
                        <span style={{ color: "var(--success)", fontWeight: 600 }}>${b.comboPrice.toLocaleString()}</span>
                        {!b.enabled ? <span style={{ marginLeft: "0.35rem", color: "var(--text-muted)" }}>(oculto)</span> : null}
                      </span>
                      <span style={{ display: "flex", gap: "0.35rem" }}>
                        <button type="button" style={btnGhost} onClick={() => toggleBundle(b)}>
                          {b.enabled ? "Desactivar" : "Activar"}
                        </button>
                        <button type="button" style={btnDanger} onClick={() => deleteBundle(b.id)}>
                          Borrar
                        </button>
                      </span>
                    </li>
                  ))}
                </ul>
              )}

              <h3 style={{ fontSize: "0.95rem", marginBottom: "0.75rem" }}>Nuevo combo en esta página</h3>
              <form onSubmit={createComboOnLanding} style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
                <label style={lab}>
                  Nombre
                  <input required value={formName} onChange={(e) => setFormName(e.target.value)} />
                </label>
                <label style={lab}>
                  Descripción (opcional)
                  <textarea rows={2} value={formDesc} onChange={(e) => setFormDesc(e.target.value)} />
                </label>
                <label style={lab}>
                  Imagen URL (opcional)
                  <input value={formImg} onChange={(e) => setFormImg(e.target.value)} placeholder="https://…" />
                </label>
                <div>
                  <span style={lab}>Productos</span>
                  <TnProductPicker onPick={addProductFromTn} onPickCustomerChoice={addProductFromTnCustomerChoice} />
                </div>
                {products.length > 0 && (
                  <ul style={{ fontSize: "0.78rem", color: "var(--text-muted)", paddingLeft: "1rem" }}>
                    {products.map((p) => (
                      <li key={p.id} style={{ marginBottom: "0.25rem" }}>
                        {p.productName}{" "}
                        <button type="button" style={{ ...btnDanger, padding: "0.1rem 0.35rem", fontSize: "0.65rem" }} onClick={() => setProducts((x) => x.filter((y) => y.id !== p.id))}>
                          Quitar
                        </button>
                      </li>
                    ))}
                  </ul>
                )}
                <label style={lab}>
                  Precio combo ($) — opcional (default suma ítems)
                  <input type="number" min={0} step="0.01" value={formPrice} onChange={(e) => setFormPrice(e.target.value)} />
                </label>
                <button type="submit" disabled={comboSaving} style={btnPrimary}>
                  {comboSaving ? "Guardando…" : "Crear combo en esta página"}
                </button>
              </form>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

const card: React.CSSProperties = {
  background: "var(--surface)",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius)",
  padding: "1.25rem",
};

const lab: React.CSSProperties = {
  display: "flex",
  flexDirection: "column",
  gap: "0.35rem",
  fontSize: "0.8rem",
  fontWeight: 500,
};

const btnPrimary: React.CSSProperties = {
  padding: "0.6rem 1rem",
  background: "linear-gradient(135deg, var(--accent), var(--accent2))",
  color: "#fff",
  border: "none",
  borderRadius: "var(--radius-sm)",
  cursor: "pointer",
  fontWeight: 600,
  fontSize: "0.85rem",
};

const btnGhost: React.CSSProperties = {
  padding: "0.3rem 0.55rem",
  background: "var(--surface2)",
  border: "1px solid var(--border)",
  borderRadius: 6,
  cursor: "pointer",
  fontSize: "0.72rem",
};

const btnDanger: React.CSSProperties = {
  padding: "0.3rem 0.55rem",
  background: "rgba(239,68,68,0.12)",
  color: "var(--danger)",
  border: "1px solid rgba(239,68,68,0.35)",
  borderRadius: 6,
  cursor: "pointer",
  fontSize: "0.72rem",
};
