FROM node:18-alpine AS base

# development
FROM base as dev
ARG USER_ID
ARG GROUP_ID
USER $USER_ID:$GROUP_ID
CMD npm install && npm run dev -- --host 0.0.0.0

# build assets
FROM base as builder
COPY . /app
WORKDIR /app
RUN npm install && npm run build && npm prune --production

# nginx state for serving content
FROM nginx:alpine
# Set working directory to nginx asset directory
WORKDIR /usr/share/nginx/html
# Remove default nginx static assets
RUN rm -rf ./*
# Copy static assets from builder stage
COPY --from=builder /app/dist .

EXPOSE 80 443
# Containers run nginx with global directives and daemon off
ENTRYPOINT ["nginx", "-g", "daemon off;"]
