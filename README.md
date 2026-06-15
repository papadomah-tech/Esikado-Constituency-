# Ghana NDC Executive Registry (v3.0, National)

A working, offline-first Progressive Web App for registering and managing party executives across the whole country, with national, regional, and constituency-level access. Built as a single self-contained HTML file with no build step, so it deploys exactly like the earlier Western Region edition.

## What is in this folder

| File | Purpose |
|---|---|
| `index.html` | The entire application (UI, logic, storage). |
| `manifest.json` | PWA manifest so the app installs to a phone home screen. |
| `sw.js` | Service worker for offline app-shell caching (cache bumped to v8 for this release). |
| `icon-192.png`, `icon-512.png` | App icons (umbrella mark). |
| `Dockerfile`, `nginx.conf`, `docker-compose.yml`, `.dockerignore` | Container build for deploying the app as a static site (see "Deploy with Docker" below). |

## Organisational structure

The registry has four levels:

**Region (16) -> Constituency (276) -> Zonal/Electoral Area -> Branch**

All 16 regions and 276 constituencies of Ghana are seeded automatically and cannot be added or removed from within the app. Each region and each constituency can have its own executives (Chairman, Vice Chairmen, Secretary, Treasurer, Organizers, Women's and Youth Organizers, Communications Officer, Nasara Coordinator, and deputies where applicable). Each Zonal/Electoral Area has a single elected Zonal Coordinator. Each Branch has its own nine-position executive slate (Chairman, Secretary, Organizer, Youth Organizer, Women's Organizer, Communications Officer, Treasurer, Executive Member 1, Executive Member 2) and is the lowest level in the structure.

## First sign in

Open the app and log in with:

- **Username:** `admin`
- **Password:** `ndc2024`

This is the **National Administrator** account. On first login, you will be required to set a new password immediately, before the rest of the app becomes available. This account, and every account, is stored centrally, so once the password is changed it applies on every device immediately and the default stops working everywhere.

To change your own password later, use the account icon (👤) in the top bar.

## Roles and access

| Role | Access |
|---|---|
| **National Admin** | Sees and manages the whole country: all 16 regions, all 276 constituencies, region-level executives, and user accounts (suspend, reset, or delete any account). |
| **Constituency Admin** | Scoped to one constituency: its executives, zonal/electoral areas, branches, search, reports, and album. Can also create and manage user accounts (any non-national role, including other Constituency Admins) for that constituency. |
| **Zonal/Electoral Area Admin / Branch Admin** | Standard create/edit access within their constituency's scope. |
| **Branch Secretary** | An additional flag on a Branch Admin account, scoped to one specific branch. Grants access to that branch's Branch Register (the list of registered party members used for nomination verification), in addition to the normal Branch Admin access. |
| **Viewer** | Read-only access and exports within their scope. |

A National Admin or Constituency Admin creates new accounts from **Admin, + User**, choosing a role and a temporary password; the new user must set their own password the first time they sign in. When the role is Branch Admin, a branch can be selected and the account optionally designated as that branch's Branch Secretary. Scoped users who try to open another region's or constituency's records see an "Outside your access" message. Accounts can be suspended (blocking login with a message), have their password reset (forcing a new password on next sign in), or be deleted from the Admin page.

## Branch Register

Each branch has its own Branch Register: a list of registered party members at that branch, each assigned an auto-generated registry number (separate from the NDC member ID used for executive records) in the format `MEMBER-<branch>-0001`. The register is opened from the **Branch Register** button on a branch's page, visible to the National Admin, the Constituency Admin for that constituency, and the branch's designated Branch Secretary. Entries record full name, phone, gender, and date of birth, and can be edited or removed at any time.

## Nominations

A National Admin or Constituency Admin can open nominations for a branch from the **Nominations** card on that branch's page. While open, anyone can visit the login page, choose **File a nomination**, select their region, constituency, zonal/electoral area, and branch, and enter their Branch Register registry number to verify their identity. Once verified, they choose one of the branch's nine positions, confirm their phone, gender, and date of birth, and submit. A member cannot file more than one nomination per position, and the form only offers positions they have not already filed for.

