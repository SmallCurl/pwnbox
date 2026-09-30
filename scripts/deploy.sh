#!/bin/bash
# Create one Hetzner server per team and start the pwnbox image on each.
# Usage: ./scripts/deploy.sh TEAM_COUNT [--yes]
# Example: PLAYERS_PER_TEAM=2 ./scripts/deploy.sh 4 --yes
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF="$ROOT/terraform"
OUT="$ROOT/out"
COUNT="${1:-}"
YES="${2:-}"

if [[ -z "$COUNT" || "$COUNT" == "-h" || "$COUNT" == "--help" ]]; then
  echo "Usage: $0 TEAM_COUNT [--yes]" >&2
  echo "  TEAM_COUNT          how many Hetzner servers (1-50)" >&2
  echo "  --yes               create them (without this flag, only a plan is shown)" >&2
  echo "Env: HCLOUD_TOKEN PLAYERS_PER_TEAM TEAM_PREFIX LOCATION SERVER_TYPE PWNBOX_IMAGE SSH_PUBLIC_KEY_FILE" >&2
  exit 1
fi

if [[ -z "${HCLOUD_TOKEN:-}" ]]; then
  echo "Set HCLOUD_TOKEN to a Hetzner Read & Write API token." >&2
  exit 1
fi

PLAYERS_PER_TEAM="${PLAYERS_PER_TEAM:-3}"
TEAM_PREFIX="${TEAM_PREFIX:-team}"
LOCATION="${LOCATION:-fsn1}"
SERVER_TYPE="${SERVER_TYPE:-cx52}"
PWNBOX_IMAGE="${PWNBOX_IMAGE:-changemeor/gctf-pwnbox:v2}"
SSH_PUBLIC_KEY_FILE="${SSH_PUBLIC_KEY_FILE:-$HOME/.ssh/id_ed25519.pub}"

if [[ ! -f "$SSH_PUBLIC_KEY_FILE" && -f "$HOME/.ssh/id_rsa.pub" ]]; then
  SSH_PUBLIC_KEY_FILE="$HOME/.ssh/id_rsa.pub"
fi
if [[ ! -f "$SSH_PUBLIC_KEY_FILE" ]]; then
  echo "SSH public key not found: $SSH_PUBLIC_KEY_FILE" >&2
  echo "Set SSH_PUBLIC_KEY_FILE to a .pub file." >&2
  exit 1
fi

PUB="$(tr -d '\n' <"$SSH_PUBLIC_KEY_FILE")"
mkdir -p "$OUT"
umask 077

cat >"$TF/terraform.tfvars" <<EOF
ssh_public_key   = "${PUB}"
team_count       = ${COUNT}
team_prefix      = "${TEAM_PREFIX}"
players_per_team = ${PLAYERS_PER_TEAM}
location         = "${LOCATION}"
server_type      = "${SERVER_TYPE}"
pwnbox_image     = "${PWNBOX_IMAGE}"
EOF
chmod 600 "$TF/terraform.tfvars"

terraform -chdir="$TF" init -input=false
terraform -chdir="$TF" plan -input=false -out="$OUT/plan.tfplan"

if [[ "$YES" != "--yes" ]]; then
  echo
  echo "Plan only. Re-run with --yes to create ${COUNT} server(s)."
  exit 0
fi

terraform -chdir="$TF" apply -input=false "$OUT/plan.tfplan"
rm -f "$OUT/plan.tfplan"
"$ROOT/scripts/show-logins.sh"

echo
echo "Servers are up. The desktop image is large, so RDP can take several minutes."
echo "Check progress with ./scripts/status.sh"
