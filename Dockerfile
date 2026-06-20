# syntax=docker/dockerfile:1

# =====================================================================
# STAGE 1: BASE — shared foundation with Node & package files
# =====================================================================
FROM node:24-alpine AS base
WORKDIR /app

# Only copy manifests first so Docker can cache this layer independently
COPY package.json package-lock.json* ./

# =====================================================================
# STAGE 2: DEPENDENCIES — install ALL deps
# =====================================================================
FROM base AS deps
# --frozen-lockfile ensures reproducible installs
RUN npm ci

# =====================================================================
# STAGE 3: DEVELOPMENT — hot-reload dev server
# =====================================================================
FROM deps AS development
ENV NODE_ENV=development
COPY . .
EXPOSE 5173
# Start Vite with --host to expose it outside the container
CMD ["npm", "run", "dev", "--", "--host"]

# =====================================================================
# STAGE 4: BUILDER — compile the Vite application
# =====================================================================
FROM deps AS builder
WORKDIR /app
COPY . .
# Build the production bundle (outputs to dist/)
RUN npm run build

# =====================================================================
# STAGE 5: PRODUCTION — minimal, secure, Nginx server
# =====================================================================
FROM nginx:alpine AS production
# Copy the built assets from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Add a custom nginx config for Single Page Applications (SPA)
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]