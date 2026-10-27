# pokr

> Planning poker online app built with Vue 3 &amp; Phoenix

Live at <https://pokr.elbe.software>.

## Layout

| Directory   | What                                                    |
| ----------- | ------------------------------------------------------- |
| `frontend/` | Vue 3 SPA, see [frontend/README.md](frontend/README.md) |
| `backend/`  | Phoenix API + websocket, see [backend/README.md](backend/README.md) |

## Local development

```sh
cp .env.dist .env         # set USER_ID / GROUP_ID to `id -u` / `id -g`
docker compose up         # frontend :5173, backend :4000, postgres :5432
```

## Deployment

| Part     | Where                    | How                                                       |
| -------- | ------------------------ | --------------------------------------------------------- |
| Frontend | Cloudflare Pages `pokr`  | Push to `main`. Cloudflare builds and deploys by itself.  |
| Backend  | Oracle Cloud VM, Docker  | Push to `main`. CI pushes the image to GHCR; re-pull it by updating the stack in Portainer. See [backend/README.md](backend/README.md). |

GitHub Actions (`.github/workflows/ci.yml`) runs lint, type check, tests and build for the frontend and format, compile and tests for the backend on every PR and push to `main`. On `main` it also publishes the backend image to GHCR. It does not deploy: Cloudflare deploys the frontend by itself, the backend stack is updated by hand in Portainer.

## Infrastructure

- **Oracle Cloud** compute instance (`eu-frankfurt-1`, Ubuntu, x86_64, 1 GB RAM, 2 GB swapfile at `/swapfile`, `vm.swappiness=10`), reachable via SSH as `ubuntu`.
- **Cloudflare** proxies `pokr.elbe.software` (Pages), `bpokr.elbe.software` (backend) and `portainer.elbe.software`. The VM's public IP is not in this repo.
- **Docker** runs everything on the VM:
  - `nginx-proxy` terminates TLS (Cloudflare origin cert) on 80/443 and routes by host name. Config in `/opt/reverse-proxy/conf.d/` (`bpokr.conf`, `portainer.conf`). Stack: `reverse-proxy`.
  - `pokr_backend` + `pokr_postgres`. Stack: `pokr-backend`.
  - `portainer` (CE), plain `docker run`, not a stack.
  - They share the Docker network `proxy`; nginx reaches them by container name. No container publishes ports other than `nginx-proxy`.
- Stacks are managed in Portainer (<https://portainer.elbe.software>). Production secrets (`SECRET_KEY_BASE`, DB credentials) live only in the `pokr-backend` stack's environment there, never in the repo. See [backend/README.md](backend/README.md#configuration).

### SSH

Keep a local, gitignored `.ssh_config` in the repo root and use it with `ssh -F .ssh_config oracle`:

```
Host oracle
    HostName <public ip, see OCI console: Compute > Instances>
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

### Updating Portainer

Portainer does not update itself. It runs `portainer/portainer-ce:lts` on the `proxy` network under the name `portainer` (nginx proxies to `https://portainer:9443`).

```sh
docker pull portainer/portainer-ce:lts
docker stop portainer
docker run --rm -v portainer_data:/data:ro -v /home/ubuntu:/backup alpine:3 \
  tar czf /backup/portainer_data-<old version>.tgz -C /data .
docker rename portainer portainer-old
docker run -d --name portainer --restart=always --network proxy \
  -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data \
  portainer/portainer-ce:lts
```

Only the Portainer UI is down meanwhile. The new version migrates its database in place, so rolling back means restoring the tarball into `portainer_data`, then starting `portainer-old`. Delete `portainer-old`, the tarball and the old image once the new version is fine.
