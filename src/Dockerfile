# --------------------------
# 1️⃣ Build Stage
# --------------------------
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy rest of the app
COPY . .

# Build the production app
RUN npm run build

# --------------------------
# 2️⃣ Nginx Serve Stage
# --------------------------
FROM nginx:1.25-alpine

# Copy build output from previous stage
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
