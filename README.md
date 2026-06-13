# Western Region NDC — Executive Registry (v2.0)

A working, offline-first Progressive Web App for registering and managing party executives across the whole **Western Region**, with constituency-level access. Built as a single self-contained HTML file with no build step, so it deploys exactly like your other GitHub Pages PWAs.

## What is in this folder

| File | Purpose |
|---|---|
| `index.html` | The entire application (UI, logic, storage). |
| `manifest.json` | PWA manifest so the app installs to a phone home screen. |
| `sw.js` | Service worker for offline app-shell caching (cache bumped to v6 for this release). |
| `icon-192.png`, `icon-512.png` | App icons (umbrella mark). |

## Organisational structure

The registry now has five levels:

**Region (Western) → Constituency → Ward / Electoral Area → Branch → Unit / Polling Station**

The 17 constituencies of the Western Region are seeded automatically and cannot be added or removed from within the app:

Ahanta West, Amenfi Central, Amenfi East, Amenfi West, Effia, Ellembelle, Essikado-Ketan, Evalue-Ajomoro (Evalue Gwira), Jomoro, Kwesimintsim, Mpohor, Prestea-Huni Valley, Sekondi, Shama, Takoradi, Tarkwa-Nsuaem, Wassa East.

Each constituency and the region itself can have their own executives (Chairman, Vice Chairmen, Secretary, Treasurer, Organizers, Women's and Youth Organizers, Communications Officer, Nasara Coordinator, and deputies where applicable), in addition to the Ward, Branch and Unit executives that existed in v1.

## First sign in

Open the app and log in with:

- **Username:** `admin`
- **Password:** `ndc2024`

This is the **Regional Administrator** account. Go to **Admin, Reset my password** and change it immediately.

## Roles and access

| Role | Access |
|---|---|
| **Regional Admin** | Sees and manages the whole region: all 17 constituencies, regional executives, user accounts. |
| **Constituency Admin** | Scoped to one constituency: its executives, wards, branches, units, search, reports, and album. |
| **Ward Admin / Branch Admin** | Standard create/edit access within their constituency's scope. |
| **Viewer** | Read-only access and exports within their scope. |

A Regional Admin creates new accounts from **Admin, + User**, choosing a role and, for everything except Regional Admin, the constituency the account is scoped to. Scoped users who try to open another constituency's records see an "Outside your access" message.

## Registration numbers

Every executive receives a permanent, system-generated registration number, assigned in sequence and never changed:

- Constituency and lower-level executives use the constituency's three-letter code, for example **ESK-0001**, **AHW-0001**, **SEK-0002**.
- Regional executives use **WR-0001**, **WR-0002**, and so on.

Numbering is independent per constituency, so each constituency's sequence starts at 0001.

## Features

- Five-level registry (Region, Constituency, Ward, Branch, Unit) with drill-down and breadcrumb navigation, scoped to the signed-in user's access.
- Regional dashboard with a per-constituency roll-up of executive counts; constituency dashboard for scoped users.
- Executive records with mandatory passport photo (camera or gallery), auto-compressed before saving.
- Full validation, phone-based and name plus date-of-birth duplicate detection.
- Search across all levels with constituency (regional admins), level, gender, and sort filters, including search by registration number.
- Reports: gender distribution across all five levels, coverage gaps, totals, CSV export, scoped to the user's access.
- Photo album report: passport photos in a grid, grouped by constituency in the regional view or by location in a scoped view, filterable, with a print or save-as-PDF layout for A4.
- Data tools: CSV export and import with a `constituency` column (constituencies, wards, branches, units matched by name and created if missing, with the correct registration prefix assigned automatically), full backup and restore as a single JSON file.
- Audit trail of every create, update, delete, import, export, and login.
- Installable and fully usable offline.

## Deploy to GitHub Pages

1. Create a new repository, for example `ndc-western-region`.
2. Upload all five files to the repository root.
3. In the repository, go to **Settings, Pages**, set the source to the `main` branch and the `/ (root)` folder, and save.
4. After a minute the app is live at `https://papadomah-tech.github.io/ndc-western-region/`.
5. Open that URL on a phone in Chrome and choose **Add to home screen** to install it.

Because everything is relative-pathed, no configuration is needed for the subpath. The service worker scope and manifest already use `./`.

## Upgrading from v1 (single constituency)

If this app is replacing a v1 (Keten Esikado-only) install on the same device, opening it the first time after the update runs a one-time migration automatically:

- Any wards already registered are attached to **Essikado-Ketan**.
- Any executives that were missing a registration number are backfilled with an ESK- prefixed number, continuing from the existing highest number.
- Executives that already had a KE-xxxx number keep it unchanged.
- If the existing admin account had the old "Constituency Admin" role with no constituency scope, it is promoted to **Regional Admin** so full access to the region is retained.

## How data is stored

Data lives on the device, in the browser database (IndexedDB). Nothing leaves the phone or laptop it was entered on. This makes the app instant and fully offline, but it also means each device holds its own separate registry.

To consolidate across devices, use **Data, Download full backup** on one device and **Restore from backup** on another, or move to the shared cloud backend described below.

## Moving to multi-device sync and real accounts

The storage layer in `index.html` is a small async key-value interface (`Store.get`, `set`, `del`, `keys`). It currently talks to IndexedDB. To get real multi-user accounts, scoped permissions, and live sync across phones and constituencies, point that same interface at Supabase using the schema and steps in the architecture spec and deployment guide. The user interface does not change; only the four `Store` methods do. Until then, treat the in-app accounts as device-local.

## Note on the architecture

This is version 2.0 of the system described in the architecture document, extended from a single-constituency registry to a region-wide registry with constituency-level access. It keeps the same zero-build, single-file design as v1, with the same offline-first storage layer, now organised around a five-level hierarchy and per-constituency registration numbering. The Supabase migration path above is how to grow into a full client-server design when shared, authenticated, real-time data across all 17 constituencies is needed.
