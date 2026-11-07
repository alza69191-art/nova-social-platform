# NOVA Social Platform

NOVA is a unified social platform for publishing, video and creator channels, communities, messaging, marketplaces, and user-controlled privacy.

## Technology

- Next.js 15.5.29, React 19, and TypeScript.
- Render Web Service for application hosting.
- Supabase Auth, PostgreSQL with Row Level Security, Storage, and Realtime.
- GitHub Actions for type-check, lint, and production-build verification.

## Product direction

Build an original product experience inspired by familiar social-platform workflows. NOVA has its own identity, interface, implementation, and policies; it is not presented as an official integration or merger of other platforms.

## Core areas

- Social feed: posts, media, comments, replies, reactions, sharing, stories, and polls.
- Video and creator channels: public channels, video publishing, and creator profiles.
- Messaging: conversations, attachments, typing/read indicators, and configurable disappearing messages.
- Communities: groups, public/private pages, events, memberships, and moderation.
- Marketplace: listings, digital goods, auctions, and seller profiles.
- Trust and safety: reporting, blocking, moderation tools, rate limits, session controls, and account security.
- Personalization: notifications, follows, friends, badges, points, and accessibility settings.
- Optional AI assistance for discovery, creation, and moderation, subject to privacy controls.

## Product principles

1. Privacy and user control are first-class requirements.
2. Security-sensitive features must be implemented and tested, not represented by UI placeholders.
3. Ship in small, verifiable milestones; do not claim unfinished capabilities as complete.
4. Build a responsive, localization-ready experience with Arabic as a primary interface language.
5. Use original branding and avoid copying protected assets or proprietary interface elements.

## Getting started

1. Copy .env.example to .env.local.
2. Set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY.
3. Install dependencies with npm install.
4. Start the app with npm run dev.
5. Apply the SQL migration in supabase/migrations/ to the Supabase project before using social data features.

## Deployment

Render is configured through [render.yaml](render.yaml). Create a Render Web Service from this repository and provide the Supabase environment variables in the Render dashboard. Never commit real secrets.

## Project documents

- [Product scope](docs/PRODUCT_SCOPE.md)
- [Roadmap](docs/ROADMAP.md)
- [Architecture and security](docs/ARCHITECTURE.md)

## Current implementation status

The repository currently includes an Arabic RTL landing page, email/password signup and login, Supabase SSR cookie handling, auth callback, a protected feed placeholder, and the initial social database migration with RLS policies. Messaging, communities, video publishing, and marketplace flows are planned stages and are not yet implemented.
