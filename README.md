# Keten Esikado Constituency NDC — Executive Registry

A working, offline-first Progressive Web App for registering and managing party executives across three levels: **Ward / Electoral Area → Branch → Unit / Polling Station**. Built as a single self-contained HTML file with no build step, so it deploys exactly like your other GitHub Pages PWAs.

## What is in this folder

| File | Purpose |
|---|---|
| `index.html` | The entire application (UI, logic, storage). |
| `manifest.json` | PWA manifest so the app installs to a phone home screen. |
| `sw.js` | Service worker for offline app-shell caching. |
| `icon-192.png`, `icon-512.png` | App icons (umbrella mark). |

## First sign in

Open the app and log in with:

- **Username:** `admin`
- **Password:** `ndc2024`

Go to **Admin → Reset admin password** and change it immediately.

## Features

- Three-tier registry with drill-down (Ward → Branch → Unit) and breadcrumb navigation.
- Every executive receives a permanent, system-generated registration number (KE-0001, KE-0002, …), assigned in sequence and never changed.
- Executive records with mandatory passport photo (camera or gallery), auto-compressed before saving.
- Full validation, phone-based and name plus date-of-birth duplicate detection.
- Dashboard: counts, gender distribution, coverage bars, recent activity.
- Search with level, gender, and sort filters.
- Reports: gender by level, coverage gaps, totals, CSV export.
- Data tools: CSV export, CSV import (wards/branches/units matched by name and created if missing), full backup and restore as a single JSON file.
- Role-based accounts (Constituency Admin, Ward Admin, Branch Admin, Viewer).
- Audit trail of every create, update, delete, import, export, and login.
- Installable and fully usable offline.

## Deploy to GitHub Pages

1. Create a new repository, for example `ndc-keten-esikado`.
2. Upload all five files to the repository root.
3. In the repository, go to **Settings → Pages**, set the source to the `main` branch and the `/ (root)` folder, and save.
4. After a minute the app is live at `https://papadomah-tech.github.io/ndc-keten-esikado/`.
5. Open that URL on a phone in Chrome and choose **Add to home screen** to install it.

Because everything is relative-pathed, no configuration is needed for the subpath. The service worker scope and manifest already use `./`.

## How data is stored

Data lives on the device, in the browser database (IndexedDB). Nothing leaves the phone or laptop it was entered on. This makes the app instant and fully offline, but it also means each device holds its own separate registry.

To consolidate across devices, use **Data → Download full backup** on one device and **Restore from backup** on another, or move to the shared cloud backend below.

## Moving to multi-device sync and real accounts

The storage layer in `index.html` is a small async key/value interface (`Store.get`, `set`, `del`, `keys`). It currently talks to IndexedDB. To get real multi-user accounts, scoped permissions, and live sync across phones, point that same interface at Supabase using the schema and steps in the architecture spec and deployment guide. The user interface does not change; only the four `Store` methods do. Until then, treat the in-app accounts as device-local.

## Note on the architecture

This is the working version 1 of the system described in the architecture document. It keeps the same data model, the same three-tier hierarchy, the same position slate, and the same features, but ships as a zero-build single file for immediate deployment rather than as a compiled React project. The Supabase migration path above is how you grow into the full client-server design when you need shared, authenticated, real-time data.
