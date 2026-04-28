# 3. Postgres 18 pe Ubuntu 24.04

Referinta: https://dev.to/topeogunleye/how-to-install-postgresql-18-on-ubuntu-2404-1doc

## 3.1 Update sistem

```bash
sudo apt update
sudo apt upgrade -y
```

## 3.2 Adauga repo PGDG

```bash
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg

echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4
sudo apt update
```

## 3.3 Instaleaza Postgres + Node.js 20

```bash
sudo apt -y install postgresql-18

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v
```

## 3.4 Verifica si activeaza serviciul

```bash
systemctl status postgresql
sudo systemctl enable postgresql
```

## 3.5 Creeaza user readonly + baza `shop`

```bash
sudo -u postgres psql
```

In prompt-ul `psql`:

```sql
ALTER USER postgres WITH ENCRYPTED PASSWORD 'CHANGE_ME';
CREATE USER shop_readonly WITH PASSWORD 'CHANGE_ME_RO';
CREATE DATABASE shop;
\c shop
GRANT CONNECT ON DATABASE shop TO shop_readonly;
GRANT USAGE ON SCHEMA public TO shop_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO shop_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO shop_readonly;
\q
```

> Inlocuieste `CHANGE_ME` si `CHANGE_ME_RO` cu parole reale. Userul `shop_readonly` este cel pe care il foloseste MCP-ul Postgres — fara drept de scriere, important pentru un agent LLM.

## 3.6 Activeaza autentificare cu parola

Implicit Postgres foloseste `peer` pentru conexiuni locale. Schimbam pe `scram-sha-256`:

```bash
sudo sed -i '/^local/s/peer/scram-sha-256/' /etc/postgresql/18/main/pg_hba.conf
sudo systemctl restart postgresql
```
