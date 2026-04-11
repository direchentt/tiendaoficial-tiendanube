import Link from "next/link";

export default function AdminHomePage() {
  const base =
    process.env.NEXT_PUBLIC_APP_URL?.replace(/\/$/, "") ?? "(tu dominio en produccion)";

  return (
    <main>
      <h1 style={{ fontSize: "1.35rem" }}>Panel</h1>
      <p style={{ color: "#444", lineHeight: 1.5 }}>
        El <strong>backend</strong> es esta app Next.js en la carpeta{" "}
        <code style={{ background: "#f4f4f4", padding: "0.1rem 0.35rem" }}>store-admin/</code> del
        repo. En local corre en{" "}
        <a href="http://localhost:3010">http://localhost:3010</a> (<code>npm run dev</code>).
      </p>
      <ul style={{ lineHeight: 1.8 }}>
        <li>
          <Link href="/admin/payment-rules">Reglas de pago</Link> (Business Rules callback)
        </li>
        <li>
          <Link href="/admin/payment-options">IDs de medios de pago</Link> desde la API TN
        </li>
        <li>
          <Link href="/admin/price">Ajuste masivo de precios</Link> por porcentaje
        </li>
        <li>
          <Link href="/admin/categories">Categorias con contrasena</Link> (capa propia)
        </li>
      </ul>
      <section style={{ marginTop: "1.5rem", fontSize: "0.9rem", color: "#333" }}>
        <h2 style={{ fontSize: "1rem" }}>Webhook Tiendanube (POST)</h2>
        <p>
          Registrar en Partners la URL publica del callback, por ejemplo:
        </p>
        <pre
          style={{
            background: "#f6f6f6",
            padding: "0.75rem",
            borderRadius: "6px",
            overflow: "auto",
          }}
        >
          {`${base}/api/tn/payments-before-filter`}
        </pre>
        <p style={{ marginTop: "0.5rem" }}>
          En local podes exponer con <code>ngrok</code>, <code>cloudflared</code> o similar.
        </p>
      </section>
    </main>
  );
}
