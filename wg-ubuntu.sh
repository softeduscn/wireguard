#!/bin/bash

apt update
apt install wireguard resolvconf -y
interface=$(ip -o -4 route show to default | awk '{print $5}')
mkdir -p /etc/wireguard
cd /etc/wireguard
wg genkey | tee private.key | wg pubkey > public.key

echo "[Interface]
#PrivateKey = $(cat private.key)
PrivateKey = uCXBr9sKnbrT9cN4R5KepOwM6RZnipEyTKtyL9voEHY=
Address = 192.168.9.1/24 
PostUp   = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $interface -j MASQUERADE
ListenPort = 51820
MTU = 1420
SaveConfig = true

[Peer]
PublicKey = ql9g9ngGQMq9cyBaun5QjnyROyh7Cu4zJ9eZwFM6UGw=
AllowedIPs = 192.168.9.2/32
Endpoint = 114.87.72.214:12604

[Peer]
PublicKey = RuCdaOHKPDf2c2kihx2dzBhEDKZnbnhP1N4aUBkzw3A=
AllowedIPs = 192.168.9.3/32
Endpoint = 101.84.164.21:13621

[Peer]
PublicKey = HkRSRzDMks74AmFQlnByouVNR6E/o5I+j033QqF1UyI=
AllowedIPs = 192.168.9.5/32
Endpoint = 117.136.8.97:52935

[Peer]
PublicKey = oMLjf94E/fIvN50WzTwAw4Qi3EbxCZgV8By5Bjyxsgk=
AllowedIPs = 192.168.9.120/32
Endpoint = 101.80.52.11:51204

[Peer]
PublicKey = msVOdo33cUvIY7ke4UJUcOfEs4MbFZwBMFnnWl3tOTo=
AllowedIPs = 192.168.9.118/32
Endpoint = 101.80.53.170:39186
" > wg0.conf

chmod 777 -R /etc/wireguard
 
sysctl_config() {
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    sysctl -p >/dev/null 2>&1
}

sysctl_config
lsmod | grep bbr

echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

wg-quick up wg0

systemctl enable wg-quick@wg0

wg
