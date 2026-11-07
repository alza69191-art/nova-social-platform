# NOVA Social Platform

NOVA is an original Arabic-first social platform project for publishing, video, messaging, communities, creator channels, discovery, and digital marketplaces.

## Technology
- Next.js 15.5.29, React 19, and TypeScript.
- Render Web Service for application hosting.
- Supabase Auth, PostgreSQL with Row Level Security, Storage, and Realtime.
- GitHub Actions for type-check, lint, and production-build verification.

## Product modules
- Identity: signup, login, profiles, privacy, sessions, and account controls.
- Social: feed, posts, stories, comments, reactions, sharing, polls, and follows.
- Video: creator channels, publishing, playlists, and future live streaming.
- Communication: direct/group messages, attachments, and notifications.
- Communities: groups, pages, memberships, moderation, and events.
- Marketplace: products, digital goods, services, and later auctions/payments.
- Safety: reporting, blocking, moderation, rate limits, audit trails, and account security.
- Discovery: search, topics, recommendations, and optional AI tools.

## Current implementation
- Arabic RTL landing page and responsive styling.
- Supabase SSR signup/login, auth callback, and protected feed.
- Initial social schema and RLS for profiles, follows, posts, comments, and reactions.
- Expanded schema for stories, conversations, messages, groups, channels, videos, listings, notifications, reports, and blocks.
- Authenticated feed with text-post publishing and audience selection.

The expanded database migration is a foundation, not a claim that every module is production-ready. Messaging, uploads, moderation workflows, live video, payments, auctions, and AI integrations require separate implementation, provider setup, tests, and security review.

## Setup
1. Copy the example environment file to your local environment file.
2. Set the Supabase project URL and publishable key.
3. Install dependencies with npm install.
4. Apply migrations in supabase/migrations in filename order.
5. Start with npm run dev.

## Deployment
Render is configured through render.yaml. Add Supabase environment variables in the Render dashboard. Never commit real secrets.

## Product documentation
- [Full feature catalog](docs/FEATURE_CATALOG.md)
- [Product scope](docs/PRODUCT_SCOPE.md)
- [Roadmap](docs/ROADMAP.md)
- [Architecture and security](docs/ARCHITECTURE.md)
