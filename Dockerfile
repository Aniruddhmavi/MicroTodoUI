# Multi-stage Dockerfile for MicroTodoUI (React)
# - Build stage runs as an unprivileged `builder` user
# - Runtime stage runs as an unprivileged `app` user and nginx listens on 8080

#########################
# 1) Build stage (non-root)
#########################
FROM node:18-alpine AS build

# Create a builder user and group
RUN addgroup -S builder && adduser -S -G builder builder

WORKDIR /app

# Copy package files and install dependencies as the non-root builder
COPY package*.json ./
RUN npm ci --silent
RUN chown -R builder:builder /app
USER builder


# Copy source files as builder and build
COPY --chown=builder:builder . .
RUN npm run build

#########################
# 2) Production stage (non-root runtime)
#########################
FROM nginx:1.25-alpine AS runtime

# Create a non-root runtime user `app`
RUN addgroup -S app && adduser -S -G app -u 1000 app

# Use a custom nginx config that listens on 8080 (non-privileged port)
RUN rm /etc/nginx/conf.d/default.conf || true
COPY nginx-app.conf /etc/nginx/conf.d/default.conf

# Copy static build output from the build stage
COPY --from=build /app/build /usr/share/nginx/html

# Ensure files are owned by the non-root user
RUN chown -R app:app /usr/share/nginx/html

# Switch to the non-root user
USER app

EXPOSE 8080

# Run nginx in the foreground (the binary in this image can run under a non-root user
# as we use non-privileged port 8080 and set file ownership accordingly).
CMD ["nginx", "-g", "daemon off;"]
