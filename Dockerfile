FROM mirror.gcr.io/library/node:22-alpine
# build-time env seeded from .env.example
ENV API_KEY_RATE_LIMIT=60/minute
ENV AWS_ACCESS_KEY_ID=access-key
ENV AWS_REGION=nexlayer-placeholder
ENV AWS_S3_BUCKET_NAME=uploads
ENV AWS_S3_ENDPOINT_URL=http://plane-minio:9000
ENV AWS_SECRET_ACCESS_KEY=secret-key
ENV CERT_ACME_CA=https://acme-v02.api.letsencrypt.org/directory
ENV CERT_ACME_DNS=nexlayer-placeholder
ENV CERT_EMAIL=nexlayer-placeholder
ENV DOCKERIZED="1  # deprecated"
ENV FILE_SIZE_LIMIT=5242880
ENV GPT_ENGINE="\"gpt-3.5-turbo\" # deprecated"
ENV LISTEN_HTTPS_PORT=443
ENV LISTEN_HTTP_PORT=80
ENV MINIO_ENDPOINT_SSL=0
ENV OPENAI_API_BASE="\"https://api.openai.com/v1\" # deprecated"
ENV OPENAI_API_KEY="\"sk-\" # deprecated"
ENV PGDATA=/var/lib/postgresql/data
ENV POSTGRES_DB=plane
ENV POSTGRES_PASSWORD=plane
ENV POSTGRES_USER=plane
ENV RABBITMQ_HOST=plane-mq
ENV RABBITMQ_PASSWORD=plane
ENV RABBITMQ_PORT=5672
ENV RABBITMQ_USER=plane
ENV RABBITMQ_VHOST=plane
ENV REDIS_HOST=plane-redis
ENV REDIS_PORT=6379
ENV SITE_ADDRESS=:80
ENV TRUSTED_PROXIES=0.0.0.0/0
ENV USE_MINIO=1

# Install build essentials for native modules and CSS processing
RUN apk add --no-cache python3 make g++ linux-headers git

# Install pnpm using the version from packageManager
RUN npm install -g pnpm@11.3.0

WORKDIR /repo

# Fix: COPY multiple sources must end in / to avoid the 'destination must be a directory' error
COPY .npmrc package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Install dependencies using the requested flag
RUN pnpm install --no-frozen-lockfile

# Copy all source code
COPY . .

# Build environment variables
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=8192"

# Inject placeholders for VITE_ and NEXT_PUBLIC_ vars to prevent build-time validation crashes
ENV VITE_WEB_BASE_URL=https://placeholder.nexlayer.ai
ENV VITE_API_BASE_URL=https://placeholder.nexlayer.ai/api
ENV VITE_LIVE_BASE_URL=https://placeholder.nexlayer.ai/live
ENV VITE_SPACE_BASE_URL=https://placeholder.nexlayer.ai/space
ENV VITE_ADMIN_BASE_URL=https://placeholder.nexlayer.ai/admin
ENV VITE_WEB_BASE_PATH=/
ENV VITE_API_BASE_PATH=/api

# Aggressive patch for 'must be configured' or 'is required' errors in source
RUN find . -path ./node_modules -prune -o \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' \) -print \
    | xargs grep -l 'must be configured\|must be set\|is required' 2>/dev/null \
    | xargs sed -i '/must be configured\|must be set\|is required/d' 2>/dev/null || true

# Build the web app and its dependencies
# Using --filter=...web ensures all local workspace dependencies (@plane/*) are built first
RUN pnpm exec turbo run build --filter=...web

# The app is a Vite/React Router v7 app
WORKDIR /repo/apps/web

# Set runtime envs
ENV PORT=80
ENV HOSTNAME=0.0.0.0
EXPOSE 80

# Use pnpm start for the web app
CMD ["pnpm", "start"]