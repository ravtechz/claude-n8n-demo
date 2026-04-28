# Prompt Claude Code — workflow n8n cu Postgres + Telegram

Lipeste continutul de mai jos integral in Claude Code (din folderul user-ului `<nume_utilizator>`, dupa ce postgres-mcp si n8n-mcp sunt active).

---

```
Am o baza de date Postgres numita "shop" cu 4 tabele: customers, products, orders si order_items. E un magazin online.

Mai intai, inspecteaza schema bazei de date folosind postgres MCP ca sa intelegi structura tabelelor (coloane, tipuri, nullability, indexuri — noteaza relatiile FK implicite pe baza denumirilor, chiar daca nu exista constraints explicite).

Apoi construieste un workflow in n8n folosind n8n MCP cu doua ramuri de raspuns: text si grafic, care se decid automat din intrebare.

Flow

[Telegram Trigger]
  -> [AI Agent 1 — Intent + SQL]       (output = JSON strict)
  -> [Code — Parse Agent Output]       (JSON.parse pe $json.output)
  -> [Postgres — Execute Query]        (query = ={{ $json.sql }})
  -> [Switch — Route by Intent]        (2 iesiri: text / chart)
        |- text  -> [AI Agent 2 — Formatter RO]   -> [Telegram sendMessage]
        |- chart -> [AI Agent 3 — Chart Config]   -> [Telegram sendPhoto]

Noduri & configurari

1. Telegram Trigger
- n8n-nodes-base.telegramTrigger v1.2, updates: ["message"].

2. AI Agent 1 — Intent + SQL
- @n8n/n8n-nodes-langchain.agent v3.1, promptType: "define", text: "={{ $json.message.text }}".
- Sub-model: @n8n/n8n-nodes-langchain.lmChatAnthropic v1.3 cu model.__rl=true, mode:"id", value:"claude-sonnet-4-20250514", temperature 0.
- System prompt include: schema completa, regulile pentru clasificare intent, si impune output JSON strict, fara markdown fences:
{"intent": "text" | "chart", "chart_type": "line"|"bar"|"horizontalBar"|"pie"|null, "sql": "SELECT ..."}
- Reguli clasificare:
  - intent="chart" cand mesajul contine "grafic", "chart", "diagrama", "vizualizeaza", "evolutia", "tendinta" SAU cand rezultatul natural e serie temporala / comparatie / distributie.
  - chart_type: line (serii temporale), bar (top N scurt), horizontalBar (etichete lungi sau N>8), pie (distributie <=8 felii).
  - Cand intent="chart", SQL-ul TREBUIE sa returneze EXACT 2 coloane: prima = eticheta, a doua = valoare numerica.

3. Code — Parse Agent Output
- n8n-nodes-base.code v2, JavaScript:
const raw = $input.first().json.output;
let parsed;
if (raw && typeof raw === 'object') parsed = raw;
else if (typeof raw === 'string') {
  const match = raw.match(/\{[\s\S]*\}/);
  parsed = JSON.parse(match ? match[0] : raw);
} else throw new Error('Unexpected agent output');
return [{ json: { intent: parsed.intent, chart_type: parsed.chart_type ?? null, sql: parsed.sql } }];

4. Postgres — Execute Query
- n8n-nodes-base.postgres v2.6, operation: "executeQuery", query: "={{ $json.sql }}". Pastreaza prefixul = altfel n8n trimite textul literal.

5. Switch — Route by Intent
- n8n-nodes-base.switch v3.2 mode rules, doua iesiri pe ={{ $('Parse Agent Output').first().json.intent }} egal cu "text" (output 0) respectiv "chart" (output 1). Fiecare conditie cu options: {version: 2, leftValue: "", caseSensitive: true, typeValidation: "strict"}.

6. AI Agent 2 — Formatter RO (ramura text)
- Identic cu Agent 1 ca tip, sub-model Claude Sonnet 4, temperature 0.2.
- executeOnce: true la nivel de nod (NU in parameters).
- User prompt include intrebarea originala si JSON.stringify($input.all().map(i => i.json)).
- System prompt: raspunde in romana, concis (1-3 randuri pentru valori unice, 8-10 pentru liste), separator . pentru mii, , pentru zecimale, valute cu 2 zecimale + "RON", fara JSON/SQL, emoji sobru cu masura, intra direct in subiect.

7. Telegram sendMessage (ramura text)
- n8n-nodes-base.telegram v1.2, resource: "message", operation: "sendMessage".
- chatId: "={{ $('Telegram Trigger').first().json.message.chat.id }}" — ca string simplu, NU wrap in __rl (telegrafic nu foloseste resource locator pe chatId — daca il impachetezi primesti "chat not found"). Foloseste .first() nu .item (robust la paired-item tracking).
- text: "={{ $json.output }}".
- executeOnce: true la nivel de nod.

8. AI Agent 3 — Chart Config (ramura chart)
- Acelasi tip, sub-model Claude Sonnet 4, temperature 0, maxTokens 2048.
- executeOnce: true la nivel de nod.
- User prompt include: intrebarea, chart_type din Parse Agent Output, si JSON.stringify($input.all().map(i => i.json)).
- System prompt: construieste config Chart.js valid (fara markdown fences), prima cheie = label, a doua = value, titlu in romana max 60 caractere, culori sobre. Ofera template-uri JSON pentru line/bar/horizontalBar (type=bar + indexAxis=y)/pie.

9. Telegram sendPhoto (ramura chart)
- n8n-nodes-base.telegram v1.2, resource: "message", operation: "sendPhoto".
- chatId identic cu sendMessage (string simplu).
- binaryData: false, file: "=https://quickchart.io/chart?w=700&h=450&bkg=white&c={{ encodeURIComponent($json.output) }}" — Telegram descarca singur PNG-ul de la QuickChart.
- executeOnce: true la nivel de nod.

Conexiuni

Main: Trigger -> Agent1 -> ParseOutput -> Postgres -> Switch; Switch[0] -> Agent2 -> sendMessage; Switch[1] -> Agent3 -> sendPhoto.
AI_languageModel: fiecare Anthropic model -> agentul sau corespondent.

Puncte critice (NU le omite)

1. Claude model: claude-sonnet-4-20250514 pentru toti trei agentii, setat prin model.__rl=true, mode:"id".
2. executeOnce: true pe Agent 2, Agent 3, Telegram sendMessage, Telegram sendPhoto — la nivel de nod, NU in parameters. Altfel Postgres returnand N randuri -> N mesaje duplicate.
3. chatId pe nodurile Telegram ramane string cu = prefix, nu resource locator. Validatorul n8n va sugera sa-l impachetezi in __rl — ignora sugestia, rupe nodul.
4. $('Telegram Trigger').first().json.message.chat.id, nu .item — ca sa fie robust cand paired-item tracking se rupe prin AI Agent.
5. Postgres query incepe cu = pentru a fi tratat ca expresie.
6. Agent 1 output DOAR JSON pur — fara ```json fences, fara text in plus. Code node are regex de fallback {[\s\S]*} dar e mai curat daca agentul returneaza JSON curat direct.
7. Dupa creare, ruleaza n8n_validate_workflow. Warning-urile despre "systemMessage lipsa", "chat model not reachable from trigger", "chatId should use resource locator" sunt false positives — ignora-le. Doar erorile reale trebuie rezolvate.
8. Workflow-ul ramane inactiv dupa creare. User-ul ataseaza manual credentiale (Telegram, Anthropic, Postgres) si activeaza din UI.
```
