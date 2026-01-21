FROM node:20-alpine as builder

# Set the working directory inside the container
WORKDIR /app

COPY package.json ./

RUN npm install

# Copy the rest of the application code
COPY . .

# Build the React application for production
# Vite typically outputs to a 'dist' directory
RUN npm run build

# Stage 2: Serve the application with Nginx
# Use a lightweight Nginx image
FROM nginx:stable-alpine

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy your custom Nginx configuration file
# This file should be in the root of your project alongside the Dockerfile
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built React app from the builder stage to the Nginx web root
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80, which Nginx will listen on
EXPOSE 80

# Command to run Nginx in the foreground
# This is important for Docker containers, as the container needs a process to keep running
CMD ["nginx", "-g", "daemon off;"]
