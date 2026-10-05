# Home Server Tunnel

Проброс TCP-портов с VPS на домашний сервер без белого IP.

## 1. Внешний сервер (external)

Клонируйте репозиторий и выполните от root:

```bash
sudo make token
```

Скопируйте `TUNNEL_TOKEN` из вывода.

## 2. Домашний сервер (home)

Нужны Docker и Docker Compose.

```bash
cp .env.example .env
```

Заполните `.env`:

```env
SERVER_HOST=1.2.3.4
PORTS=80,443,8080:80
TUNNEL_TOKEN=...
```

Порты через запятую: `80` или `remote:local` (`8080:80`).

Запуск:

```bash
make up
make status
```

## Команды

| Команда | Где | Что делает |
|---|---|---|
| `make token` | external | Выдает токен для связки |
| `make uninstall` | external | Откатывает настройки external |
| `make up` | home | Поднимает туннель |
| `make down` | home | Останавливает туннель |
| `make restart` | home | Перезапускает туннель |
| `make status` | home | Статус, порты, логи |
