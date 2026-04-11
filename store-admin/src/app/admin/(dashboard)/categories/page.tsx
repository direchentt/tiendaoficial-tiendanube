import Link from "next/link";
import { ensureDefaultStore } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";
import { createLockedCategoryForm, deleteLockedCategoryForm } from "./actions";

export const dynamic = "force-dynamic";

export default async function CategoriesPage() {
  const store = await ensureDefaultStore();
  const locked = await prisma.lockedCategory.findMany({
    where: { storeId: store.id },
    orderBy: { categoryId: "asc" },
  });

  return (
    <main>
      <p>
        <Link href="/admin" style={{ fontSize: "0.9rem" }}>
          &larr; Inicio
        </Link>
      </p>
      <h1 style={{ fontSize: "1.25rem" }}>Categorias bloqueadas</h1>
      <p style={{ color: "#555", fontSize: "0.9rem", maxWidth: "40rem" }}>
        No es un campo nativo de la API Category: el tema debe llamar a{" "}
        <code>POST /api/admin/category-gate/verify</code> y mostrar contenido solo si{" "}
        <code>ok: true</code>. Hash SHA256 solo para desarrollo; usar bcrypt en produccion.
      </p>
      <section style={{ marginBottom: "2rem" }}>
        <h2 style={{ fontSize: "1rem" }}>Agregar</h2>
        <form
          action={createLockedCategoryForm}
          style={{ display: "flex", flexWrap: "wrap", gap: "0.75rem", alignItems: "flex-end" }}
        >
          <label>
            <span style={{ display: "block", fontSize: "0.8rem" }}>ID categoria (TN)</span>
            <input name="categoryId" type="number" required min={1} style={inp} />
          </label>
          <label>
            <span style={{ display: "block", fontSize: "0.8rem" }}>Contrasena</span>
            <input name="password" type="password" required minLength={4} style={inp} />
          </label>
          <button type="submit" style={btn}>
            Guardar
          </button>
        </form>
      </section>
      <h2 style={{ fontSize: "1rem" }}>Listado</h2>
      {locked.length === 0 ? (
        <p>Ninguna.</p>
      ) : (
        <ul style={{ listStyle: "none", padding: 0 }}>
          {locked.map((l) => (
            <li
              key={l.id}
              style={{
                display: "flex",
                alignItems: "center",
                gap: "1rem",
                padding: "0.5rem 0",
                borderBottom: "1px solid #eee",
              }}
            >
              <span>
                Categoria <strong>{l.categoryId}</strong>
              </span>
              <form action={deleteLockedCategoryForm}>
                <input type="hidden" name="id" value={l.id} />
                <button type="submit" style={{ ...btn, background: "#888" }}>
                  Quitar
                </button>
              </form>
            </li>
          ))}
        </ul>
      )}
    </main>
  );
}

const inp: React.CSSProperties = {
  padding: "0.45rem 0.55rem",
  borderRadius: "6px",
  border: "1px solid #ccc",
};

const btn: React.CSSProperties = {
  padding: "0.45rem 0.9rem",
  background: "#111",
  color: "#fff",
  border: "none",
  borderRadius: "6px",
  cursor: "pointer",
};
