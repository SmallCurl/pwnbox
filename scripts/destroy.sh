#!/bin/bash
# Delete the team servers, firewall, and SSH key object created by deploy.sh.
# Usage: ./scripts/destroy.sh --yes
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF="$ROOT/terraform"

if [[ "${1:-}" != "--yes" ]]; then
  echo "Usage: $0 --yes" >&2
  echo "This deletes every team server in this Terraform state." >&2
  exit 1
fi

if [[ -z "${HCLOUD_TOKEN:-}" ]]; then
  echo "Set HCLOUD_TOKEN first." >&2
  exit 1
fi

terraform -chdir="$TF" init -input=false
terraform -chdir="$TF" destroy -input=false -auto-approve
echo "Team servers destroyed."
