#Written by Joseph

#Enable or allow ICMP ping incoming client request
#"173.194.38.80" is the IP Address for www.google.com
SERVER_IP="173.194.38.80"

sudo iptables -F
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP

#Rule to enable ICMP ping incoming client request ( assuming that default iptables policy is to drop all INPUT and OUTPUT packets)
sudo iptables -A OUTPUT -p icmp --icmp-type 8 -s 0/0 -d $SERVER_IP -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type 0 -s $SERVER_IP -d 0/0 -m state --state ESTABLISHED,RELATED -j ACCEPT


#To enable ICMP ping outgoing request use following iptables rule:
sudo iptables -A OUTPUT -p icmp --icmp-type 8 -s $SERVER_IP -d 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type 0 -s 0/0 -d $SERVER_IP -m state --state ESTABLISHED,RELATED -j ACCEPT

