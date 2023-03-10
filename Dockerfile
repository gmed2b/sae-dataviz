# 1. Install dependencies only when needed
FROM node:16-alpine AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN yarn --frozen-lockfile

# 2. Rebuild the source code only when needed
FROM node:16-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# This will do the trick, use the corresponding env file for each environment.
# COPY .env.production.sample .env.production
RUN yarn build
EXPOSE 4173
ENV PORT 4173
CMD ["yarn", "preview"]

# 3. Production image, copy all the files and run next
# FROM node:16-alpine AS runner
# WORKDIR /app

# ENV NODE_ENV=production

# RUN addgroup -g 1001 -S nodejs
# RUN adduser -S dataviz -u 1001

# COPY --from=builder /app/public ./public

# # Automatically leverage output traces to reduce image size
# # https://dataviz.org/docs/advanced-features/output-file-tracing
# COPY --from=builder --chown=dataviz:nodejs /app/dist ./

# USER dataviz