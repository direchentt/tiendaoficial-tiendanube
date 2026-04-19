import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Hache Suite — Panel Admin",
  description: "Panel de reglas de negocio avanzadas para tu tienda Tiendanube",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        {/* eslint-disable-next-line @next/next/no-page-custom-font */}
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
          rel="stylesheet"
        />
        <style>{`
          *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
          :root {
            --bg: #0a0a0f;
            --surface: #12121a;
            --surface2: #1a1a26;
            --border: #2a2a3d;
            --border-hover: #3d3d5c;
            --accent: #7c5cfc;
            --accent2: #a78bfa;
            --accent-glow: rgba(124,92,252,0.25);
            --success: #22c55e;
            --danger: #ef4444;
            --warning: #f59e0b;
            --text: #e8e8f0;
            --text-muted: #8888aa;
            --text-dim: #5555778;
            --radius: 12px;
            --radius-sm: 8px;
            --shadow: 0 4px 24px rgba(0,0,0,0.4);
            --transition: 0.18s ease;
          }
          html { font-size: 16px; }
          body {
            font-family: 'Inter', system-ui, sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
          }
          a { color: var(--accent2); text-decoration: none; }
          a:hover { color: var(--accent); }
          input, select, textarea {
            font-family: inherit;
            font-size: 0.875rem;
            background: var(--surface2);
            border: 1px solid var(--border);
            color: var(--text);
            border-radius: var(--radius-sm);
            padding: 0.6rem 0.85rem;
            outline: none;
            transition: border-color var(--transition), box-shadow var(--transition);
            width: 100%;
          }
          input:focus, select:focus, textarea:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px var(--accent-glow);
          }
          input[type="checkbox"] {
            width: auto;
            accent-color: var(--accent);
            width: 16px; height: 16px;
            cursor: pointer;
          }
          input[type="number"] { -moz-appearance: textfield; }
          label { display: block; font-size: 0.8rem; color: var(--text-muted); margin-bottom: 0.35rem; font-weight: 500; }
          h1 { font-size: 1.5rem; font-weight: 700; letter-spacing: -0.02em; }
          h2 { font-size: 1.1rem; font-weight: 600; }
          h3 { font-size: 0.95rem; font-weight: 600; }
          pre {
            font-family: 'JetBrains Mono', 'Fira Code', monospace;
            font-size: 0.78rem;
            background: #0d0d14;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            padding: 1rem;
            overflow: auto;
            color: #a8b4d8;
          }
          code {
            font-family: monospace;
            background: var(--surface2);
            padding: 0.1em 0.35em;
            border-radius: 4px;
            font-size: 0.85em;
            color: var(--accent2);
          }
          ::-webkit-scrollbar { width: 6px; height: 6px; }
          ::-webkit-scrollbar-track { background: var(--surface); }
          ::-webkit-scrollbar-thumb { background: var(--border); border-radius: 99px; }
        `}</style>
      </head>
      <body>{children}</body>
    </html>
  );
}
