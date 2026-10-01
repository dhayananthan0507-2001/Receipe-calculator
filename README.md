# Homies Kit V3 — Premium Food Business Experience

This version keeps the existing Homies Kit application logic while applying a major visual redesign:
- cinematic farm/crop hero
- animated image layers and subtle motion
- glassmorphism metric cards
- Farm → Kitchen → Product workflow
- large visual gallery using the included images
- premium food-industry color system
- responsive/mobile layouts
- polished authentication background

## Deployment
Upload the `index.html`, `auth.html`, `README.md`, and the entire `images` folder to GitHub. Keep the folder structure intact.


## V4 performance and UX improvements
- Authentication is now a single primary login experience; account creation and password recovery are secondary actions instead of competing login tabs.
- Dashboard startup loads products and extra ingredients in parallel.
- Pricing and production-cost data load in the background after the dashboard becomes usable.
- Removed the extra `auth.getUser()` network request used only to populate the header.
- Added Supabase preconnect/DNS-prefetch.
- Static gallery images use lazy loading and async decoding.
- Added lightweight transform/opacity animations, animated auth background/orbs, button sheen, and reduced-motion support.
- YouTube iframe API remains lazy-loaded only when a video is opened.
