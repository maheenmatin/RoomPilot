# =========================
# 1) Builder image
# =========================
FROM node:20-alpine AS builder

WORKDIR /app

# Prisma needs DATABASE_URL defined even just for `prisma generate`.
# It does NOT need to be a real, reachable DB during build.
ARG DATABASE_URL="postgresql://meeting_user:meeting_password@localhost:5432/meeting_db?schema=public"
ENV DATABASE_URL=${DATABASE_URL}

# Install dependencies
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copy source
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Build Next.js app
RUN npm run build

# =========================
# 2) Runtime image (non-root)
# =========================
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copy only what we need at runtime
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/prisma ./prisma

# Run as non-root user provided by the base image
USER node

EXPOSE 3000
CMD ["npm", "run", "start"]
