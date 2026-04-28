# 6. Bot Telegram + credentiale n8n

## 6.1 Creeaza bot-ul cu BotFather

In Telegram, deschide chat cu [@BotFather](https://t.me/BotFather):

```
/newbot
Name:     Seful-Rapoartelor
Username: rav_report_bot
```

BotFather iti da un token de forma `123456:ABC-...`. Salveaza-l — il folosesti la pasul urmator.

## 6.2 Adauga credentialele in n8n

In UI-ul n8n -> **Credentials** -> **New**:

1. **Telegram API**
   - Access Token: token-ul de la BotFather.
2. **Anthropic API**
   - API Key: cheia ta din console.anthropic.com.
3. **Postgres**
   - Host: IP-ul gateway-ului Docker (vezi [docs/08](08-fix-postgres-docker.md)).
   - Database: `shop`.
   - User: `shop_readonly`.
   - Password: parola setata la pasul 3.
   - Port: `5432`.
   - SSL: `disable` (LAN intern).

> Salveaza credentialele dar **nu** le atasa inca pe noduri — Claude le va atasa cand creeaza workflow-ul, sau le legi manual la final.
