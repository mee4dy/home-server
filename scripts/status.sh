#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

print_ports() {
  local mapping remote local_port

  echo "=== ports ==="

  if [ -z "${PORTS:-}" ]; then
    echo "(PORTS не задан)"
    return
  fi

  echo "host: ${SERVER_USER:-root}@${SERVER_HOST:-(не задан)}"
  printf '%-12s -> %s\n' "external" "home"

  IFS=',' read -r -a mappings <<< "$PORTS"

  for mapping in "${mappings[@]}"; do
    mapping="${mapping// /}"

    if [ -z "$mapping" ]; then
      continue
    fi

    if [[ "$mapping" == *:* ]]; then
      remote="${mapping%%:*}"
      local_port="${mapping##*:}"
    else
      remote="$mapping"
      local_port="$mapping"
    fi

    printf '%-12s -> %s\n' ":${remote}" ":${local_port}"
  done
}

print_ports

echo
echo "=== container ==="
docker compose ps

if ! docker compose ps --status running --services 2>/dev/null | grep -qx "tunnel"; then
  echo
  echo "status: down"
  exit 1
fi

echo
echo "=== logs (tail) ==="
docker compose logs --tail=20 tunnel

echo
echo "status: up"
echo "reconnect: autossh + restart unless-stopped"
exit 0
