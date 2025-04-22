# Dockerfile

# 1. Build stage: install, test, and build
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source, run tests
COPY . .
RUN npm test

# Build production assets
RUN npm run build

# 2. Run stage: serve with nginx
FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]


# FROM node:18-alpine AS builder

# WORKDIR /app

# COPY package.json .

# RUN npm install

# COPY . .

# RUN npm run build


# FROM nginx

# COPY --from=builder /app/build /usr/share/nginx/html