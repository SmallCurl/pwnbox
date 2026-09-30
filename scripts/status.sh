#!/bin/bash
# Report whether each team RDP port is accepting connections yet.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF="$ROOT/terraform"

if [[ ! -d "$TF/.terraform" ]]; then
  echo "Nothing deployed yet. Run ./scripts/deploy.sh TEAM_COUNT --yes" >&2
  exit 1
fi

terraform -chdir="$TF" output -json addresses | python3 - <<'PY'
import json
import socket
import sys

addresses = json.load(sys.stdin)
for name in sorted(addresses):
    ip = addresses[name]
    sock = socket.socket()
    sock.settimeout(3)
    try:
        sock.connect((ip, 3389))
    except OSError:
        print(f"{name}  {ip}:3389  booting")
    else:
        print(f"{name}  {ip}:3389  ready")
    finally:
        sock.close()
PY
