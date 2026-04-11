export default function HomePage() {
  return (
    <main>
      <h1>Store admin (Next.js)</h1>
      <p>
        Callback Business Rules (POST):{" "}
        <code>/api/tn/payments-before-filter</code>
      </p>
      <p>
        Listar medios de pago (GET + header <code>x-admin-secret</code>):{" "}
        <code>/api/admin/payment-options</code>
      </p>
      <p>
        Ajuste masivo de precios % (POST JSON <code>{"{ percent, dryRun? }"}</code>):{" "}
        <code>/api/admin/apply-price-percent</code>
      </p>
      <p>
        Categoria con contrasena (capa propia, POST):{" "}
        <code>/api/admin/category-gate/verify</code>
      </p>
      <p>
        Ver <code>store-admin/README.md</code> para OAuth, scopes y habilitacion de Business Rules
        con Partners.
      </p>
    </main>
  );
}
