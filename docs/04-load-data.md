# 4. Date dummy si import in Postgres

Avem 4 tabele: `customers`, `products`, `orders`, `order_items`. SQL-urile sunt deja in [`../sql/`](../sql/). Daca vrei sa le regenerezi cu alte volume, foloseste [Mockaroo](https://www.mockaroo.com/).

## 4.1 Schema Mockaroo (referinta)

**customers** (500 rows)

| Coloana | Tip | Note |
|---|---|---|
| `id` | Row Number | PK |
| `first_name` | First Name | |
| `last_name` | Last Name | |
| `email` | Email Address | |
| `country` | Country | bias spre RO/EU |
| `city` | City | |
| `created_at` | Datetime | ultimii 2 ani |

**products** (100 rows)

| Coloana | Tip | Note |
|---|---|---|
| `id` | Row Number | PK |
| `name` | Custom List | Laptop Dell XPS 15, iPhone 15 Pro, Nike Air Zoom Pegasus, Kindle Paperwhite |
| `category` | Custom List | Electronics, Electronics, Clothing, Books |
| `price` | Number (10-5000, 2 dec) | |
| `stock` | Number (0-500) | |
| `created_at` | Datetime | |

**orders** (1000 rows)

| Coloana | Tip | Note |
|---|---|---|
| `id` | Row Number | PK |
| `customer_id` | Number (1-500) | FK -> customers |
| `status` | Custom List | pending, shipped, delivered, cancelled, returned |
| `total_amount` | Number (20-10000, 2 dec) | |
| `order_date` | Datetime | ultimele 12 luni |

**order_items** (1000 rows)

| Coloana | Tip | Note |
|---|---|---|
| `id` | Row Number | PK |
| `order_id` | Number (1-1000) | FK -> orders |
| `product_id` | Number (1-100) | FK -> products |
| `quantity` | Number (1-5) | |
| `unit_price` | Number (10-5000, 2 dec) | |

## 4.2 Urca fisierele pe VPS

De pe masina locala:

```bash
cd 110-claude-n8n
zip -r postgres-data.zip sql/
scp postgres-data.zip root@<IP_VPS>:/root
```

## 4.3 Creeaza schema si incarca datele

Pe VPS:

```bash
ssh root@<IP_VPS>
apt install -y zip
mv postgres-data.zip /var/lib/postgresql/
chown postgres: /var/lib/postgresql/postgres-data.zip
su - postgres
cd /var/lib/postgresql
unzip postgres-data.zip
cd sql

# 1. schema
psql -d shop -a -f create-table.sql

# 2. date (in ordinea dependentelor)
psql -d shop -a -f customers.sql
psql -d shop -a -f products.sql
psql -d shop -a -f orders.sql
psql -d shop -a -f order_items.sql
```

## 4.4 Verifica

```bash
psql -d shop -c "SELECT count(*) FROM customers;"
psql -d shop -c "SELECT count(*) FROM orders;"
```
