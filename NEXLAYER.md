# Nexlayer — plane

<!-- nexlayer:meta version=1 analyzed=2026-06-26T18:50:15Z repo=https://github.com/armondhonore/plane branch=nexlayer -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
Plane is an open-source project management platform designed to track issues, manage cycles, and organize product roadmaps, featuring a monorepo architecture with separate frontend and backend services.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Node.js | language | >=22.18.0 | package.json |
| Turborepo | build | latest | turbo.json |
| pnpm | tool | 11.3.0 | package.json |
| PostgreSQL | database | latest | docker-compose.yml |
| Redis | cache | latest | docker-compose.yml |
| React | framework | latest | pnpm-workspace.yaml |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- apps/web/ — Primary user-facing web application
- apps/admin/ — Administrative dashboard for platform management
- apps/space/ — Space-specific project management interface
- apps/api/ — Backend REST API and core business logic
- apps/live/ — Real-time collaboration and synchronization service
- packages/ — Shared internal libraries and UI components
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- Sentry (SENTRY_DSN)
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Node.js >= 22.18.0
- pnpm >= 11.3.0

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
DATABASE_URL=postgresql://postgres:password@localhost:5432/plane
REDIS_URL=redis://localhost:6379/0
NODE_ENV=development
```

### Steps

1. `pnpm install` — Install workspace-wide dependencies
2. `pnpm dev` — Start all applications in development mode via Turborepo

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `web` | `NODE_ENV` | `"production"` | plain |
| `web` | `PORT` | `"80"` | plain |
| `web` | `HOSTNAME` | `"0.0.0.0"` | plain |
| `web` | `VITE_WEB_BASE_URL` | `"<% URL %>"` | plain |
| `web` | `VITE_API_BASE_URL` | `"<% URL %>/api"` | plain |
| `web` | `VITE_LIVE_BASE_URL` | `"<% URL %>/live"` | plain |
| `web` | `VITE_SPACE_BASE_URL` | `"<% URL %>/space"` | plain |
| `web` | `VITE_ADMIN_BASE_URL` | `"<% URL %>/admin"` | plain |

### nexlayer.yaml

```yaml
application:
  name: plane
  pods:
    - name: web
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/plane:9f0543d-fix5"
      path: /
      servicePorts:
        - 80
      vars:
        NODE_ENV: "production"
        PORT: "80"
        HOSTNAME: "0.0.0.0"
        VITE_WEB_BASE_URL: "<% URL %>"
        VITE_API_BASE_URL: "<% URL %>/api"
        VITE_LIVE_BASE_URL: "<% URL %>/live"
        VITE_SPACE_BASE_URL: "<% URL %>/space"
        VITE_ADMIN_BASE_URL: "<% URL %>/admin"
```

<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| plane-db | mirror.gcr.io/library/postgres:16-alpine | 5432 | database |
| plane-redis | mirror.gcr.io/library/redis:7-alpine | 6379 | cache |
| api | mirror.gcr.io/library/node:22-alpine | 8000 | web |
| worker | mirror.gcr.io/library/node:22-alpine | 0 | worker |
| beat-worker | mirror.gcr.io/library/node:22-alpine | 0 | worker |
| web | mirror.gcr.io/library/node:22-alpine | 3000 | web |
| admin | mirror.gcr.io/library/node:22-alpine | 3001 | web |
| space | mirror.gcr.io/library/node:22-alpine | 3002 | web |
| live | mirror.gcr.io/library/node:22-alpine | 8080 | web |

### Deployment notes

- All services communicate using the <podName>.pod:<port> pattern (e.g., plane-db.pod:5432).
- Separate pods are used for the API, background worker, and beat worker despite sharing the same image base.
- Database and Cache are strictly isolated in their own pods per Nexlayer rules.

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-06-26T19:19:19Z  
**Live URL:** https://relaxed-weasel-plane.cloud.nexlayer.ai  
**Runtime:**  · **Port:** auto-detected  
**Deploy branch:** nexlayer  

```yaml
application:
  name: plane
  pods:
    - name: web
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/plane:9f0543d-fix5"
      path: /
      servicePorts:
        - 80
      vars:
        NODE_ENV: "production"
        PORT: "80"
        HOSTNAME: "0.0.0.0"
        VITE_WEB_BASE_URL: "<% URL %>"
        VITE_API_BASE_URL: "<% URL %>/api"
        VITE_LIVE_BASE_URL: "<% URL %>/live"
        VITE_SPACE_BASE_URL: "<% URL %>/space"
        VITE_ADMIN_BASE_URL: "<% URL %>/admin"
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-06-26T18:50:15Z | analyzed | initial repo analysis |
| 2026-06-26T19:19:19Z | success | deployed https://relaxed-weasel-plane.cloud.nexlayer.ai |
<!-- nexlayer:end -->
