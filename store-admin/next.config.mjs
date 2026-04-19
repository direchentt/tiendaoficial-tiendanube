/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: {
    serverComponentsExternalPackages: ["@prisma/client", "bcryptjs"],
    serverActions: {
      allowedOrigins: [
        "tiendaoficial-tiendanube-production.up.railway.app",
        "localhost:3010",
      ],
    },
  },
};

export default nextConfig;
