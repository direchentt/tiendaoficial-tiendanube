"use client";

import { adminFetch } from "@/lib/admin-fetch";
import type { CSSProperties } from "react";
import { useCallback, useEffect, useRef, useState } from "react";
import type { TNProduct, TNVariant } from "./tn-product-picker-utils";
import { variantLabel } from "./tn-product-picker-utils";

export type TnProductPickerProps = {
  onPick: (product: TNProduct, variant: TNVariant) => void;
  /** Tiempo de espera tras escribir antes de llamar a TN (default 400 ms). */
  searchDebounceMs?: number;
  /** Productos por página en la pestaña Catálogo. */
  catalogPerPage?: number;
  /** Resultados máximos en la pestaña Buscar. */
  searchPerPage?: number;
  /** Máximo de IDs en la pestaña "IDs" (default 24, tope del servidor). */
  maxPasteIds?: number;
};

function isAbortError(e: unknown): boolean {
  return e instanceof DOMException && e.name === "AbortError";
}

export function TnProductPicker({
  onPick,
  searchDebounceMs = 400,
  catalogPerPage = 24,
  searchPerPage = 20,
  maxPasteIds = 24,
}: TnProductPickerProps) {
  const [pickerTab, setPickerTab] = useState<"catalog" | "search" | "ids">("catalog");
  const [search, setSearch] = useState("");
  const [tnProducts, setTnProducts] = useState<TNProduct[]>([]);
  const [loadingProducts, setLoadingProducts] = useState(false);
  const [searchError, setSearchError] = useState<string | null>(null);
  const [searchEmpty, setSearchEmpty] = useState(false);

  const [catalogPage, setCatalogPage] = useState(1);
  const [catalogItems, setCatalogItems] = useState<TNProduct[]>([]);
  const [catalogLoading, setCatalogLoading] = useState(false);
  const [catalogHasMore, setCatalogHasMore] = useState(true);
  const [catalogError, setCatalogError] = useState<string | null>(null);

  const [idsInput, setIdsInput] = useState("");
  const [idsProducts, setIdsProducts] = useState<TNProduct[]>([]);
  const [idsFailed, setIdsFailed] = useState<{ id: number; error: string }[]>([]);
  const [idsLoading, setIdsLoading] = useState(false);
  const [idsError, setIdsError] = useState<string | null>(null);

  const catalogAbortRef = useRef<AbortController | null>(null);
  const searchAbortRef = useRef<AbortController | null>(null);
  const idsAbortRef = useRef<AbortController | null>(null);

  useEffect(() => {
    return () => {
      catalogAbortRef.current?.abort();
      searchAbortRef.current?.abort();
      idsAbortRef.current?.abort();
    };
  }, []);

  const fetchCatalogPage = useCallback(
    async (page: number, append: boolean) => {
      catalogAbortRef.current?.abort();
      const ac = new AbortController();
      catalogAbortRef.current = ac;

      setCatalogLoading(true);
      try {
        const r = await adminFetch(
          `/api/admin/tn-products?q=&page=${page}&per_page=${catalogPerPage}`,
          { signal: ac.signal }
        );
        const data = await r.json().catch(() => ({}));
        if (!r.ok) {
          if (ac.signal.aborted) return;
          setCatalogError(typeof data.error === "string" ? data.error : "Error al cargar catálogo");
          setCatalogLoading(false);
          return;
        }
        const list = Array.isArray(data.products) ? data.products : [];
        if (ac.signal.aborted) return;
        setCatalogItems((prev) => (append ? [...prev, ...list] : list));
        setCatalogHasMore(list.length >= catalogPerPage);
        setCatalogPage(page);
        setCatalogError(null);
      } catch (e) {
        if (isAbortError(e) || (e as { name?: string })?.name === "AbortError") return;
        if (!ac.signal.aborted) setCatalogError("No se pudo cargar el catálogo.");
      } finally {
        if (catalogAbortRef.current === ac) setCatalogLoading(false);
      }
    },
    [catalogPerPage]
  );

  const runSearch = useCallback(
    async (q: string) => {
      const trimmed = q.trim();
      if (trimmed.length < 2) {
        searchAbortRef.current?.abort();
        setTnProducts([]);
        setSearchError(null);
        setSearchEmpty(false);
        setLoadingProducts(false);
        return;
      }

      searchAbortRef.current?.abort();
      const ac = new AbortController();
      searchAbortRef.current = ac;

      setLoadingProducts(true);
      setSearchError(null);
      setSearchEmpty(false);
      try {
        const r = await adminFetch(
          `/api/admin/tn-products?q=${encodeURIComponent(trimmed)}&per_page=${searchPerPage}`,
          { signal: ac.signal }
        );
        const data = await r.json().catch(() => ({}));
        if (ac.signal.aborted) return;
        if (r.ok) {
          const list = Array.isArray(data.products) ? data.products : [];
          setTnProducts(list);
          setSearchEmpty(list.length === 0);
        } else {
          setTnProducts([]);
          setSearchEmpty(false);
          const msg = typeof data.error === "string" ? data.error : "Error al buscar";
          setSearchError(msg);
        }
      } catch (e) {
        if (isAbortError(e) || (e as { name?: string })?.name === "AbortError") return;
        if (!ac.signal.aborted) {
          setTnProducts([]);
          setSearchError("No se pudo conectar con el buscador.");
        }
      } finally {
        if (searchAbortRef.current === ac) setLoadingProducts(false);
      }
    },
    [searchPerPage]
  );

  useEffect(() => {
    if (pickerTab !== "ids") return;
    return () => {
      idsAbortRef.current?.abort();
    };
  }, [pickerTab]);

  useEffect(() => {
    if (pickerTab !== "catalog") return;
    void fetchCatalogPage(1, false);
  }, [pickerTab, fetchCatalogPage]);

  useEffect(() => {
    if (pickerTab !== "search") {
      searchAbortRef.current?.abort();
      return;
    }
    const t = setTimeout(() => void runSearch(search), searchDebounceMs);
    return () => clearTimeout(t);
  }, [search, pickerTab, searchDebounceMs, runSearch]);

  const loadByIds = useCallback(async () => {
    const parts = idsInput
      .split(/[\s,;]+/)
      .map((s) => parseInt(s.trim(), 10))
      .filter((n) => Number.isFinite(n) && n > 0);
    const seen = new Set<number>();
    const ids: number[] = [];
    for (const n of parts) {
      if (seen.has(n)) continue;
      seen.add(n);
      ids.push(n);
      if (ids.length >= maxPasteIds) break;
    }
    if (ids.length === 0) {
      setIdsError("Ingresá al menos un ID numérico de producto.");
      setIdsProducts([]);
      setIdsFailed([]);
      return;
    }

    idsAbortRef.current?.abort();
    const ac = new AbortController();
    idsAbortRef.current = ac;

    setIdsLoading(true);
    setIdsError(null);
    setIdsFailed([]);
    try {
      const r = await adminFetch(`/api/admin/tn-products/by-ids?ids=${ids.join(",")}`, {
        signal: ac.signal,
      });
      const data = await r.json().catch(() => ({}));
      if (ac.signal.aborted) return;
      if (!r.ok) {
        setIdsProducts([]);
        setIdsError(typeof data.error === "string" ? data.error : "Error al cargar por IDs");
        return;
      }
      const list = Array.isArray(data.products) ? data.products : [];
      const failed = Array.isArray(data.failed) ? data.failed : [];
      setIdsProducts(list);
      setIdsFailed(failed);
    } catch (e) {
      if (isAbortError(e) || (e as { name?: string })?.name === "AbortError") return;
      if (!ac.signal.aborted) {
        setIdsProducts([]);
        setIdsError("No se pudo conectar.");
      }
    } finally {
      if (idsAbortRef.current === ac) setIdsLoading(false);
    }
  }, [idsInput, maxPasteIds]);

  function handlePick(p: TNProduct, v: TNVariant) {
    onPick(p, v);
    setSearch("");
    setTnProducts([]);
    setSearchEmpty(false);
    setSearchError(null);
    setIdsProducts([]);
    setIdsInput("");
    setIdsFailed([]);
    setIdsError(null);
  }

  return (
    <div>
      <div style={tabRow}>
        <button
          type="button"
          style={pickerTab === "catalog" ? tabActive : tabIdle}
          onClick={() => setPickerTab("catalog")}
        >
          Catálogo
        </button>
        <button
          type="button"
          style={pickerTab === "search" ? tabActive : tabIdle}
          onClick={() => setPickerTab("search")}
        >
          Buscar
        </button>
        <button
          type="button"
          style={pickerTab === "ids" ? tabActive : tabIdle}
          onClick={() => setPickerTab("ids")}
        >
          IDs
        </button>
      </div>

      {pickerTab === "catalog" && (
        <div style={{ marginTop: "0.75rem" }}>
          {catalogError && (
            <p style={{ fontSize: "0.8rem", color: "var(--danger)", marginBottom: "0.5rem" }}>{catalogError}</p>
          )}
          {catalogLoading && catalogItems.length === 0 ? (
            <p style={{ fontSize: "0.85rem", color: "var(--text-muted)" }}>Cargando productos…</p>
          ) : (
            <>
              <div style={catalogGrid}>
                {catalogItems.map((p) => (
                  <div key={p.id} style={catalogCard}>
                    {p.images[0] ? (
                      // eslint-disable-next-line @next/next/no-img-element -- miniaturas TN; sin dominio Next Image
                      <img
                        src={p.images[0]}
                        alt=""
                        style={{
                          width: "100%",
                          aspectRatio: "1",
                          objectFit: "cover",
                          borderRadius: "8px",
                          background: "var(--surface2)",
                        }}
                      />
                    ) : (
                      <div
                        style={{
                          width: "100%",
                          aspectRatio: "1",
                          borderRadius: "8px",
                          background: "var(--surface2)",
                        }}
                      />
                    )}
                    <div style={{ fontWeight: 600, fontSize: "0.8rem", marginTop: "0.45rem", lineHeight: 1.3 }}>
                      {p.name}
                    </div>
                    <div style={{ marginTop: "0.35rem", display: "flex", flexDirection: "column", gap: "0.25rem" }}>
                      {p.variants.map((v) => (
                        <button
                          key={v.id}
                          type="button"
                          style={btnMini}
                          onClick={() => handlePick(p, v)}
                        >
                          + {variantLabel(v)} · ${v.price}
                        </button>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
              {catalogHasMore && (
                <button
                  type="button"
                  style={{ ...btnSecondary, marginTop: "0.75rem", width: "100%" }}
                  disabled={catalogLoading}
                  onClick={() => fetchCatalogPage(catalogPage + 1, true)}
                >
                  {catalogLoading ? "Cargando…" : "Cargar más productos"}
                </button>
              )}
            </>
          )}
        </div>
      )}

      {pickerTab === "search" && (
        <div style={{ marginTop: "0.75rem", position: "relative", zIndex: 20 }}>
          <input
            placeholder="Nombre, SKU o tag (mín. 2 caracteres)…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          {loadingProducts && (
            <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", marginTop: "0.35rem" }}>Buscando…</p>
          )}
          {searchError && (
            <p style={{ fontSize: "0.8rem", color: "var(--danger)", marginTop: "0.35rem" }}>{searchError}</p>
          )}
          {!loadingProducts && searchEmpty && search.trim().length >= 2 && (
            <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", marginTop: "0.35rem" }}>Sin resultados.</p>
          )}
          {tnProducts.length > 0 && (
            <div style={pickerDropdown}>
              {tnProducts.map((p) => (
                <div key={p.id} style={{ padding: "0.5rem", borderBottom: "1px solid var(--border)" }}>
                  <div style={{ display: "flex", gap: "0.65rem", alignItems: "center" }}>
                    {p.images[0] ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={p.images[0]}
                        alt=""
                        style={{ width: 36, height: 36, objectFit: "cover", borderRadius: 6 }}
                      />
                    ) : (
                      <div style={{ width: 36, height: 36, borderRadius: 6, background: "var(--surface2)" }} />
                    )}
                    <div style={{ fontWeight: 600, fontSize: "0.85rem", flex: 1 }}>{p.name}</div>
                  </div>
                  <div
                    style={{
                      paddingLeft: "44px",
                      marginTop: "0.25rem",
                      display: "flex",
                      flexDirection: "column",
                      gap: "0.25rem",
                    }}
                  >
                    {p.variants.map((v) => (
                      <button key={v.id} type="button" style={btnSecondary} onClick={() => handlePick(p, v)}>
                        + {variantLabel(v)} (${v.price})
                      </button>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {pickerTab === "ids" && (
        <div style={{ marginTop: "0.75rem" }}>
          <textarea
            value={idsInput}
            onChange={(e) => setIdsInput(e.target.value)}
            rows={3}
            placeholder={`IDs separados por coma o espacio (máx. ${maxPasteIds})…`}
            style={{
              width: "100%",
              resize: "vertical",
              fontFamily: "inherit",
              fontSize: "0.875rem",
              padding: "0.5rem 0.65rem",
              borderRadius: 8,
              border: "1px solid var(--border)",
              background: "var(--surface)",
            }}
          />
          <button
            type="button"
            onClick={() => void loadByIds()}
            disabled={idsLoading}
            style={{ ...btnSecondary, marginTop: "0.5rem" }}
          >
            {idsLoading ? "Cargando…" : "Cargar por IDs"}
          </button>
          {idsError && (
            <p style={{ fontSize: "0.8rem", color: "var(--danger)", marginTop: "0.35rem" }}>{idsError}</p>
          )}
          {idsFailed.length > 0 && (
            <ul style={{ fontSize: "0.72rem", color: "var(--danger)", margin: "0.35rem 0 0", paddingLeft: "1.1rem" }}>
              {idsFailed.map((f) => (
                <li key={f.id}>
                  ID {f.id}: {f.error}
                </li>
              ))}
            </ul>
          )}
          {idsProducts.length > 0 && (
            <div
              style={{
                marginTop: "0.75rem",
                border: "1px solid var(--border)",
                borderRadius: "var(--radius-sm)",
                maxHeight: "340px",
                overflowY: "auto",
                background: "var(--surface)",
              }}
            >
              {idsProducts.map((p) => (
                <div key={p.id} style={{ padding: "0.5rem", borderBottom: "1px solid var(--border)" }}>
                  <div style={{ display: "flex", gap: "0.65rem", alignItems: "center" }}>
                    {p.images[0] ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={p.images[0]}
                        alt=""
                        style={{ width: 36, height: 36, objectFit: "cover", borderRadius: 6 }}
                      />
                    ) : (
                      <div style={{ width: 36, height: 36, borderRadius: 6, background: "var(--surface2)" }} />
                    )}
                    <div style={{ fontWeight: 600, fontSize: "0.85rem", flex: 1 }}>{p.name}</div>
                  </div>
                  <div
                    style={{
                      paddingLeft: "44px",
                      marginTop: "0.25rem",
                      display: "flex",
                      flexDirection: "column",
                      gap: "0.25rem",
                    }}
                  >
                    {p.variants.map((v) => (
                      <button key={v.id} type="button" style={btnSecondary} onClick={() => handlePick(p, v)}>
                        + {variantLabel(v)} (${v.price})
                      </button>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

const btnSecondary: CSSProperties = {
  padding: "0.35rem 0.65rem",
  background: "var(--surface2)",
  color: "var(--text-muted)",
  border: "1px solid var(--border)",
  borderRadius: "6px",
  cursor: "pointer",
  fontSize: "0.78rem",
};

const btnMini: CSSProperties = {
  ...btnSecondary,
  textAlign: "left" as const,
  fontSize: "0.72rem",
};

const tabRow: CSSProperties = {
  display: "flex",
  gap: "0.35rem",
  flexWrap: "wrap",
};

const tabActive: CSSProperties = {
  ...btnSecondary,
  borderColor: "var(--accent)",
  color: "var(--accent2)",
  background: "rgba(124,92,252,0.12)",
};

const tabIdle: CSSProperties = {
  ...btnSecondary,
  opacity: 0.85,
};

const catalogGrid: CSSProperties = {
  display: "grid",
  gridTemplateColumns: "repeat(auto-fill, minmax(9.5rem, 1fr))",
  gap: "0.65rem",
};

const catalogCard: CSSProperties = {
  border: "1px solid var(--border)",
  borderRadius: "10px",
  padding: "0.5rem",
  background: "var(--surface)",
};

const pickerDropdown: CSSProperties = {
  position: "absolute",
  left: 0,
  right: 0,
  top: "100%",
  marginTop: 4,
  zIndex: 60,
  background: "var(--surface)",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius-sm)",
  maxHeight: "340px",
  overflowY: "auto",
  boxShadow: "0 8px 24px rgba(0,0,0,0.4)",
};
