# lilidns


Source code for <http://lilidns.com/>


## Running


### Clone project

```bash
cd /opt/
git clone https://github.com/marcojetson/lilidns.git
```

### Install dependencies

```bash
cd /opt/lilidns
bundler install
```

### Install PowerDNS

```bash
apt-get install -y pdns-server pdns-backend-sqlite3
```

### Configure PowerDNS

Edit /etc/powerdns/pdns.d/pdns.local.gsqlite3

```bash
# Launch gsqlite3
launch=gsqlite3

# Database location
gsqlite3-database=/opt/lilidns/lilidns.db

# Disable dnssec
gsqlite3-dnssec=off
```

### Start PowerDNS

```bash
service pdns start
```

### Run

```
ruby /opt/lilidns/application.rb
```
