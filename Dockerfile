# 1st Stage: Build the Next.js app
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies separately to leverage Docker caching
COPY package.json package-lock.json ./
RUN npm ci --only=production

# Copy the rest of the app and build it
COPY . .
RUN npm run build

# 2nd Stage: Run the app in a minimal runtime
FROM node:18-alpine

WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app/package.json /app/package-lock.json ./
RUN npm ci --only=production

# Copy Next.js build output
COPY --from=builder /app/.next ./.next

# Expose port and start the app
EXPOSE 3000
CMD ["npm", "run", "start"]
