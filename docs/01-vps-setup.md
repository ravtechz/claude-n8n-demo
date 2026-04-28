# 1. Setup VPS Ubuntu

## 1.1 Provisionare

Pornesti un VPS Ubuntu 24.04 (Hostinger din interfata web — alegere de plan, regiune, snapshot Ubuntu 24.04). Iei IP-ul public si parola root din panel.

## 1.2 Test viteza retea (optional)

```bash
curl -s https://raw.githubusercontent.com/PeterLinuxOSS/speedtest-cli/master/speedtest.py | python3 -
```

## 1.3 Creeaza user separat

Nu lucra direct ca `root`. Cream `<nume_utilizator>` cu drepturi sudo:

```bash
adduser <nume_utilizator>
usermod -aG sudo <nume_utilizator>
su - <nume_utilizator>
```

> `<nume_utilizator>` este un **placeholder** — inlocuieste-l peste tot cu numele real dorit (de exemplu `raz`, `andrei` etc.). Toti pasii urmatori care folosesc Claude / MCP se executa din acest user.
