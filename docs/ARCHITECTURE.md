# NOVA Architecture

## Selected hosting and data services

- **Render Web Service:** hosts the Next.js Node.js application and server-rendered routes.
- **Supabase Auth:** email/password identity and cookie-based SSR sessions.
- **Supabase PostgreSQL:** application data, relational constraints, and Row Level Security (RLS).
- **Supabase Storage:** user-uploaded avatars, images, and video objects, with private/public bucket policies.
- **Supabase Realtime:** live messaging and notification updates where appropriate.
- **GitHub:** source control and deployment trigger for the Render service.

## Runtime

- Next.js 15.5.29 App Router, React 19, TypeScript.
- Supabase SSR clients are created separately for browser and server execution.
- `middleware.ts` refreshes auth claims and session cookies for Next.js 15.
- Render runs `npm install && npm run build`, then `npm run start`.

## Required Render environment variables

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (or legacy `NEXT_PUBLIC_SUPABASE_ANON_KEY`)

Do not commit real credentials. The Supabase service-role key is intentionally not included in the client setup and must never be exposed to browser code. Add it to Render only if a later server-only administrative operation genuinely requires it.

## Security requirements

1. Enable RLS on every table exposed through the Supabase API.
2. Derive user identity from verified Supabase sessions; never trust a user ID supplied by the browser for authorization.
3. Keep service-role credentials server-only.
4. Validate upload MIME type, size, ownership, and storage path.
5. Apply least-privilege policies to Storage buckets and database tables.
6. Keep authenticated pages dynamic and do not publicly cache responses containing session cookies.
7. Add rate limits and abuse controls before opening public registration at scale.

## Initial implementation

The repository includes a branded Arabic RTL landing page, email/password signup and login, SSR cookie handling, auth callback, and a protected feed placeholder. The first database migration adds the initial social graph and publishing tables with RLS. Messaging, communities, video, and marketplace remain staged features, not yet implemented.
