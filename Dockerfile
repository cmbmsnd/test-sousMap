# Stage 1: Build the Angular application
#----------------------------------------
# Use a specific Node LTS version (Alpine for smaller size)
FROM node:20-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or npm-shrinkwrap.json)
COPY package.json package-lock.json ./

# Install dependencies using npm ci for faster, reproducible builds
RUN npm ci

# Copy the rest of the application source code
COPY . .

# Build the application for production
# The output will be in /app/dist/test-sous-map based on angular.json
RUN npm run build

# Stage 2: Serve the application with Nginx
#------------------------------------------
# Use a lightweight Nginx image (Alpine variant)
FROM nginx:alpine

# Remove default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom Nginx configuration file created above
# Assumes nginx.conf is in the same directory as the Dockerfile
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the build artifacts from the 'build' stage to the Nginx web root directory
COPY --from=build /app/dist/test-sous-map/browser /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# The default Nginx command starts the server.
# CMD ["nginx", "-g", "daemon off;"] is implicitly run by the base image.
