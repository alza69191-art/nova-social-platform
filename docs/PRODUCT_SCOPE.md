# NOVA Product Scope

## Vision

A unified social destination where people can publish, watch, communicate, form communities, and trade through one account and a consistent experience.

## User-facing modules

### 1. Identity and profiles
- Registration, authentication, profile details, avatar, cover image, and account settings.
- Public profile visibility controls.
- Session management and optional two-factor authentication.

### 2. Social publishing
- Text and media posts.
- Stories with configurable visibility and expiry.
- Comments, threaded replies, reactions, sharing, and polls.
- Drafts and scheduled publishing are later-phase capabilities.

### 3. Video and channels
- Creator channels and channel pages.
- Video publishing and playback.
- Subscriptions/follows and creator discovery.
- Live streaming and advanced transcoding are outside the initial MVP.

### 4. Messaging and notifications
- Direct conversations, message history, and attachments.
- Typing and read indicators.
- Notification center for relevant account and community activity.
- Disappearing messages require clearly communicated retention behavior.

### 5. Communities and pages
- Public and private groups.
- Membership requests, roles, posts, and moderation.
- Public pages and events.

### 6. Marketplace
- Listings for products and digital goods.
- Seller profiles, search, and listing details.
- Auctions are a later milestone and require explicit bidding, expiry, and dispute rules.

### 7. Safety, privacy, and administration
- Block, report, mute, and content moderation workflows.
- Privacy settings and audience selection.
- Rate limiting, secure session handling, audit events, and admin roles.
- Data export and account deletion workflows.
- Encryption claims must match the actual cryptographic design and implementation.

### 8. Engagement and optional AI
- Points, badges, and achievement system with transparent rules.
- AI-assisted discovery, creation, and moderation only after data-use and consent rules are defined.

## MVP acceptance criteria

- A user can register, authenticate, and manage a profile.
- A user can publish a post and interact with another post.
- Feed visibility respects post audience and account privacy settings.
- Users can follow/unfollow and block/report accounts.
- Notifications are generated for core interactions.
- Admin moderation actions are permission-checked and auditable.
- The application works on mobile and desktop and supports Arabic RTL layouts.
- Automated tests cover authentication, authorization, privacy boundaries, and core publishing flows.

## Explicit non-goals for the first release

- Reproducing another company's product or copying protected visual assets.
- Claiming end-to-end encryption before an audited implementation exists.
- Live streaming, advanced video editing, or full-scale recommendation models.
- Real-money payments, escrow, or auction settlement before legal, provider, and fraud controls are designed.
