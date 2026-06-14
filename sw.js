/* Ghana NDC Executive Registry — offline app shell
   Strategy:
   - The HTML document is fetched NETWORK-FIRST so a redeploy always reaches
     the user when online, with the cached copy used only as an offline fallback.
   - Static assets (icons, manifest) are cache-first for speed.
   - Supabase API calls (REST data) are NEVER cached — they must always hit
     the network, since the data is shared/live across devices and stale
     cached responses (including error responses) must never be replayed.
   Bump CACHE on every release so old shells, and any previously cached
   Supabase responses, are discarded. */
const CACHE = 'ndc-gh-v16';
const ASSETS = ['./', './index.html', './manifest.json', './icon-192.png', './icon-512.png'];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

function isDocument(req) {
  return req.mode === 'navigate' || req.destination === 'document' ||
         (req.headers.get('accept') || '').includes('text/html');
}

function isSupabase(req) {
  return req.url.includes('.supabase.co/');
}

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;

  // Supabase API requests: always go to the network, never cache (and
  // never serve a cached response, including cached errors).
  if (isSupabase(req)) {
    e.respondWith(fetch(req));
    return;
  }

  // HTML: network-first, fall back to cache when offline.
  if (isDocument(req)) {
    e.respondWith(
      fetch(req)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => { try { c.put('./index.html', copy); } catch (_) {} });
          return res;
        })
        .catch(() => caches.match(req).then((hit) => hit || caches.match('./index.html')))
    );
    return;
  }

  // Everything else: cache-first, then network (and cache the result).
  e.respondWith(
    caches.match(req).then((hit) => hit || fetch(req).then((res) => {
      const copy = res.clone();
      caches.open(CACHE).then((c) => { try { c.put(req, copy); } catch (_) {} });
      return res;
    }).catch(() => caches.match('./index.html')))
  );
});

// Allow the page to tell a waiting worker to take over immediately.
self.addEventListener('message', (e) => { if (e.data === 'skipWaiting') self.skipWaiting(); });
