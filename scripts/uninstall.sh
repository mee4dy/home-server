#!/usr/bin/env bash
set -euo pipefail

SSH_DIR="${HOME}/.ssh"
AUTH_KEYS="${SSH_DIR}/authorized_keys"
SSHD_DROPIN="/etc/ssh/sshd_config.d/home-server.conf"
KEY_COMMENT="home-server-tunnel"

if [ "$(id -u)" -ne 0 ]; then
  echo "Нужен root (запустите: sudo make uninstall)" >&2
  exit 1
fi

restart_sshd() {
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

  echo "sshd: не удалось перезапустить автоматически" >&2
  exit 1
}

if [ -f "$SSHD_DROPIN" ]; then
  rm -f "$SSHD_DROPIN"
  echo "GatewayPorts: удален (${SSHD_DROPIN})"
  restart_sshd
else
  echo "GatewayPorts: нечего удалять"
fi

if [ -f "$AUTH_KEYS" ]; then
  BEFORE="$(wc -l < "$AUTH_KEYS" | tr -d ' ')"
  grep -vF "$KEY_COMMENT" "$AUTH_KEYS" > "${AUTH_KEYS}.tmp" || true
  mv "${AUTH_KEYS}.tmp" "$AUTH_KEYS"
  chmod 600 "$AUTH_KEYS"
  AFTER="$(wc -l < "$AUTH_KEYS" | tr -d ' ')"
  REMOVED=$((BEFORE - AFTER))
  echo "authorized_keys: удалено ключей: ${REMOVED}"
else
  echo "authorized_keys: файл не найден"
fi

echo "uninstall: готово"
