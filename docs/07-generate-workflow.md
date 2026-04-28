# 7. Genereaza workflow-ul cu Claude Code

Aici e momentul "magic": ii dai lui Claude un prompt si el iti construieste workflow-ul direct in n8n prin n8n-mcp.

## 7.1 Porneste Claude

```bash
cd ~
claude
```

## 7.2 Lipeste prompt-ul

Prompt-ul integral este in [`../prompts/claude-workflow.md`](../prompts/claude-workflow.md). Il copiezi tot si il dai ca mesaj in Claude Code.

Pe scurt, prompt-ul ii cere lui Claude:

1. Sa inspecteze schema bazei `shop` cu postgres-mcp.
2. Sa creeze un workflow n8n cu doua ramuri (text / chart).
3. Sa configureze nodurile cu setarile critice (model Claude Sonnet 4, `executeOnce`, `chatId` ca string, etc.).
4. Sa ruleze `n8n_validate_workflow` la final.

## 7.3 Atasare credentiale + activare

Workflow-ul ramane **inactiv** dupa creare. In UI n8n:

1. Deschide workflow-ul nou creat.
2. Pe fiecare nod cu icon de avertizare, alege credentialul corespunzator (Telegram, Anthropic, Postgres).
3. Click **Save**.
4. Activeaza din toggle-ul din dreapta sus.

## 7.4 Test

Trimite mesaj catre `@rav_report_bot` pe Telegram:

- `cati clienti avem?` -> raspuns text.
- `arata-mi grafic vanzari pe luna` -> raspuns cu imagine de la QuickChart.

Daca primesti **"chat not found"** la Telegram, verifica ca nodurile `sendMessage` / `sendPhoto` au `chatId` ca string simplu cu `=` prefix, **nu** ca resource locator (`__rl: true`). Vezi sectiunea Puncte critice din prompt.

## 7.5 Probleme frecvente

| Eroare | Cauza | Fix |
|---|---|---|
| `chat not found` | chatId wrap in resource locator | Schimba in string simplu cu `={{ $('Telegram Trigger').first().json.message.chat.id }}` |
| Postgres `connection refused` | n8n in Docker, Postgres pe host | Vezi [docs/08](08-fix-postgres-docker.md) |
| N mesaje duplicate | lipseste `executeOnce` | Seteaza pe Agent 2, Agent 3, sendMessage, sendPhoto |
| Agent output nu parseaza | Claude returneaza ```json fences | System prompt impune JSON pur, fara fences |
