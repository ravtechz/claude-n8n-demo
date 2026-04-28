# 2. Instalare Claude Code

Documentatie oficiala: https://code.claude.com/docs/en/setup

## 2.1 Instalare

```bash
curl -fsSL https://claude.ai/install.sh | bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 2.2 Verificare

```bash
claude --version
```

## 2.3 Login

```bash
claude
```

La prima rulare, Claude Code te ghideaza prin login (browser sau token). Dupa autentificare, iesi cu `/exit` — vom configura serverele MCP la pasul 5.
