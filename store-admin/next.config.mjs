/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Next.js 14: external packages for server components (prisma, bcryptjs)
  experimental: {
    serverComponentsExternalPackages: ["@prisma/client", "bcryptjs"],
    serverActions: {
      allowedOrigins: ["tiendaoficial-tiendanube-production.up.railway.app"],
    },
  },
};

export default nextConfig;
