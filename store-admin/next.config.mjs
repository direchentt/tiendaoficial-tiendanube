/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Needed for prisma in Next.js edge/server
  serverExternalPackages: ["@prisma/client", "bcryptjs"],
  // Fix for RSC fetch in Railway — ensures server fetches use the correct base URL
  // instead of defaulting to 0.0.0.0:8080
  experimental: {
    serverActions: {
      allowedOrigins: ["tiendaoficial-tiendanube-production.up.railway.app"],
    },
  },
};

export default nextConfig;
