import Link from "next/link";
import { AdminNav } from "./nav";

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <AdminNav />
      <main
        style={{
          marginLeft: "220px",
          minHeight: "100vh",
          padding: "2rem 2.5rem",
          maxWidth: "calc(100vw - 220px)",
          boxSizing: "border-box",
        }}
      >
        {children}
      </main>
    </>
  );
}
