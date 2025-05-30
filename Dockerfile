# Single-stage build for MCP-SSE-Proxy
FROM node:22-alpine

WORKDIR /usr/src/app

# Create a non-root user and group for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy package.json and package-lock.json (if you use one)
# These should be in your project root.
COPY package.json ./
# COPY package-lock.json ./ # Uncomment if you have a package-lock.json and prefer 'npm ci'

# Install all dependencies (including devDependencies needed for the build)
RUN npm install 
# If using package-lock.json, consider 'npm ci' for faster, more reliable builds

# Copy TypeScript configuration and source code
COPY tsconfig.json ./
COPY src ./src

# --- Configuration File ---
# Copy config.json from your project's base directory into the image.
# Make sure 'config.json' exists in the same directory as this Dockerfile when building.
COPY config.json /usr/src/app/config.json

# Build the TypeScript project (compiles .ts to .js in ./dist)
RUN npm run build

# Prune development dependencies to reduce the final image size
# For npm v7+ use --omit=dev. For older npm, use --production.
RUN npm prune --omit=dev

# Change ownership of all application files to the non-root user
RUN chown -R appuser:appgroup /usr/src/app

# Switch to the non-root user
USER appuser

# Expose the port the application runs on (default is 3006)
EXPOSE 3006

# Command to run the application
# This now points to the config.json that was copied into the image.
# Other parameters like port can still be overridden via docker-compose.
CMD ["npm", "start", "--", "--config", "/usr/src/app/config.json"]