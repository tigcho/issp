set-netconnectionprofile -interfacealias "Ethernet 2" -networkcategory private
new-netipaddress -interfacealias "Ethernet 2" -ipaddress 192.168.56.101 -prefixlength 24 -defaultgateway 192.168.56.10
set-dnsclientserveraddress -interfacealias "Ethernet 2" -serveraddresses 192.168.56.10
netsh advfirewall firewall add rule name="Allow ICMPv4-In" protocol=icmpv4:8,any dir=in action=allow
