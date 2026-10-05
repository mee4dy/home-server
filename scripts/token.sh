#!/usr/bin/env bash
set -euo pipefail

SSH_DIR="${HOME}/.ssh"
AUTH_KEYS="${SSH_DIR}/authorized_keys"
SSHD_DROPIN="/etc/ssh/sshd_config.d/home-server.conf"
TMP_DIR="$(mktemp -d)"
KEY_FILE="${TMP_DIR}/tunnel"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

ensure_gateway_ports() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Нужен root для настройки GatewayPorts (запусти: sudo make token)" >&2
    exit 1
  fi

  if [ ! -d /etc/ssh/sshd_config.d ]; then
    mkdir -p /etc/ssh/sshd_config.d
  fi

  if [ ! -f "$SSHD_DROPIN" ] || ! grep -qxF "GatewayPorts yes" "$SSHD_DROPIN"; then
    printf 'GatewayPorts yes\n' > "$SSHD_DROPIN"
    echo "GatewayPorts: включён (${SSHD_DROPIN})"
  else
    echo "GatewayPorts: уже включён"
  fi

  if command -v sshd >/dev/null 2>&1; then
    sshd -t
  fi

  if command -v systemctl >/dev/null 2>&1; then
    if systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null; then
      echo "sshd: перезапущен"
      return
    fi
  fi

  if command -v service >/dev/null 2>&1; then
    if service sshd restart 2>/dev/null || service ssh restart 2>/dev/null; then
      echo "sshd: перезапущен"
      return
    fi
  fi

  echo "sshd: не удалось перезапустить автоматически, сделай вручную" >&2
  exit 1
}

ensure_gateway_ports

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

ssh-keygen -t ed25519 -f "$KEY_FILE" -N "" -q -C "home-server-tunnel"

touch "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"

if ! grep -qxF "$(cat "${KEY_FILE}.pub")" "$AUTH_KEYS"; then
  cat "${KEY_FILE}.pub" >> "$AUTH_KEYS"
fi

if command -v base64 >/dev/null 2>&1; then
  if base64 --help 2>&1 | grep -q -- '-w'; then
    TOKEN="$(base64 -w0 < "$KEY_FILE")"
  else
    TOKEN="$(base64 < "$KEY_FILE" | tr -d '\n')"
  fi
else
  echo "base64 not found" >&2
  exit 1
fi

echo
echo "Токен (вставьте в .env на home как TUNNEL_TOKEN):"
echo
echo "$TOKEN"
echo
