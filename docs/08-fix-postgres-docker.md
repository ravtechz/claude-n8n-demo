# 8. Conexiune Postgres din container n8n

Daca n8n ruleaza in Docker pe acelasi VPS ca Postgres-ul, container-ul **nu** vede `localhost`-ul host-ului. Trebuie sa folosesti gateway-ul retelei Docker.

## 8.1 Afla gateway-ul Docker

```bash
sudo docker inspect n8n-n8n-1 \
  --format '{{range .NetworkSettings.Networks}}Gateway: {{.Gateway}} | IP: {{.IPAddress}} | Net: {{.NetworkID}}{{"\n"}}{{end}}'
```

Output exemplu: `Gateway: 172.18.0.1 | IP: 172.18.0.5 | Net: ...`

> **Foloseste valoarea `Gateway`** (in exemplu `172.18.0.1`) ca `host` in credentialele Postgres din n8n.

## 8.2 Asculta pe interfata Docker

Edit `postgresql.conf` ca Postgres sa accepte conexiuni si pe gateway-ul Docker, nu doar `localhost`:

```bash
sudo sed -i "s/^#*listen_addresses.*/listen_addresses = 'localhost,172.18.0.1'/" \
  /etc/postgresql/18/main/postgresql.conf
```

## 8.3 Adauga regula in `pg_hba.conf`

```bash
echo "host    all    all    samenet    scram-sha-256" | \
  sudo tee -a /etc/postgresql/18/main/pg_hba.conf

sudo systemctl restart postgresql
```

## 8.4 Verifica

```bash
sudo ss -ltn | grep 5432
```

Trebuie sa vezi atat `127.0.0.1:5432` cat si `172.18.0.1:5432`.

Test din container n8n:

```bash
sudo docker exec n8n-n8n-1 node -e "
const net=require('net');
const s=net.createConnection({host:'172.18.0.1',port:5432,timeout:3000},()=>{
  console.log('TCP OK'); s.end();
});
s.on('error',e=>console.log('FAIL:',e.message));
"
```

Daca primesti `TCP OK`, credentialul Postgres din n8n trebuie configurat cu `host = 172.18.0.1`.
