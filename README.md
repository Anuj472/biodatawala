# BioDatawala - Professional Document Creation Platform

![BioDatawala](https://img.shields.io/badge/Next.js-14-black?style=for-the-badge&logo=next.js)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue?style=for-the-badge&logo=typescript)
![Supabase](https://img.shields.io/badge/Supabase-✓-green?style=for-the-badge&logo=supabase)
![Tailwind CSS](https://img.shields.io/badge/Tailwind-3.4-38bdf8?style=for-the-badge&logo=tailwind-css)

A professional, SEO-optimized multi-service document design platform focusing on marriage biodata, resumes, and creative templates with exceptional user experience.

## 🚀 Features

- **14 Services**: Marriage Biodata, Wedding Invitations, Resumes, Business Cards, Certificates, and more
- **140+ Templates**: 10 unique templates per service
- **Drag & Drop Editor**: Intuitive template customization with Fabric.js/Konva
- **Multi-format Export**: PDF, JPG, PNG downloads
- **Multilingual**: Support for 10 Indian languages
- **Authentication**: Secure user authentication with Supabase Auth
- **SEO Optimized**: Dynamic sitemap, robots.txt, structured data
- **Responsive Design**: Mobile-first approach

## 🛠️ Tech Stack

- **Frontend**: Next.js 14 (App Router), React 18, TypeScript
- **Backend**: Next.js API Routes, Supabase
- **Database**: PostgreSQL with Supabase
- **Styling**: Tailwind CSS, shadcn/ui
- **Editor**: Fabric.js / Konva.js
- **Storage**: Supabase Storage
- **Authentication**: Supabase Auth
- **Deployment**: Docker, Vercel

## 📋 Prerequisites

- Node.js 20+
- PostgreSQL 15+ (or Supabase account)
- Docker & Docker Compose (optional)
- npm or yarn

## 🏃 Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/Anuj472/biodatawala.git
cd biodatawala
```

### 2. Install dependencies

```bash
npm install
```

### 3. Setup environment variables

```bash
cp .env.example .env.local
```

Edit `.env.local` and add your Supabase credentials.

### 4. Setup database

#### Using Supabase (Recommended)

1. Create a new project at [supabase.com](https://supabase.com)
2. Copy your project URL and anon key to `.env.local`
3. Run the database schema:

```bash
psql -h db.your-project.supabase.co -U postgres -d postgres -f database_schema.sql
```

#### Using Docker

```bash
docker-compose up -d postgres redis
```

### 5. Run development server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## 📁 Project Structure

```
biodatawala/
├── app/                      # Next.js App Router
│   ├── (marketing)/         # Marketing pages
│   │   ├── [lang]/         # Internationalized routes
│   │   └── layout.tsx
│   ├── api/                # API routes
│   ├── editor/             # Template editor
│   ├── layout.tsx          # Root layout
│   ├── page.tsx            # Homepage
│   ├── robots.ts           # Dynamic robots.txt
│   └── sitemap.ts          # Dynamic sitemap
├── components/             # React components
│   ├── ui/                # shadcn/ui components
│   ├── marketing/         # Marketing components
│   ├── editor/            # Editor components
│   └── templates/         # Template components
├── lib/                   # Utility functions
│   ├── supabase/         # Supabase clients
│   ├── utils.ts          # Helper functions
│   └── constants.ts      # Constants
├── types/                # TypeScript types
├── public/               # Static assets
├── database_schema.sql   # PostgreSQL schema
├── docker-compose.yml    # Docker configuration
└── next.config.js        # Next.js configuration
```

## 🔑 Environment Variables

See `.env.example` for all required environment variables.

## 🚢 Deployment

### Vercel (Recommended)

```bash
npm i -g vercel
vercel --prod
```

### Docker

```bash
docker build -t biodatawala:latest .
docker run -p 3000:3000 biodatawala:latest
```

## 📊 Database Schema

The database includes:

- **profiles**: User profiles and subscription info
- **services**: 14 document creation services
- **templates**: 140+ professional templates
- **user_documents**: User's saved documents
- **downloads**: Download history
- **blog_posts**: SEO content
- **testimonials**: User reviews
- **analytics_events**: Usage tracking
- **subscriptions**: Payment and subscription management

## 🎨 Services

1. Marriage Biodata Maker
2. Wedding Invitation Cards
3. Pre-Wedding Templates
4. Biodata Posters
5. Family Introduction Videos
6. Resume/CV Maker
7. Cover Letter Templates
8. Portfolio Websites
9. LinkedIn Banner Designs
10. Job Application Tracker
11. ID Card Maker
12. Certificate Generator
13. Business Card Designer
14. Letterhead Templates

## 🔐 Security Features

- Row Level Security (RLS) on all tables
- Supabase Auth for authentication
- Rate limiting on API routes
- CSRF protection
- Input validation with Zod
- Secure file uploads

## 🌐 SEO Features

- Dynamic sitemap generation
- robots.txt configuration
- Meta tags optimization
- Open Graph tags
- Schema markup (Organization, Product, Breadcrumb)
- Multilingual hreflang tags
- Optimized for Google Core Web Vitals

## 📝 License

MIT License - see LICENSE file for details

## 👨‍💻 Author

**Anuj Kumar Mishra**
- GitHub: [@Anuj472](https://github.com/Anuj472)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For support, email support@biodatawala.in or create an issue on GitHub.

---

Made with ❤️ for the Indian market