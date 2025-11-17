# ------------ Stage 1: Build Angular app ------------
FROM node:20 AS builder

WORKDIR /app

# Copy dependency files
COPY package*.json ./
RUN npm ci

# Copy full project
COPY . .

# Build the Angular app (production build)
RUN npm run build -- --configuration production --base-href="/git-actions/"


# ------------ Stage 2: Run with Nginx ------------
FROM nginx:stable-alpine

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/*

# Copy Angular built files
COPY --from=builder /app/dist/git-actions/browser /usr/share/nginx/html

# SPA fallback (important!)
RUN printf 'server {\n  listen 80;\n  location / {\n    try_files $uri $uri/ /index.html;\n  }\n}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