Filed nominations appear as **pending** on the branch's **Review nominations** page (National Admin or Constituency Admin only), where each can be **cleared** (confirmed as a candidate) or **rejected**. Cleared candidates get a **Copy message** button that places a ready-to-send notification (confirming the position and branch) on the clipboard, to be pasted into an SMS or WhatsApp message manually; the system marks the candidate as notified once the message has been copied.

## Registration numbers

Every executive receives a permanent, system-generated registration number, assigned in sequence and never changed:

- Constituency and lower-level executives use the constituency's unique code, for example **ESK-0001**, **AHW-0001**, **SEK-0002**.
- Region-level executives use the region's own code, for example **ASH-0001** for an Ashanti regional executive, **WR-0001** for a Western regional executive.

Numbering is independent per code, so each constituency's and each region's sequence starts at 0001.

### Duplicate constituency names across regions

A handful of constituency names are repeated in more than one region (for example "Bole" exists in both Northern and Savannah, and "Chereponi" exists in both North East and Northern). Each occurrence still gets its own unique code so registration numbers never collide, for example:

- Bole, Northern Region -> code **BOL** -> registration numbers **BOL-0001**, **BOL-0002**, ...
- Bole, Savannah Region -> code **BOLE** -> registration numbers **BOLE-0001**, **BOLE-0002**, ...

The Registry, Search, Reports, Album, and Data screens always show the region alongside any constituency name that is not unique on its own, so it is clear which "Bole" (or "Chereponi", "Damango", "Daboya-Mankarigu") a record belongs to.

Region codes and constituency codes are also kept distinct from each other nationwide, so a constituency such as Ashaiman (code **ASHA**) never shares a numbering sequence with the Ashanti region (code **ASH**), even though the names look similar.

## Features

- Four-level registry (Region, Constituency, Zonal/Electoral Area, Branch) with drill-down and breadcrumb navigation, scoped to the signed-in user's access. National Admins start at a list of 16 regions, drill into a region to see its constituencies and region executives, then into a constituency for its zonal/electoral areas and branches.
- National dashboard with a per-region roll-up of executive counts (16 rows); constituency dashboard for scoped users.
- Executive records with mandatory passport photo (camera or gallery) and mandatory NDC member ID number, auto-compressed photo before saving.
- Full validation, phone-based and name plus date-of-birth duplicate detection.
- Search across all levels with region and constituency filters (grouped by region), level, gender, and sort filters, including search by registration number or NDC member ID.
- Reports: gender distribution across all levels, coverage gaps, totals (regions, constituencies, zonal/electoral areas, branches), CSV export, scoped to the user's access.
- Photo album report: passport photos in a grid, grouped by region for region-level executives and by constituency (with region shown) elsewhere in the national view, or by location in a scoped view, filterable by region and constituency, with a print or save-as-PDF layout for A4.
- Data tools: CSV export and import with `region`, `constituency`, and `memberId` columns (regions and constituencies matched by name or code, with the region column used to disambiguate duplicate constituency names; zonal/electoral areas and branches matched by name and created if missing, with the correct registration prefix assigned automatically), full backup and restore as a single JSON file.
- Audit trail of every create, update, delete, import, export, and login. The National Admin sees activity from every user; all other users see only their own activity, both on the dashboard and the Activity tab.
- Installable and fully usable offline.

## Deploy to GitHub Pages

1. Create a new repository, for example `ndc-national-registry`.
2. Upload all five files to the repository root.
3. In the repository, go to **Settings, Pages**, set the source to the `main` branch and the `/ (root)` folder, and save.
4. After a minute the app is live at `https://papadomah-tech.github.io/ndc-national-registry/`.
5. Open that URL on a phone in Chrome and choose **Add to home screen** to install it.

Because everything is relative-pathed, no configuration is needed for the subpath. The service worker scope and manifest already use `./`.

## Deploy with Docker

The app is a static site (no server-side code, no database connection of its own), so the `Dockerfile` simply packages `index.html`, `manifest.json`, `sw.js`, and the two icon files into a small `nginx:alpine` image and serves them.

Build and run locally:

