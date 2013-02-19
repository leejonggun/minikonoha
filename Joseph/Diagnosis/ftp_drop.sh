#Written by Joseph
#This script makes the outgoing & incoming ICMP request(menas "ping") enable.

sudo iptables -F
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
#ftp-control
sdo iptables -A OUTPUT -p tcp --dport 21  -j DROP
sudo iptables -A INPUT -p tcp --sport 21  -j DROP
#ftp-control
#ftp-data
sudo iptables -A INPUT -p tcp --dport 20 -j DROP
sudo iptables -A OUTPUT -p tcp --sport 20 -j DROP
#ftp-data
sudo iptables -L
