# Ghana NDC Executive Registry (v3.0, National)

A working, offline-first Progressive Web App for registering and managing party executives across the whole country, with national, regional, and constituency-level access. Built as a single self-contained HTML file with no build step, so it deploys exactly like the earlier Western Region edition.

## What is in this folder

| File | Purpose |
|---|---|
| `index.html` | The entire application (UI, logic, storage). |
| `manifest.json` | PWA manifest so the app installs to a phone home screen. |
| `sw.js` | Service worker for offline app-shell caching (cache bumped to v7 for this release). |
| `icon-192.png`, `icon-512.png` | App icons (umbrella mark). |

## Organisational structure

The registry has five levels:

**Region (16) -> Constituency (276) -> Ward / Electoral Area -> Branch -> Unit / Polling Station**

All 16 regions and 276 constituencies of Ghana are seeded automatically and cannot be added or removed from within the app. Each region and each constituency can have its own executives (Chairman, Vice Chairmen, Secretary, Treasurer, Organizers, Women's and Youth Organizers, Communications Officer, Nasara Coordinator, and deputies where applicable), in addition to the Ward, Branch and Unit executives below them.

## First sign in

Open the app and log in with:

- **Username:** `admin`
- **Password:** `ndc2024`

This is the **National Administrator** account. On first login (and on any device where this account is still on the published default password), you will be required to set a new password immediately, before the rest of the app becomes available. The default password stops working on that device the moment a new one is set.

To change your password again later, go to **Admin** and use **Reset my password**, which requires your current password plus a confirmation of the new one.

### Important: this is a per-device security boundary

Because this app stores its data locally on each device (see "How data is stored" below), the `admin` / `ndc2024` default is only ever a one-time setup credential **for the device it is used on**. Changing the password on one phone or computer does not change it on any other device: each device that has never had this account log in will still offer `admin` / `ndc2024` as the starting credential, and will immediately force a new password to be set on first use there too.

If staff were given the shared `admin` / `ndc2024` credential during rollout, treat every device that login was used on as needing its own password change (or, better, create individually named accounts from **Admin, + User** and stop using the shared `admin` account for day-to-day access).

## Roles and access

| Role | Access |
|---|---|
| **National Admin** | Sees and manages the whole country: all 16 regions, all 276 constituencies, region-level executives, user accounts. |
| **Constituency Admin** | Scoped to one constituency: its executives, wards, branches, units, search, reports, and album. |
| **Ward Admin / Branch Admin** | Standard create/edit access within their constituency's scope. |
| **Viewer** | Read-only access and exports within their scope. |

A National Admin creates new accounts from **Admin, + User**, choosing a role and, for everything except National Admin, the constituency the account is scoped to (the constituency list is grouped by region to make this easier with 276 options). Scoped users who try to open another region's or constituency's records see an "Outside your access" message.

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

- Five-level registry (Region, Constituency, Ward, Branch, Unit) with drill-down and breadcrumb navigation, scoped to the signed-in user's access. National Admins start at a list of 16 regions, drill into a region to see its constituencies and region executives, then into a constituency for its wards.
- National dashboard with a per-region roll-up of executive counts (16 rows); constituency dashboard for scoped users.
- Executive records with mandatory passport photo (camera or gallery), auto-compressed before saving.
- Full validation, phone-based and name plus date-of-birth duplicate detection.
- Search across all levels with region and constituency filters (grouped by region), level, gender, and sort filters, including search by registration number.
- Reports: gender distribution across all five levels, coverage gaps, totals (regions, constituencies, wards, branches, units), CSV export, scoped to the user's access.
- Photo album report: passport photos in a grid, grouped by region for region-level executives and by constituency (with region shown) elsewhere in the national view, or by location in a scoped view, filterable by region and constituency, with a print or save-as-PDF layout for A4.
- Data tools: CSV export and import with `region` and `constituency` columns (regions and constituencies matched by name or code, with the region column used to disambiguate duplicate constituency names; wards, branches, and units matched by name and created if missing, with the correct registration prefix assigned automatically), full backup and restore as a single JSON file.
- Audit trail of every create, update, delete, import, export, and login.
- Installable and fully usable offline.

## Deploy to GitHub Pages

1. Create a new repository, for example `ndc-national-registry`.
2. Upload all five files to the repository root.
3. In the repository, go to **Settings, Pages**, set the source to the `main` branch and the `/ (root)` folder, and save.
4. After a minute the app is live at `https://papadomah-tech.github.io/ndc-national-registry/`.
5. Open that URL on a phone in Chrome and choose **Add to home screen** to install it.

Because everything is relative-pathed, no configuration is needed for the subpath. The service worker scope and manifest already use `./`.

## Upgrading from v2.0 (Western Region only)

If this app is replacing a v2.0 (Western Region only) install on the same device, opening it the first time after the update runs a one-time migration automatically:

- The existing 17 Western Region constituencies are kept with their original codes and registration numbers, and are attached to the Western Region (code **WR**) in the new 16-region structure.
- The remaining 15 regions and their 259 constituencies are seeded alongside Western Region, bringing the total to 16 regions and 276 constituencies.
- Any existing **Regional Admin** account is promoted to **National Admin**, with full access to all 16 regions.
- Any region-level executive that existed before (which could only have been a Western Region executive) is linked to the Western Region, and keeps its existing **WR-xxxx** registration number. New region-level executives for Western Region continue that same sequence.
- Any executives that were missing a registration number are backfilled in the same way as before, continuing from the existing highest number for their prefix.

If this app is replacing a v1 (single-constituency, Keten Esikado) install, the v1-to-v2 migration (attaching legacy wards to Essikado-Ketan and promoting an unscoped admin account) still runs first, followed by the v2-to-v3 national migration described above.

## How data is stored

Data lives on the device, in the browser database (IndexedDB). Nothing leaves the phone or laptop it was entered on. This makes the app instant and fully offline, but it also means each device holds its own separate registry.

To consolidate across devices, use **Data, Download full backup** on one device and **Restore from backup** on another, or move to the shared cloud backend described below.

## Moving to multi-device sync and real accounts

The storage layer in `index.html` is a small async key-value interface (`Store.get`, `set`, `del`, `keys`). It currently talks to IndexedDB. To get real multi-user accounts, scoped permissions, and live sync across phones, regions, and constituencies, point that same interface at Supabase using the schema and steps in the architecture spec and deployment guide. The user interface does not change; only the four `Store` methods do. Until then, treat the in-app accounts as device-local.

## Note on the architecture

This is version 3.0 of the system described in the architecture document, extended from a single-region registry (Western Region, 17 constituencies) to a national registry covering all 16 regions and 276 constituencies of Ghana, with national-level and constituency-level access (no separate regional-admin tier). It keeps the same zero-build, single-file design as earlier versions, with the same offline-first storage layer, now organised around a national five-level hierarchy with unique per-constituency and per-region registration numbering. The Supabase migration path above is how to grow into a full client-server design when shared, authenticated, real-time data across all 276 constituencies is needed.
