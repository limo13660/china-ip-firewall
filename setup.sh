#!/bin/bash

set -e

echo "🔧 安装依赖..."
apt update && apt install -y ipset curl wget

echo "🌐 下载中国 IP 列表..."
mkdir -p /etc/china-ip-firewall
curl -sSL https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china.txt -o /etc/china-ip-firewall/china.txt

echo "🧱 创建 ipset 规则..."
ipset destroy china 2>/dev/null || true
ipset create china hash:net
for ip in $(cat /etc/china-ip-firewall/china.txt); do
  ipset add china "$ip"
done

echo "⛔️ 添加 iptables 拒绝非中国 IP..."
iptables -D INPUT -m set ! --match-set china src -j DROP 2>/dev/null || true
iptables -I INPUT -m set ! --match-set china src -j DROP

echo "💾 保存规则..."
ipset save > /etc/china-ip-firewall/ipset-china.conf
iptables-save > /etc/china-ip-firewall/iptables.rules

echo "🕘 安装定时任务..."
cp ./scripts/update_china_ipset.sh /usr/local/bin/
chmod +x /usr/local/bin/update_china_ipset.sh
cp ./systemd/*.service ./systemd/*.timer /etc/systemd/system/

systemctl daemon-reload
systemctl enable --now update-china-ipset.timer

echo "✅ 安装完成。每天凌晨3点自动更新IP段。"
