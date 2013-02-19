#Written by Joseph
#This script makes the outgoing & incoming ICMP request(menas "ping") disable.

sudo iptables -F
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-request -j DROP
sudo iptables -A INPUT -p icmp --icmp-type echo-reply -j DROP
sudo iptables -L
