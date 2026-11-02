# MichroHelp Supabase setup

This repository includes the first database migration for the redesigned MichroHelp site.

## What it creates
- projects, courses, and gallery_items for public content managed by the admin
- enquiries for contact form submissions
- orders for project/course purchases and Razorpay references
- admin_users as the one-admin allowlist
- portfolio-media (public read) and course-files (private) storage buckets

Row Level Security is enabled. Visitors can read only published content and submit enquiries. Only an authenticated user added to admin_users can manage content and view enquiries/orders.

## Apply the migration
1. Create or select the intended Supabase project.
2. Install the Supabase CLI and authenticate locally.
3. Link the repository to the intended project: `supabase link --project-ref YOUR_PROJECT_REF`.
4. Review the SQL migration, then run `supabase db push`.

Do not paste credentials into GitHub or chat. Never expose the Supabase service_role key in browser JavaScript, static site config, or public environment variables.

## Add the first admin
1. In Supabase Authentication, invite the one admin email address.
2. After the user exists, copy the user's UUID from Authentication > Users.
3. Run this in the Supabase SQL Editor, replacing the placeholder:

```sql
insert into public.admin_users (user_id)
values ('PASTE_AUTH_USER_UUID_HERE')
on conflict (user_id) do nothing;
```

Do not enable public sign-up for the admin interface. Keep the allowlist to the one intended account.

## Required secure backend work
- Create Razorpay orders on the server; calculate price from the database, never from browser input.
- Verify Razorpay webhook signatures before marking an order paid.
- Issue short-lived signed URLs for private course downloads only after checking a paid order.
- Add server-side validation, spam/rate limiting, and audit logging to public endpoints.

The migration does not implement checkout, the login UI, or a production admin dashboard. `/admin-preview/` remains a visual prototype.
## Admin panel prototype

The first Supabase-connected admin interface is available at `/control/` on the Vercel preview. It supports email magic-link sign-in for an existing user, verifies membership in `admin_users`, and provides create/edit/delete screens for projects, courses, services, blog posts, gallery items and site settings, plus enquiry viewing. It is not linked into the public pages yet; public-site rendering integration and end-to-end testing are still required before production use.

In Supabase Authentication, create/invite the one admin user first, add their UUID to `public.admin_users`, and configure the project's Site URL plus Redirect URLs to include the preview URL and final domain. The panel asks for the project URL and public anon/publishable key; these are public client configuration values. Never enter a service_role key.

## Existing Decap CMS (/admin) additions

The existing Google-authorized Decap CMS now includes Projects, Freelancing Services, and Gallery collections alongside its existing Blog Posts, Courses, Pages, and Site Settings collections. Public Projects, Freelancing, and Gallery listing templates render entries created in those collections. Enquiry records are handled in the Supabase-backed `/control/` panel, not as a fake static CMS collection; contact-form submission still needs to be wired to Supabase before enquiries will appear there.
