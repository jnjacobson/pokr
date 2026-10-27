# pokr frontend

Vue 3 single page app for pokr. Talks to the Phoenix backend over HTTP and a websocket (Phoenix channels).

**Stack:** Vue 3, Vue Router, Pinia, Tailwind CSS 4, TypeScript, Vite, Vitest. Realtime via the `phoenix` JS client.

## Development

Usually started through `docker compose up` in the repo root (Vite on `:5173`). Without Docker:

```sh
npm install
npm run dev
```

| Script               | What                                      |
| -------------------- | ----------------------------------------- |
| `npm run dev`        | Vite dev server                           |
| `npm run build`      | type check (`vue-tsc`) + production build |
| `npm run test:unit`  | Vitest                                    |
| `npm run lint[:fix]` | ESLint                                    |

## Configuration

Backend URLs are baked in at build time via Vite env vars:

| Var                    | Dev (`.env.dist`)              | Prod (`.env.production`, committed)    |
| ---------------------- | ------------------------------ | -------------------------------------- |
| `VITE_BACKEND_API_URL` | `http://localhost:4000/api`    | `https://bpokr.elbe.software/api`      |
| `VITE_BACKEND_WS_URL`  | `ws://localhost:4000/socket`   | `wss://bpokr.elbe.software/socket`     |

Copy `.env.dist` to `.env` for local development.

## Layout

- `src/views/GameView.vue`: the game screen
- `src/stores/`: Pinia stores (`useGameStore` holds game state and the channel connection)
- `src/components/`: UI pieces (cards, deck, players, results, modals)

## Deployment

Hosted on **Cloudflare Pages** (project `pokr`, <https://pokr.elbe.software>). Pushing to `main` deploys to production.

| Setting           | Value           |
| ----------------- | --------------- |
| Production branch | `main`          |
| Root directory    | `frontend`      |
| Build command     | `npm run build` |
| Output directory  | `dist`          |

The build fails on type errors, so run `npm run build` locally before pushing. The `Dockerfile` in `docker/` is only used for local dev (`dev` target); its nginx stage is not used in production.
