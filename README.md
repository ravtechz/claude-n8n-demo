# 🤖 Claude Code + n8n + Postgres + Telegram

🚀 Ghid pas cu pas pentru un workflow n8n care iti permite sa discuti cu o baza de date Postgres prin Telegram, generat automat cu Claude Code.

> 🛠️ **Stack:** Ubuntu 24.04 (VPS Hostinger) + Postgres 18 + n8n (Docker) + Claude Code + Telegram Bot.
> 💬 La final ai un bot Telegram care raspunde la intrebari in limbaj natural despre datele tale: text 📝 sau grafic 📊, decis automat de AI.

## 🎯 Ce vei construi

```
[📱 Telegram] -> [⚡ n8n Trigger]
                -> [🧠 AI Agent: Intent + SQL]
                -> [🔍 Parse JSON]
                -> [🗄️  Postgres Query]
                -> [🔀 Switch: text / chart]
                      |- 📝 text  -> [✍️  AI Formatter RO]   -> [📤 Telegram sendMessage]
                      |- 📊 chart -> [🎨 AI Chart Config]   -> [🖼️  Telegram sendPhoto via QuickChart]
```

## ✅ Cerinte preliminare

- 🖥️ VPS cu Ubuntu 24.04 (Hostinger sau echivalent), acces root prin SSH.
- 🌐 Cont n8n self-hosted accesibil public (HTTPS).
- 🔑 Cont Anthropic cu API key (pentru Claude in n8n).
- 💬 Cont Telegram (pentru a crea bot-ul prin BotFather).
- 🗝️  Cheie API n8n generata din Settings -> n8n API.

## 📚 Structura ghidului

| Pas | Fisier | Ce faci |
|-----|--------|---------|
| 1️⃣ | [docs/01-vps-setup.md](docs/01-vps-setup.md) | 👤 User non-root + verificari pe VPS |
| 2️⃣ | [docs/02-claude-install.md](docs/02-claude-install.md) | 🤖 Instalare Claude Code pe Ubuntu |
| 3️⃣ | [docs/03-postgres-install.md](docs/03-postgres-install.md) | 🐘 Postgres 18 + user readonly |
| 4️⃣ | [docs/04-load-data.md](docs/04-load-data.md) | 📦 Generare date dummy (Mockaroo) si import |
| 5️⃣ | [docs/05-mcp-servers.md](docs/05-mcp-servers.md) | 🔌 postgres-mcp + n8n-mcp pentru Claude |
| 6️⃣ | [docs/06-telegram-bot.md](docs/06-telegram-bot.md) | 🤖 Bot Telegram cu BotFather |
| 7️⃣ | [docs/07-generate-workflow.md](docs/07-generate-workflow.md) | ✨ Prompt-ul cu care Claude construieste workflow-ul |
| 8️⃣ | [docs/08-fix-postgres-docker.md](docs/08-fix-postgres-docker.md) | 🐳 Conexiune Postgres din container n8n |

## 📂 Continut repo

```
110-claude-n8n/
  📄 README.md
  📁 docs/                          # ghidul pe sectiuni
  📁 prompts/
    📝 claude-workflow.md           # prompt-ul integral pentru Claude Code
  📁 sql/
    🗃️  create-table.sql             # schema (customers, products, orders, order_items)
    👥 customers.sql                # 500 rows dummy
    📦 products.sql                 # 100 rows dummy
    🛒 orders.sql                   # 1000 rows dummy
    🧾 order_items.sql              # 1000 rows dummy
  📁 n8n-flow-json/
    ⚡ telegram-bot-plus-chart.json # flow-ul de n8n direct gata de import in n8n (daca nu mai vrei sa il generezi cu ClaudeCode)
  🚫 .gitignore
```

## ⚡ Quick start

```bash
git clone <repo>
cd 110-claude-n8n
# 👉 urmeaza pasii din docs/ in ordine
```

## 🎬 Urmareste-ma pe YouTube

⭐ Daca ti-a placut acest tutorial, aboneaza-te la canal pentru mai mult continut despre **DevOps, Linux, Cloud si AI**! 🚀
