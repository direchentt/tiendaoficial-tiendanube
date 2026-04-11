import { AdminNav } from "./nav";

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <AdminNav />
      <div>{children}</div>
    </>
  );
}
