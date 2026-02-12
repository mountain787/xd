# Native Server Setup with Pike 9

This guide shows you how to run the Xiandao game server directly with Pike 9 on a Linux server, without using Docker.

## Prerequisites

### System Requirements

- **OS**: Linux (CentOS 7+, Ubuntu 20.04+, Rocky Linux 8+)
- **RAM**: 4GB minimum, 8GB recommended
- **Disk**: 5GB free space
- **Ports**: 13800 (MUD), 8888 (HTTP API), 9001 (Web), 8443 (HTTPS)

### Install Required Software

#### 1. Install Pike 9

**For CentOS/Rocky Linux:**
```bash
# Install dependencies
yum install -y gcc make zlib-devel pcre-devel openssl-devel

# Download and build Pike 9
wget https://pike.lysator.liu.se/pub/pike/latest-stable/pike-8.0.tar.gz
tar xzf pike-8.0.tar.gz
cd pike-8.0

# Configure with MySQL support
./configure --with-mysql

make && make install
pike -v  # Verify installation
```

**For Ubuntu/Debian:**
```bash
# Install dependencies
apt-get update
apt-get install -y gcc make zlib1g-dev libpcre3-dev libssl-dev libmysqlclient-dev

# Download and build Pike 9
wget https://pike.lysator.liu.se/pub/pike/latest-stable/pike-8.0.tar.gz
tar xzf pike-8.0.tar.gz
cd pike-8.0

./configure --with-mysql
make && make install
pike -v
```

#### 2. Install MySQL

```bash
# CentOS/Rocky Linux
yum install -y mysql-server
systemctl start mysqld
systemctl enable mysqld

# Ubuntu/Debian
apt-get install -y mysql-server
systemctl start mysql
systemctl enable mysql
```

#### 3. Install Tomcat (Optional, for Web UI)

```bash
# Install Tomcat 9
yum install -y tomcat  # CentOS
# or
apt-get install -y tomcat9  # Ubuntu

systemctl start tomcat
systemctl enable tomcat
```

## Database Setup

### 1. Initialize Database

```bash
# Import the schema
mysql -u root -p < doc/mysql-init.sql
```

This creates the `xd01` database and all required tables.

### 2. Create Game User

```sql
mysql -u root -p
```

```sql
-- Create user for the game
CREATE USER 'xiandao'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON xd01.* TO 'xiandao'@'localhost';
FLUSH PRIVILEGES;
```

## Game Server Setup

### 1. Configure Environment

Create `.env` file in the project root:

```bash
cd /usr/local/games/xiand
cat > .env << EOF
# MySQL Configuration
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=xiandao
MYSQL_PASSWORD=your_secure_password

# Game Configuration
GAME_AREA=xd01
MUD_PORT=13800
HTTP_API_PORT=8888
EOF
```

### 2. Configure Game Parameters

Edit `lowlib/system/include/globals.h` if needed:

```c
// Game area identifier
#define GAME_AREA "xd01"

// MUD server port
#define MUD_PORT 13800

// Data root directory
#define DATA_ROOT ROOT "/udtestXI"
```

### 3. Setup Data Directories

```bash
# Create user data directory
mkdir -p /usr/local/games/udtestXI/u

# Create log directories
mkdir -p /usr/local/games/xiand/log

# Set permissions
chmod -R 755 /usr/local/games/udtestXI
```

## Starting the Server

### Start MUD Server

```bash
cd /usr/local/games/xiand

# Kill any existing instances
./startup.sh

# Or start manually
pike lowlib/driver.pike -i 127.0.0.1 -p 13800 /usr/local/games/xiand/ &
```

### Start HTTP API (Optional)

The HTTP API daemon starts automatically with the MUD server. It listens on port 8888.

### Start Web Frontend (Optional)

```bash
# Copy JSP files to Tomcat
cp -r frontjsp/* /var/lib/tomcat/webapps/ROOT/

# Edit configuration
vim /var/lib/tomcat/webapps/ROOT/xd/includes/config.inc

# Restart Tomcat
systemctl restart tomcat
```

## Managing the Server

### Check Server Status

```bash
# Check if MUD server is running
netstat -an | grep 13800

# Check HTTP API
curl http://localhost:8888/health

# View logs
tail -f /usr/local/games/xiand/log/*.log
```

### Restart Server

```bash
# Use the restart script
./restart.sh

# Or manually
kill $(ps aux | grep "pike.*13800" | grep -v grep | awk '{print $1}')
./startup.sh
```

### Stop Server

```bash
kill $(ps aux | grep "pike.*13800" | grep -v grep | awk '{print $1}')
```

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 13800
lsof -i :1380

# Kill it
kill -9 <PID>
```

### MySQL Connection Failed

```bash
# Check MySQL is running
systemctl status mysql

# Test connection
mysql -u xiandao -p -h 127.0.0.1 xd01

# Check firewall
firewall-cmd --list-ports
```

### Pike Module Not Found

```bash
# Check Pike module path
pike -v | grep "Module path"

# Add to PIKE_MODULE_PATH
export PIKE_MODULE_PATH=/usr/local/games/xiand
```

### Permission Denied

```bash
# Fix directory permissions
chmod -R 755 /usr/local/games/xiand
chown -R $USER:$USER /usr/local/games/xiand
```

## Production Tips

### 1. Use Systemd Service

Create `/etc/systemd/system/xiand.service`:

```ini
[Unit]
Description=Xiandao Game Server
After=network.target mysql.service

[Service]
Type=forking
User=games
WorkingDirectory=/usr/local/games/xiand
ExecStart=/usr/local/bin/pike lowlib/driver.pike -i 127.0.0.1 -p 13800 /usr/local/games/xiand/
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/bin/kill -TERM $MAINPID
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
systemctl start xiand
systemctl enable xiand
```

### 2. Log Rotation

Create `/etc/logrotate.d/xiand`:

```
/usr/local/games/xiand/log/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0644 games games
}
```

### 3. Monitor Resources

```bash
# Monitor memory usage
watch -n 5 'ps aux | grep pike | grep 13800'

# Monitor connections
watch -n 5 'netstat -an | grep 13800 | wc -l'
```

## Security Considerations

1. **Firewall**: Only expose necessary ports (80, 443, 8888)
2. **MySQL**: Don't expose port 3306 to the internet
3. **Passwords**: Use strong passwords for MySQL and game admin
4. **Updates**: Keep Pike 9 and system packages updated
5. **Backups**: Regular backups of `/usr/local/games/udtestXI` and MySQL database

## License

MIT License - See [LICENSE](../LICENSE) for details.
