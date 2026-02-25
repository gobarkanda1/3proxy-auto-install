#!/bin/bash

echo "====== 3Proxy Auto Installer ======"

apt update -y
apt install -y build-essential git

cd /opt
rm -rf 3proxy
git clone https://github.com/z3APA3A/3proxy.git
cd 3proxy
make -f Makefile.Linux

cp bin/3proxy /usr/local/bin/
chmod +x /usr/local/bin/3proxy

mkdir -p /etc/3proxy

# ===== USER INPUT =====
read -p "Enter Proxy Username: " PROXY_USER
read -p "Enter Proxy Password: " PROXY_PASS
read -p "Enter HTTP Port (example 3128): " PROXY_PORT
read -p "Enter SOCKS5 Port (example 1080): " SOCKS_PORT

cat > /etc/3proxy/3proxy.cfg <<EOF
daemon
pidfile /var/run/3proxy.pid
nscache 65536
maxconn 2000
timeouts 1 5 30 60 180 1800 15 60
users $PROXY_USER:CL:$PROXY_PASS
auth strong
allow $PROXY_USER
proxy -p$PROXY_PORT
socks -p$SOCKS_PORT
flush
EOF

cat > /etc/systemd/system/3proxy.service <<EOF
[Unit]
Description=3Proxy Proxy Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/bin/3proxy /etc/3proxy/3proxy.cfg
PIDFile=/var/run/3proxy.pid
Restart=always
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# ===== CHANGE COMMAND SCRIPT =====
cat > /usr/local/bin/proxy-change <<EOF
#!/bin/bash
read -p "New Username: " NEW_USER
read -p "New Password: " NEW_PASS
read -p "New HTTP Port: " NEW_PORT
read -p "New SOCKS5 Port: " NEW_SOCKS

cat > /etc/3proxy/3proxy.cfg <<EOC
daemon
pidfile /var/run/3proxy.pid
nscache 65536
maxconn 2000
timeouts 1 5 30 60 180 1800 15 60
users \$NEW_USER:CL:\$NEW_PASS
auth strong
allow \$NEW_USER
proxy -p\$NEW_PORT
socks -p\$NEW_SOCKS
flush
EOC

systemctl restart 3proxy
echo "Proxy Updated Successfully!"
EOF

chmod +x /usr/local/bin/proxy-change

systemctl daemon-reload
systemctl enable 3proxy
systemctl restart 3proxy

echo "==================================="
echo "Proxy Installed Successfully!"
echo "To change settings anytime run:"
echo "proxy-change"
echo "==================================="
