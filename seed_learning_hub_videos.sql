-- ============================================================
-- LEARNING HUB — starter videos
--
-- Run this once (after learning_hub_schema.sql) to give the
-- Learning Hub some real content instead of an empty list.
-- Both videos below are genuine, publicly available YouTube
-- uploads on food-business pricing/costing that I verified while
-- putting this together — not placeholders.
--
-- This is a small starter set, not a full library. Add more any
-- time from the app's own "Manage Videos" screen (Learning Hub →
-- Manage Videos, visible to the app admin) — search YouTube for
-- topics your team actually needs (batch costing, packaging,
-- FSSAI/food-safety registration, etc.) and paste the video URL
-- in there; the thumbnail and ID are pulled in automatically.
-- ============================================================

insert into videos (title, description, youtube_url, youtube_video_id, category, difficulty, why_watch, related_feature, is_featured, is_published)
values
(
  'Pricing Your Products',
  'A 22-minute UVM Extension session on setting fair, sustainable prices for a small food/farm business — covers finding your true cost of production and adjusting prices without losing customers.',
  'https://www.youtube.com/watch?v=S3E1Ly3JjnI',
  'S3E1Ly3JjnI',
  'Pricing & Costing',
  'Beginner',
  'Directly useful before you fill in Ingredient Prices and Cost Calculator for your own products.',
  'cost',
  true,
  true
),
(
  'Pricing for Profit — Make Money From Your Small Business',
  'A short, practical explainer on why pricing has to cover your time and a real profit margin, not just the ingredient cost — a good primer before setting prices in Homies Kit.',
  'https://www.youtube.com/watch?v=gQBxvEKgbw8',
  'gQBxvEKgbw8',
  'Pricing & Costing',
  'Beginner',
  'A quick mindset reset on why "cost price + a bit" usually isn''t profitable.',
  'prices',
  false,
  true
);
