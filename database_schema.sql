-- BioDatawala Database Schema
-- PostgreSQL + Supabase

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- =====================================================
-- 1. USERS TABLE (extends Supabase auth.users)
-- =====================================================
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    phone TEXT,
    subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'premium')),
    subscription_expires_at TIMESTAMPTZ,
    downloads_remaining INTEGER DEFAULT 5,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 2. SERVICES TABLE
-- =====================================================
CREATE TABLE public.services (
    id SERIAL PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name_en TEXT NOT NULL,
    name_hi TEXT,
    name_mr TEXT,
    description_en TEXT NOT NULL,
    description_hi TEXT,
    icon_url TEXT,
    template_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    meta_title TEXT,
    meta_description TEXT,
    meta_keywords TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 3. TEMPLATES TABLE
-- =====================================================
CREATE TABLE public.templates (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    service_id INTEGER REFERENCES public.services(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT NOT NULL,
    preview_url TEXT,
    template_data JSONB NOT NULL,
    is_premium BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    tags TEXT[],
    category TEXT,
    dimensions JSONB,
    file_formats TEXT[] DEFAULT ARRAY['pdf', 'jpg', 'png'],
    downloads_count INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0.00,
    reviews_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 4. USER DOCUMENTS TABLE
-- =====================================================
CREATE TABLE public.user_documents (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    template_id UUID REFERENCES public.templates(id) ON DELETE SET NULL,
    document_name TEXT NOT NULL,
    document_data JSONB NOT NULL,
    thumbnail_url TEXT,
    is_completed BOOLEAN DEFAULT false,
    last_edited_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 5. DOWNLOADS TABLE
-- =====================================================
CREATE TABLE public.downloads (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    template_id UUID REFERENCES public.templates(id) ON DELETE SET NULL,
    document_id UUID REFERENCES public.user_documents(id) ON DELETE CASCADE,
    file_format TEXT NOT NULL,
    file_url TEXT,
    file_size_kb INTEGER,
    downloaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 6. BLOG POSTS TABLE
-- =====================================================
CREATE TABLE public.blog_posts (
    id SERIAL PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    title_en TEXT NOT NULL,
    title_hi TEXT,
    content_en TEXT NOT NULL,
    content_hi TEXT,
    excerpt_en TEXT,
    excerpt_hi TEXT,
    featured_image_url TEXT,
    author_id UUID REFERENCES public.profiles(id),
    category TEXT,
    tags TEXT[],
    meta_title TEXT,
    meta_description TEXT,
    meta_keywords TEXT[],
    views_count INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT false,
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 7. TESTIMONIALS TABLE
-- =====================================================
CREATE TABLE public.testimonials (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id),
    name TEXT NOT NULL,
    avatar_url TEXT,
    service_used TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    testimonial_text TEXT NOT NULL,
    is_featured BOOLEAN DEFAULT false,
    is_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 8. NEWSLETTER SUBSCRIBERS TABLE
-- =====================================================
CREATE TABLE public.newsletter_subscribers (
    id SERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    is_active BOOLEAN DEFAULT true,
    subscribed_at TIMESTAMPTZ DEFAULT NOW(),
    unsubscribed_at TIMESTAMPTZ
);

-- =====================================================
-- 9. ANALYTICS EVENTS TABLE
-- =====================================================
CREATE TABLE public.analytics_events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id),
    event_type TEXT NOT NULL,
    event_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 10. SUBSCRIPTIONS TABLE
-- =====================================================
CREATE TABLE public.subscriptions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    plan_type TEXT NOT NULL CHECK (plan_type IN ('monthly', 'yearly')),
    amount INTEGER NOT NULL,
    currency TEXT DEFAULT 'INR',
    payment_gateway TEXT,
    payment_id TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired')),
    starts_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================
CREATE INDEX idx_templates_service_id ON public.templates(service_id);
CREATE INDEX idx_templates_is_premium ON public.templates(is_premium);
CREATE INDEX idx_templates_is_featured ON public.templates(is_featured);
CREATE INDEX idx_user_documents_user_id ON public.user_documents(user_id);
CREATE INDEX idx_downloads_user_id ON public.downloads(user_id);
CREATE INDEX idx_blog_posts_slug ON public.blog_posts(slug);
CREATE INDEX idx_blog_posts_published ON public.blog_posts(is_published, published_at);
CREATE INDEX idx_analytics_events_type ON public.analytics_events(event_type);
CREATE INDEX idx_analytics_events_created ON public.analytics_events(created_at);

-- =====================================================
-- ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Templates (Public read)
ALTER TABLE public.templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Templates are viewable by everyone" ON public.templates
    FOR SELECT USING (true);

-- User Documents (Private)
ALTER TABLE public.user_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own documents" ON public.user_documents
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own documents" ON public.user_documents
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own documents" ON public.user_documents
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own documents" ON public.user_documents
    FOR DELETE USING (auth.uid() = user_id);

-- Downloads
ALTER TABLE public.downloads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own downloads" ON public.downloads
    FOR SELECT USING (auth.uid() = user_id);

-- Blog Posts (Public read)
ALTER TABLE public.blog_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Published blog posts are viewable by everyone" ON public.blog_posts
    FOR SELECT USING (is_published = true);

-- Testimonials (Public read for approved)
ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Approved testimonials are viewable by everyone" ON public.testimonials
    FOR SELECT USING (is_approved = true);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to relevant tables
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON public.services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_templates_updated_at BEFORE UPDATE ON public.templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_blog_posts_updated_at BEFORE UPDATE ON public.blog_posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SEED DATA - 14 SERVICES
-- =====================================================
INSERT INTO public.services (slug, name_en, name_hi, description_en, template_count, sort_order, meta_title, meta_description) VALUES
('marriage-biodata-maker', 'Marriage Biodata Maker', 'विवाह बायोडाटा मेकर', 'Create beautiful marriage biodata online for free. Choose from traditional Hindu, Muslim, Christian formats.', 10, 1, 'Marriage Biodata Maker Online Free | 10+ Hindu, Muslim, Christian Formats', 'Create beautiful marriage biodata online for free. Choose from traditional Hindu, Muslim, Christian formats. Download as PDF.'),
('wedding-invitation-cards', 'Wedding Invitation Cards', 'शादी के निमंत्रण कार्ड', 'Design stunning wedding invitation cards with 10+ premium templates.', 10, 2, 'Wedding Invitation Card Maker | Digital & Print Ready Templates', 'Design stunning wedding invitation cards online. 10+ premium templates for Indian weddings.'),
('pre-wedding-templates', 'Pre-Wedding Templates', 'प्री-वेडिंग टेम्पलेट्स', 'Save the date, engagement, mehendi, sangeet ceremony cards and templates.', 10, 3, 'Pre-Wedding Templates | Save The Date, Engagement, Mehendi Cards', 'Create pre-wedding ceremony cards - save the date, engagement, mehendi, sangeet templates.'),
('biodata-posters', 'Biodata Posters', 'बायोडाटा पोस्टर्स', 'Social media ready biodata posters for Instagram, Facebook, WhatsApp.', 10, 4, 'Biodata Posters for Social Media | Instagram, Facebook, WhatsApp', 'Create shareable biodata posters optimized for social media platforms.'),
('family-introduction-videos', 'Family Introduction Videos', 'पारिवारिक परिचय वीडियो', 'Animated family introduction videos with photos and music.', 10, 5, 'Family Introduction Video Maker | Wedding Family Videos', 'Create beautiful family introduction videos with photos, music, and animations.'),
('resume-cv-maker', 'Resume/CV Maker', 'रिज्यूमे/सीवी मेकर', 'Professional resume builder with ATS-friendly templates for freshers and experienced.', 10, 6, 'Free Resume Builder India | ATS-Friendly CV Maker 2026', 'Create professional resumes online. 10+ ATS-friendly templates for freshers and experienced.'),
('cover-letter-templates', 'Cover Letter Templates', 'कवर लेटर टेम्पलेट्स', 'Professional cover letter templates for job applications.', 10, 7, 'Cover Letter Templates | Professional Job Application Letters', 'Download professional cover letter templates for your job applications.'),
('portfolio-websites', 'Portfolio Websites', 'पोर्टफोलियो वेबसाइट्स', 'Ready-to-use portfolio website templates for designers, developers, freelancers.', 10, 8, 'Portfolio Website Templates | Designer, Developer, Freelancer', 'Create stunning portfolio websites with ready-to-use templates.'),
('linkedin-banner-designs', 'LinkedIn Banner Designs', 'लिंक्डइन बैनर डिज़ाइन', 'Professional LinkedIn banner designs to enhance your profile.', 10, 9, 'LinkedIn Banner Designs | Professional Profile Headers', 'Download professional LinkedIn banner designs to enhance your profile visibility.'),
('job-application-tracker', 'Job Application Tracker', 'जॉब आवेदन ट्रैकर', 'Track your job applications, interviews, and follow-ups efficiently.', 10, 10, 'Job Application Tracker | Organize Your Job Search', 'Track job applications, interviews, and follow-ups with organized templates.'),
('id-card-maker', 'ID Card Maker', 'आईडी कार्ड मेकर', 'Design employee, student, visitor, and event ID cards.', 10, 11, 'ID Card Maker | Employee, Student, Visitor ID Cards', 'Create professional ID cards for employees, students, visitors, and events.'),
('certificate-generator', 'Certificate Generator', 'प्रमाणपत्र जनरेटर', 'Generate certificates for achievements, courses, events, and awards.', 10, 12, 'Certificate Maker Online | Achievement, Course, Award Certificates', 'Generate professional certificates for achievements, courses, events, and awards.'),
('business-card-designer', 'Business Card Designer', 'बिज़नेस कार्ड डिज़ाइनर', 'Create professional business cards with modern templates.', 10, 13, 'Business Card Maker | Professional Business Card Designs', 'Design professional business cards online with modern templates.'),
('letterhead-templates', 'Letterhead Templates', 'लेटरहेड टेम्पलेट्स', 'Professional letterhead templates for businesses and organizations.', 10, 14, 'Letterhead Templates | Professional Business Letterheads', 'Download professional letterhead templates for businesses and organizations.');

COMMIT;