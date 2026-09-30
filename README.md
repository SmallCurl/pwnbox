# Deploy team pwnboxes on Hetzner

One team = one Ubuntu VPS = one `changemeor/gctf-pwnbox:v2` desktop. Players connect with RDP on port 3389. Passwords are generated and stay in Terraform state.

## Setup

```bash
export HCLOUD_TOKEN='hetzner-read-write-token'
cd final-deploy
```

The deploy script uses `~/.ssh/id_ed25519.pub` (or `id_rsa.pub`). Override with `SSH_PUBLIC_KEY_FILE`.

## Create teams

Plan only:

```bash
./scripts/deploy.sh 4
```

Create 4 servers, 3 players each:

```bash
./scripts/deploy.sh 4 --yes
```

Two players per team, different size or site:

```bash
PLAYERS_PER_TEAM=2 SERVER_TYPE=cx52 LOCATION=fsn1 ./scripts/deploy.sh 4 --yes
```

`TEAM_PREFIX=blue` names the servers `blue01` … `blue04`.

First boot pulls an image of about 8 GB, so RDP is not ready the moment Terraform finishes.

```bash
./scripts/status.sh
./scripts/show-logins.sh
```

`show-logins.sh` prints each team IP, `ssh root@…`, and `player1` / `player2` / … passwords. The same text is stored in `out/logins.txt`.

Changing `team_count` adds or removes servers. Changing `players_per_team` replaces existing servers, because the login list is baked in at first boot.

## Tear down

```bash
export HCLOUD_TOKEN='...'
./scripts/destroy.sh --yes
```

## Ports

| Port | Use |
|---|---|
| 22 | SSH as root |
| 3389 | RDP as `playerN` |

The Hetzner firewall opens only those two. `cx52` (32 GB) is the practical size for three desktops. Use `cx53` or `cpx51` if `cx52` is gone.
