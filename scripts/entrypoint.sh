#!/bin/sh
set -eu

if [ -z "${TUNNEL_TOKEN:-}" ]; then
  echo "TUNNEL_TOKEN is required" >&2
  exit 1
fi

if [ -z "${SERVER_HOST:-}" ]; then
  echo "SERVER_HOST is required" >&2
  exit 1
fi

if [ -z "${PORTS:-}" ]; then
  echo "PORTS is required" >&2
  exit 1
fi

SERVER_USER="${SERVER_USER:-root}"
KEY_FILE="/tmp/tunnel_id"

printf '%s' "$TUNNEL_TOKEN" | base64 -d > "$KEY_FILE"
chmod 600 "$KEY_FILE"

set --

OLD_IFS=$IFS
IFS=','
for mapping in $PORTS; do
  mapping=$(printf '%s' "$mapping" | tr -d ' ')

  if [ -z "$mapping" ]; then
    continue
  fi

  case "$mapping" in
    *:*)
      remote=${mapping%%:*}
      local=${mapping##*:}
      ;;
    *)
      remote=$mapping
      local=$mapping
      ;;
  esac

  set -- "$@" -R ":${remote}:127.0.0.1:${local}"
done
IFS=$OLD_IFS

if [ "$#" -eq 0 ]; then
  echo "PORTS is empty" >&2
  exit 1
fi

echo "Tunnel -> ${SERVER_USER}@${SERVER_HOST}"
echo "Ports: ${PORTS}"

exec autossh \
  -M 0 \
  -N \
  -o ServerAliveInterval=15 \
  -o ServerAliveCountMax=3 \
  -o ExitOnForwardFailure=yes \
  -o StrictHostKeyChecking=accept-new \
  -o UserKnownHostsFile=/tmp/known_hosts \
  -i "$KEY_FILE" \
  "$@" \
  "${SERVER_USER}@${SERVER_HOST}"
