#!/bin/bash

set -e

echo "[定时更新] 刷新 china ipset..."
ipset flush china

curl -sSL https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china.txt -o /etc/china-ip-firewall/china.txt

while read ip; do
  ipset add china "$ip"
done < /etc/china-ip-firewall/china.txt

ipset save > /etc/china-ip-firewall/ipset-china.conf

echo "[定时更新] 完成。"
