# 5. Servere MCP pentru Claude Code

Claude Code va vorbi cu Postgres si cu n8n prin doua servere MCP. Ambele se inregistreaza la nivel de user (`--scope user`).

## 5.1 postgres-mcp

Repo: https://github.com/crystaldba/postgres-mcp

Instalare prin `uv`:

```bash
su - <nume_utilizator>
curl -LsSf https://astral.sh/uv/install.sh | sh
uv tool install postgres-mcp
```

Verifica binarul:

```bash
ls -l ~/.local/bin/postgres-mcp
```

Adauga MCP in Claude:

```bash
claude mcp add postgres-mcp /home/<nume_utilizator>/.local/bin/postgres-mcp \
  "postgresql://shop_readonly:CHANGE_ME_RO@localhost/shop" \
  --scope user
```

## 5.2 n8n-mcp

Repo: https://github.com/czlonkowski/n8n-mcp

Ai nevoie de:
- `N8N_API_URL` — URL-ul instantei tale n8n (HTTPS).
- `N8N_API_KEY` — generat din n8n -> Settings -> n8n API.

```bash
claude mcp add n8n-mcp npx n8n-mcp \
  --scope user \
  -e MCP_MODE=stdio \
  -e LOG_LEVEL=error \
  -e DISABLE_CONSOLE_OUTPUT=true \
  -e N8N_API_URL=https://YOUR-N8N-HOST \
  -e N8N_API_KEY=YOUR_N8N_API_KEY
```

## 5.3 Verifica

```bash
claude mcp list
```

Trebuie sa vezi `postgres-mcp` si `n8n-mcp` cu status OK. Daca apare eroare, deschide `claude` si ruleaza `/mcp` pentru detalii.
