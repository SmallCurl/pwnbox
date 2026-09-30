#!/bin/bash
# Print team IPs and player passwords from Terraform state.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF="$ROOT/terraform"
OUT="$ROOT/out"

if [[ ! -f "$TF/terraform.tfstate" && ! -d "$TF/.terraform" ]]; then
  echo "Nothing deployed yet. Run ./scripts/deploy.sh TEAM_COUNT --yes" >&2
  exit 1
fi

mkdir -p "$OUT"
umask 077
terraform -chdir="$TF" output -json teams >"$OUT/teams.json"

python3 - "$OUT/teams.json" "$OUT/logins.txt" <<'PY'
import json
import sys

src, dest = sys.argv[1], sys.argv[2]
teams = json.load(open(src))
lines = []
for name in sorted(teams):
    row = teams[name]
    lines.append(name)
    lines.append(f"  RDP  {row['rdp']}")
    lines.append(f"  SSH  {row['ssh']}")
    for player in sorted(row["players"]):
        lines.append(f"  {player}  {row['players'][player]}")
    lines.append("")
text = "\n".join(lines).rstrip() + "\n"
open(dest, "w").write(text)
sys.stdout.write(text)
PY
chmod 600 "$OUT/teams.json" "$OUT/logins.txt"
echo "Saved to $OUT/logins.txt"
