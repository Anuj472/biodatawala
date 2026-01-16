/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '*.supabase.co',
      },
      {
        protocol: 'https',
        hostname: 'cdn.biodatawala.in',
      },
    ],
    formats: ['image/webp', 'image/avif'],
  },
  
  // Enable internationalization
  i18n: {
    locales: ['en', 'hi', 'mr', 'gu', 'ta', 'te', 'bn', 'kn', 'ml', 'pa'],
    defaultLocale: 'en',
    localeDetection: true,
  },

  // Optimize for production
  swcMinify: true,
  reactStrictMode: true,
  
  // Custom headers for SEO
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on'
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN'
          },
        ],
      },
    ]
  },

  // Redirects
  async redirects() {
    return [
      {
        source: '/biodata',
        destination: '/marriage-biodata-maker',
        permanent: true,
      },
    ]
  },
  
  // Experimental features
  experimental: {
    optimizePackageImports: ['lucide-react'],
  },
}

module.exports = nextConfig