```
docker build -t ndc-registry .
docker run -p 8080:8080 ndc-registry
```

or with Docker Compose:

```
docker compose up --build
```

Then open `http://localhost:8080`.

### Notes for hosting platforms (for example Supabase)

- The container listens on port **8080** and exposes a `GET /healthz` endpoint that returns `200 ok`, for platforms that require a health check.
- `index.html` and `sw.js` are served with `Cache-Control: no-cache, no-store, must-revalidate` so that every deploy reaches users immediately and the service worker's own `CACHE` version (bumped on each release) takes effect right away. The PWA's offline support still works because the service worker caches the app shell client-side after the first successful load.
- `manifest.json` and the icons are served with a short cache lifetime (`max-age=3600`).
- Because all data is stored locally in each user's browser (see "How data is stored" below), this container is stateless: it serves the same static files to every user, and there is nothing to back up or persist on the server side. No environment variables, database connection, or secrets are required.
- If the platform expects the app to live at a sub-path rather than the domain root, the relative-pathed assets (`./manifest.json`, `./sw.js`, `./icon-*.png`) and the manifest's `start_url`/`scope` (`./`) should continue to work without changes, as long as the platform serves `index.html` at that sub-path's root.

## Upgrading from v2.0 (Western Region only)


If this app is replacing a v2.0 (Western Region only) install on the same device, opening it the first time after the update runs a one-time migration automatically:

- The existing 17 Western Region constituencies are kept with their original codes and registration numbers, and are attached to the Western Region (code **WR**) in the new 16-region structure.
- The remaining 15 regions and their 259 constituencies are seeded alongside Western Region, bringing the total to 16 regions and 276 constituencies.
- Any existing **Regional Admin** account is promoted to **National Admin**, with full access to all 16 regions.
- Any region-level executive that existed before (which could only have been a Western Region executive) is linked to the Western Region, and keeps its existing **WR-xxxx** registration number. New region-level executives for Western Region continue that same sequence.
- Any executives that were missing a registration number are backfilled in the same way as before, continuing from the existing highest number for their prefix.

If this app is replacing a v1 (single-constituency, Keten Esikado) install, the v1-to-v2 migration (attaching legacy wards to Essikado-Ketan and promoting an unscoped admin account) still runs first, followed by the v2-to-v3 national migration described above.

## How data is stored

All registry data, including user accounts, executives and their photos, wards, branches, units, registration number sequences, and the activity log, is stored centrally in Supabase (Postgres). Every device that opens the app reads and writes the same shared data in real time, so an executive registered on one phone is immediately visible on every other device. The browser itself only keeps a small marker of which user is currently signed in, so a page refresh does not log you out; no registry records are stored in the browser.

`supabase_schema.sql` sets up the database. If you already have this app deployed and are updating to a newer version of `index.html`, check the bottom of `supabase_schema.sql` for any new migration statements (for example, new columns added to the executives table) and re-run the whole file in the Supabase SQL editor; statements are written to be safe to re-run.

## Moving to multi-device sync and real accounts

This is already done as of v4.0: the app reads and writes Supabase directly via its REST API (`SUPABASE_URL` and the anon key are set near the top of `index.html`). User accounts, executive records, and the rest of the registry are shared across every device automatically. No further setup is needed beyond running `supabase_schema.sql` once against your Supabase project.

## Note on the architecture

This is version 5.0 of the system. It builds on the v4.0 national rebuild (all 16 regions and 276 constituencies of Ghana, backed by a shared Supabase database for real-time multi-device sync) and restructures the lower levels of the hierarchy: the former Ward level is renamed Zonal/Electoral Area with a single elected Zonal Coordinator position, the Unit/Polling Station level is retired (existing unit-level records remain in the database for historical integrity but are hidden from all views), and Branches now use a fixed nine-position executive slate (Chairman, Secretary, Organizer, Youth Organizer, Women's Organizer, Communications Officer, Treasurer, Executive Member 1, Executive Member 2) and are the lowest level in the structure. The 16 regions and 276 constituencies remain fixed constants in the app code, since they never change; everything else (users, executives, zonal/electoral areas, branches, registration sequences, audit log) lives in Supabase.
