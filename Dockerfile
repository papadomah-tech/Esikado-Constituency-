# Ghana NDC Executive Registry - container image
#
# This app is a single self-contained, static HTML PWA (no build step,
# no server-side code). This image simply serves the static files with
# nginx, with the correct headers for a PWA (especially around caching
# the service worker and app shell).
#
# Build:
#   docker build -t ndc-registry .
#
# Run:
#   docker run -p 8080:8080 ndc-registry
#
# Then open http://localhost:8080

FROM nginx:1.27-alpine

# Remove the default nginx site and replace it with our config.
RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the static app files into nginx's web root.
COPY index.html manifest.json sw.js icon-192.png icon-512.png /usr/share/nginx/html/

# nginx:alpine already runs as an unprivileged user by default and listens
# on the port configured in nginx.conf.
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
