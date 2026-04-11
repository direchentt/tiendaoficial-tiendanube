import Link from "next/link";
import { redirect } from "next/navigation";

export default function HomePage() {
  if (process.env.NODE_ENV === "production") {
    redirect("/admin/login");
  }

  return (
    <main>
      <h1>Store admin (Next.js)</h1>
      <p>
        <strong>Panel web:</strong>{" "}
        <Link href="/admin/login">/admin/login</Link> (puerto local{" "}
        <Link href="http://localhost:3010">3010</Link> con <code>npm run dev</code>).
      </p>
      <p>
        Callback Business Rules (POST): <code>/api/tn/payments-before-filter</code>
      </p>
      <p>
        APIs admin (cookie de sesion o header <code>x-admin-secret</code>):{" "}
        <code>/api/admin/payment-options</code>, <code>/api/admin/apply-price-percent</code>
      </p>
      <p>
        Gate categorias (POST): <code>/api/admin/category-gate/verify</code>
      </p>
      <p>
        Documentacion: <code>store-admin/README.md</code>
      </p>
    </main>
  );
}
