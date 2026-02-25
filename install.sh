#!/bin/bash

echo "Installing 3proxy..."

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

cat > /etc/3proxy/3proxy.cfg <<EOF
daemon
pidfile /var/run/3proxy.pid
nscache 65536
maxconn 1000
timeouts 1 5 30 60 180 1800 15 60
users happy:CL:happy
auth strong
allow happy
proxy -p3128
socks -p1080
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

systemctl daemon-reload
systemctl enable 3proxy
systemctl restart 3proxy

echo "----------------------------------"
systemctl status 3proxy --no-pager
echo "----------------------------------"
echo "Proxy Installed Successfully"
echo "HTTP: 3128"
echo "SOCKS5: 1080"
echo "User: happy"
echo "Pass: happy"
