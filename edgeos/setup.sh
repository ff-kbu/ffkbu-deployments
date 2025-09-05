# shellcheck disable=SC2121,SC2016,SC2148,SC2059,SC2046,SC2183
#
#=================== Modify below and then copy from THIS LINE until EOF ===================
# version check
configure
sleep 1

ROUTER_NAME="ZZZ" # format: ff<name>up01
ROUTER_LOCATION_ADDRESS="YYY" # format without Umlaut: <street name> <number>, <zipcode> <city>

# ROUTER_ADMIN_ENCR_PASSWORD is encrypted and can be shared
ROUTER_ADMIN_ENCR_PASSWORD='$5$ss3r7p.y6VkZeoJr$9/MtjUnefQh4fuSfr/KBMDBcB40MVkcY3TjSHteXyLD'
ROUTER_GUI_LISTEN_ADDRESS="10.2XX.0.100"
ROUTER_IPV4_ADDRESS="10.2XX.0.100/16"
ROUTER_IPV6_ADDRESS="2a03:2260:101a:2XX::100/64"
ROUTER_INTERFACE_WAN_0="eth0"
ROUTER_INTERFACE_WAN_1="eth1"
ROUTER_INTERFACE_LAN="eth2"

ROUTER_WAN1_IP_ADDRESS="192.168.2.240/24"
ROUTER_WAN1_NEXTHOP="192.168.2.1"
# for single wan connection set ROUTER_WAN2_IP_ADDRESS to ""
ROUTER_WAN2_IP_ADDRESS=""
ROUTER_WAN2_NEXTHOP="192.168.2.1"

DHCP_IP_FIRST="10.2XX.0.101"
DHCP_IP_LAST="10.2XX.255.254"
DHCP_NETWORK_V4="10.2XX.0.0/16"
DHCP_NETWORK_V6="2a03:2260:101a:2XX::/64"
DHCP_LEASE_TIME="1800"

IPV6_RA_IP_ADDRESS="2a03:2260:101a:2XX::100"

DNS_DOMAIN="ffkbu.lan"
DNS_SERVER_PRIMARY_IP="10.0.1.3"
DNS_SERVER_SECONDARY_IP="10.0.1.4"

# always us IPs for wireguard gateway addresses
WIREGUARD_ENDPOINT_PORT="194XX"
WIREGUARD_ENDPOINT_1_GATEWAY_IP="116.203.4.48"
WIREGUARD_ENDPOINT_1_LOCAL_IPV4="10.1XX.0.11"
WIREGUARD_ENDPOINT_1_LOCAL_IPV6="2a03:2260:101a:1XX::11"
WIREGUARD_ENDPOINT_1_REMOTE_IPV4="10.1XX.0.1"
WIREGUARD_ENDPOINT_1_REMOTE_IPV6="2a03:2260:101a:1XX::1"
WIREGUARD_ENDPOINT_2_GATEWAY_IP="116.202.4.116"
WIREGUARD_ENDPOINT_2_LOCAL_IPV4="10.1XX.0.12"
WIREGUARD_ENDPOINT_2_LOCAL_IPV6="2a03:2260:101a:1XX::12"
WIREGUARD_ENDPOINT_2_REMOTE_IPV4="10.1XX.0.2"
WIREGUARD_ENDPOINT_2_REMOTE_IPV6="2a03:2260:101a:1XX::2"

# NEVER SAVE THIS SCRIPT WITH WIREGUARD_PRIVATE_KEY IN IT
# CHANGE TO "" AFTER SETUP !!!
WIREGUARD_PRIVATE_KEY=""
WIREGUARD_REMOTE_PUBKEY=""

UISP_GATEWAY_IP="23.88.124.22"
UISP_DOMAIN="uisp.kbu.freifunk.net"

NTP_SERVER_1="192.53.103.103"
NTP_SERVER_2="10.0.1.3"
NTP_SERVER_3="10.0.1.4"
#
#=================== DO NOT EDIT BELOW THIS LINE  ===================
#
if ! _vyatta_op_run show version | grep "Version" | grep -q "v3"; then
  echo "ERROR: Upgrade OS first!"
  exit
  sleep 1
  exit
fi

# Set the system settings
eval $(printf "set system analytics-handler send-analytics-report false")
eval $(printf "set system crash-handler send-crash-report false")
eval $(printf "set system host-name $ROUTER_NAME")

# Configure lan interface
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN address $ROUTER_IPV4_ADDRESS")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN address $ROUTER_IPV6_ADDRESS")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN description 'LAN'")

# set dhcp and RA
eval $(printf "set service dhcp-server shared-network-name LAN authoritative enable")
eval $(printf "set service dhcp-server shared-network-name LAN subnet $DHCP_NETWORK_V4 start $DHCP_IP_FIRST stop $DHCP_IP_LAST")
eval $(printf "set service dhcp-server shared-network-name LAN subnet $DHCP_NETWORK_V4 default-router $ROUTER_GUI_LISTEN_ADDRESS")
eval $(printf "set service dhcp-server shared-network-name LAN subnet $DHCP_NETWORK_V4 dns-server $ROUTER_GUI_LISTEN_ADDRESS")
eval $(printf "set service dhcp-server shared-network-name LAN subnet $DHCP_NETWORK_V4 domain-name $DNS_DOMAIN")
eval $(printf "set service dhcp-server shared-network-name LAN subnet $DHCP_NETWORK_V4 time-server $ROUTER_GUI_LISTEN_ADDRESS")
eval $(printf "set service dhcp-server shared-network-name LAN subnet $DHCP_NETWORK_V4 lease $DHCP_LEASE_TIME")

eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN ipv6 dup-addr-detect-transmits 1")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN ipv6 router-advert cur-hop-limit 64")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN ipv6 router-advert link-mtu 0")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN ipv6 router-advert send-advert true")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN ipv6 router-advert max-interval 600")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN ipv6 router-advert prefix '::/64' autonomous-flag true")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN ipv6 router-advert prefix '::/64' on-link-flag true")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN ipv6 router-advert prefix '::/64' valid-lifetime 7200")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN ipv6 router-advert reachable-time 0")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN ipv6 router-advert retrans-timer 0")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN ipv6 router-advert name-server $IPV6_RA_IP_ADDRESS")

eval $(printf "set custom-attribute setupstage value 1")
eval $(printf "show custom-attribute setupstage") | grep -q "+value 1" || SETUP=1
echo $SETUP | grep -q 1 || commit
echo $SETUP | grep -q 1 || save
echo $SETUP | grep -q 1 || exit
echo "First setup stage complete!"
echo $SETUP | grep -q 1 || reboot now
# end first setup part


# configure dns domain and forwarding
delete system name-server
commit
eval $(printf "set system name-server 127.0.0.1")
eval $(printf "set system domain-search domain $DNS_DOMAIN")
eval $(printf "set system time-zone Europe/Berlin")
eval $(printf "set service dns forwarding name-server $DNS_SERVER_PRIMARY_IP")
eval $(printf "set service dns forwarding name-server $DNS_SERVER_SECONDARY_IP")
eval $(printf "set service dns forwarding cache-size 5000")
eval $(printf "set service dns forwarding except-interface $ROUTER_INTERFACE_WAN_0")
eval $(printf "set service dns forwarding except-interface $ROUTER_INTERFACE_WAN_1")
commit

# Set IPs for wan interfaces
eval $(printf "delete interfaces ethernet $ROUTER_INTERFACE_WAN_0 address")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_WAN_0 address $ROUTER_WAN1_IP_ADDRESS")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_WAN_0 description 'WAN0'")

eval $(printf "delete interfaces ethernet $ROUTER_INTERFACE_WAN_1 address")
[[ -z $ROUTER_WAN2_IP_ADDRESS ]] || eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_WAN_1 address $ROUTER_WAN2_IP_ADDRESS")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_WAN_1 description 'WAN1'")

# Configure login credentials
eval $(printf "%s" "set system login user ubnt authentication encrypted-password $ROUTER_ADMIN_ENCR_PASSWORD")
commit

# Create a WireGuard key
echo "$WIREGUARD_PRIVATE_KEY" > /config/auth/wg.key

# set static routes to direct wireguard peers to wan interfaces
eval $(printf "set protocols static route 0.0.0.0/0 next-hop $WIREGUARD_ENDPOINT_1_REMOTE_IPV4")
eval $(printf "set protocols static route6 ::/0 next-hop $WIREGUARD_ENDPOINT_1_REMOTE_IPV6")
eval $(printf "set protocols static route 0.0.0.0/0 next-hop $WIREGUARD_ENDPOINT_2_REMOTE_IPV4")
eval $(printf "set protocols static route6 ::/0 next-hop $WIREGUARD_ENDPOINT_1_REMOTE_IPV6")

eval $(printf "set protocols static route $WIREGUARD_ENDPOINT_1_GATEWAY_IP/32 next-hop $ROUTER_WAN1_NEXTHOP")
eval $(printf "set protocols static route $WIREGUARD_ENDPOINT_2_GATEWAY_IP/32 next-hop $ROUTER_WAN2_NEXTHOP")

# set static routes for ntp
eval $(printf "set protocols static route $NTP_SERVER_1/32 next-hop $ROUTER_WAN1_NEXTHOP")
eval $(printf "set protocols static route $NTP_SERVER_1/32 next-hop $ROUTER_WAN2_NEXTHOP")

# set static routes for uisp
eval $(printf "set protocols static route $UISP_GATEWAY_IP/32 next-hop $ROUTER_WAN1_NEXTHOP")
eval $(printf "set protocols static route $UISP_GATEWAY_IP/32 next-hop $ROUTER_WAN2_NEXTHOP")
eval $(printf "set system static-host-mapping host-name $UISP_DOMAIN inet $UISP_GATEWAY_IP")
commit

# setup wireguard tunnel to first exit node
eval $(printf "set interfaces wireguard wg0 route-allowed-ips false")
eval $(printf "set interfaces wireguard wg0 peer $WIREGUARD_REMOTE_PUBKEY endpoint $WIREGUARD_ENDPOINT_1_GATEWAY_IP:$WIREGUARD_ENDPOINT_PORT")
eval $(printf "set interfaces wireguard wg0 address $WIREGUARD_ENDPOINT_1_LOCAL_IPV4/32")
eval $(printf "set interfaces wireguard wg0 address $WIREGUARD_ENDPOINT_1_LOCAL_IPV6/128")
eval $(printf "set interfaces wireguard wg0 peer $WIREGUARD_REMOTE_PUBKEY allowed-ips ::/0")
eval $(printf "set interfaces wireguard wg0 peer $WIREGUARD_REMOTE_PUBKEY allowed-ips 0.0.0.0/0")
eval $(printf "set interfaces wireguard wg0 peer $WIREGUARD_REMOTE_PUBKEY persistent-keepalive 10")
eval $(printf "set interfaces wireguard wg0 private-key /config/auth/wg.key")
eval $(printf "set interfaces wireguard wg0 mtu 1400")
eval $(printf "set protocols static interface-route $WIREGUARD_ENDPOINT_1_REMOTE_IPV4/32 next-hop-interface wg0")
eval $(printf "set protocols static interface-route6 $WIREGUARD_ENDPOINT_1_REMOTE_IPV6/128 next-hop-interface wg0")
commit

# setup wireguard tunnel to second exit node
eval $(printf "set interfaces wireguard wg1 route-allowed-ips false")
eval $(printf "set interfaces wireguard wg1 peer $WIREGUARD_REMOTE_PUBKEY endpoint $WIREGUARD_ENDPOINT_2_GATEWAY_IP:$WIREGUARD_ENDPOINT_PORT")
eval $(printf "set interfaces wireguard wg1 address $WIREGUARD_ENDPOINT_2_LOCAL_IPV4/32")
eval $(printf "set interfaces wireguard wg1 address $WIREGUARD_ENDPOINT_2_LOCAL_IPV6/128")
eval $(printf "set interfaces wireguard wg1 peer $WIREGUARD_REMOTE_PUBKEY allowed-ips ::/0")
eval $(printf "set interfaces wireguard wg1 peer $WIREGUARD_REMOTE_PUBKEY allowed-ips 0.0.0.0/0")
eval $(printf "set interfaces wireguard wg1 peer $WIREGUARD_REMOTE_PUBKEY persistent-keepalive 10")
eval $(printf "set interfaces wireguard wg1 private-key /config/auth/wg.key")
eval $(printf "set interfaces wireguard wg1 mtu 1400")
eval $(printf "set protocols static interface-route $WIREGUARD_ENDPOINT_2_REMOTE_IPV4/32 next-hop-interface wg1")
eval $(printf "set protocols static interface-route6 $WIREGUARD_ENDPOINT_2_REMOTE_IPV6/128 next-hop-interface wg1")
commit

# enable dns forwarding
eval $(printf "set service dns forwarding except-interface wg0")
eval $(printf "set service dns forwarding except-interface wg1")

# mss-clamping to pass ethernet frames though gre with MTU 1400 at FFRL
eval $(printf "set firewall options mss-clamp mss 1320")
eval $(printf "set firewall options mss-clamp interface-type all")
eval $(printf "set firewall options mss-clamp6 mss 1320")
eval $(printf "set firewall options mss-clamp6 interface-type all")
commit

# set login banner
eval $(printf "set system login banner pre-login ''")
eval $(printf "%s" "set system login banner post-login \"\nFreifunk KBU\n$ROUTER_LOCATION_ADDRESS\n\n\n\"")
commit

# Set firewall rules for wan interfaces
eval $(printf "set firewall name WAN_LOCAL_V4 rule 10 action accept")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 10 log disable")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 10 protocol icmp")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 10 state new enable")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 10 description 'Allow IPv4 icmp from wan'")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 20 action accept")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 20 protocol tcp")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 20 destination port 22")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 20 state new enable")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 20 description 'Allow IPv4 ssh connection from wan'")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 900 state established enable")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 900 state related enable")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 900 action accept")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 900 description 'Allow IPv4 established and related connections'")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 901 state invalid enable")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 901 action drop")
eval $(printf "set firewall name WAN_LOCAL_V4 rule 901 description 'IPv4 Drop invalid state'")

# allow icmp
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 default-action drop")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 10 action accept")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 10 log disable")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 10 protocol icmp")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 10 state new enable")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 10 description 'Allow IPv6 icmp from wan'")

# allow ssh
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 20 action accept")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 20 protocol tcp")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 20 destination port 22")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 20 state new enable")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 20 description 'Allow IPv6 ssh connection from wan'")

# allow related and established connections, drop invalid
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 900 state established enable")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 900 state related enable")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 900 action accept")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 900 description 'Allow IPv6 established and related connections'")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 901 state invalid enable")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 901 action drop")
eval $(printf "set firewall ipv6-name WAN_LOCAL_V6 rule 901 description 'IPv6 Drop invalid state'")
commit

eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_WAN_0 firewall local name WAN_LOCAL_V4")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_WAN_1 firewall local name WAN_LOCAL_V4")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_WAN_0 firewall local ipv6-name WAN_LOCAL_V6")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_WAN_1 firewall local ipv6-name WAN_LOCAL_V6")
commit

# set firwall rules for lan interfaces
eval $(printf "set firewall name LAN_IN_V4 default-action drop")

eval $(printf "set firewall name LAN_IN_V4 rule 10 action accept")
eval $(printf "set firewall name LAN_IN_V4 rule 10 log disable")
eval $(printf "set firewall name LAN_IN_V4 rule 10 destination address $DHCP_NETWORK_V4")
eval $(printf "set firewall name LAN_IN_V4 rule 10 protocol all")
eval $(printf "set firewall name LAN_IN_V4 rule 10 description 'Allow IPv4 LAN to LAN'")

# IMPORTANT: ALWAYS LIMIT TO ! 10.0.0.0/8.
# OTHERWISE LAN CLIENTS CAN ACCESS ALL INTERNAL FFKBU RESSOURCES
eval $(printf "set firewall name LAN_IN_V4 rule 20 action accept")
eval $(printf "set firewall name LAN_IN_V4 rule 20 protocol all")
eval $(printf "set firewall name LAN_IN_V4 rule 20 destination address !10.0.0.0/8")
eval $(printf "set firewall name LAN_IN_V4 rule 20 state new enable")
eval $(printf "set firewall name LAN_IN_V4 rule 20 description 'Allow IPv4 Freifunk WAN Access'")

# Used for service website, uisp and unifi controller
eval $(printf "set firewall name LAN_IN_V4 rule 40 action accept")
eval $(printf "set firewall name LAN_IN_V4 rule 40 protocol tcp_udp")
eval $(printf "set firewall name LAN_IN_V4 rule 40 destination address $DNS_SERVER_SECONDARY_IP")
eval $(printf "set firewall name LAN_IN_V4 rule 40 destination port 443,2055,3478,6789,8080,8443,9080,9443,10001")
eval $(printf "set firewall name LAN_IN_V4 rule 40 state new enable")
eval $(printf "set firewall name LAN_IN_V4 rule 40 description 'Allow FFKBU service access'")

# Used for uisp and unifi controller
eval $(printf "set firewall name LAN_IN_V4 rule 41 action accept")
eval $(printf "set firewall name LAN_IN_V4 rule 41 protocol icmp")
eval $(printf "set firewall name LAN_IN_V4 rule 41 destination address $DNS_SERVER_SECONDARY_IP")
eval $(printf "set firewall name LAN_IN_V4 rule 41 state new enable")
eval $(printf "set firewall name LAN_IN_V4 rule 41 description 'Allow IPv4 Unifi Controller ICMP'")

# Used for client ntp
eval $(printf "set firewall name LAN_IN_V4 rule 42 action accept")
eval $(printf "set firewall name LAN_IN_V4 rule 42 protocol udp")
eval $(printf "set firewall name LAN_IN_V4 rule 42 destination address $DNS_SERVER_SECONDARY_IP")
eval $(printf "set firewall name LAN_IN_V4 rule 42 state new enable")
eval $(printf "set firewall name LAN_IN_V4 rule 42 description 'Allow IPv4 Unifi Controller UDP'")

eval $(printf "set firewall name LAN_IN_V4 rule 900 state established enable")
eval $(printf "set firewall name LAN_IN_V4 rule 900 state related enable")
eval $(printf "set firewall name LAN_IN_V4 rule 900 action accept")
eval $(printf "set firewall name LAN_IN_V4 rule 900 description 'Allow IPv4 established and related connections'")
eval $(printf "set firewall name LAN_IN_V4 rule 901 state invalid enable")
eval $(printf "set firewall name LAN_IN_V4 rule 901 action drop")
eval $(printf "set firewall name LAN_IN_V4 rule 901 description 'IPv4 Drop invalid state'")

eval $(printf "set firewall name LAN_LOCAL_V4 default-action drop")
eval $(printf "set firewall name LAN_LOCAL_V4 rule 10 action accept")
eval $(printf "set firewall name LAN_LOCAL_V4 rule 10 log disable")
eval $(printf "set firewall name LAN_LOCAL_V4 rule 10 state new enable")
eval $(printf "set firewall name LAN_LOCAL_V4 rule 10 description 'Allow local IPv4 LAN'")

# allow related and established connections, drop invalid
eval $(printf "set firewall name LAN_LOCAL_V4 rule 900 state established enable")
eval $(printf "set firewall name LAN_LOCAL_V4 rule 900 state related enable")
eval $(printf "set firewall name LAN_LOCAL_V4 rule 900 action accept")
eval $(printf "set firewall name LAN_LOCAL_V4 rule 900 description 'Allow local established and related connections'")
eval $(printf "set firewall name LAN_LOCAL_V4 rule 901 state invalid enable")
eval $(printf "set firewall name LAN_LOCAL_V4 rule 901 action drop")
eval $(printf "set firewall name LAN_LOCAL_V4 rule 901 description 'IPv4 Drop local invalid state'")
commit


eval $(printf "set firewall ipv6-name LAN_IN_V6 default-action drop")

eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 10 action accept")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 10 destination address $DHCP_NETWORK_V6")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 10 state new enable")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 10 description 'Allow IPv6 LAN to LAN'")

eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 20 action accept")
eval $(printf "%s" "set firewall ipv6-name LAN_IN_V6 rule 20 destination address !2a03:2260:101a::1-2a03:2260:101a::10")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 20 state new enable")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 20 description 'Allow IPv6 Freifunk WAN Access'")

eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 21 action accept")
eval $(printf "%s" "set firewall ipv6-name LAN_IN_V6 rule 21 destination address 2a03:2260:101a::1-2a03:2260:101a::10")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 21 protocol tcp_udp")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 21 destination port 443,8080,8443,9443,9080")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 21 state new enable")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 21 description 'Allow IPv6 Freifunk Service Access'")

eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 900 state established enable")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 900 state related enable")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 900 action accept")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 900 description 'Allow IPv6 established and related connections'")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 901 state invalid enable")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 901 action drop")
eval $(printf "set firewall ipv6-name LAN_IN_V6 rule 901 description 'IPv4 Drop invalid state'")
commit

eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN firewall in name LAN_IN_V4")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN firewall local name LAN_LOCAL_V4")
eval $(printf "set interfaces ethernet $ROUTER_INTERFACE_LAN firewall in ipv6-name LAN_IN_V6")
commit

# set up ibgp
eval $(printf "set protocols bgp 65528 parameters router-id 10.105.0.0")
eval $(printf "set protocols bgp 65528 parameters graceful-restart")
eval $(printf "set protocols bgp 65528 network $DHCP_NETWORK_V4")
eval $(printf "set protocols bgp 65528 address-family ipv6-unicast network $DHCP_NETWORK_V6")
eval $(printf "set protocols static route $DHCP_NETWORK_V4 blackhole")
eval $(printf "set protocols static route6 $DHCP_NETWORK_V6 blackhole")

eval $(printf "set policy prefix-list BGPV4INPREFIXES rule 10 action deny")
eval $(printf "set policy prefix-list BGPV4INPREFIXES rule 10 prefix 0.0.0.0/0")
eval $(printf "set policy prefix-list BGPV4INPREFIXES rule 20 action permit")
eval $(printf "set policy prefix-list BGPV4INPREFIXES rule 20 prefix 10.0.0.0/16")
eval $(printf "set policy prefix-list BGPV4INPREFIXES rule 21 action permit")
eval $(printf "set policy prefix-list BGPV4INPREFIXES rule 21 prefix 10.0.0.1/32")
eval $(printf "set policy prefix-list BGPV4INPREFIXES rule 22 action permit")
eval $(printf "set policy prefix-list BGPV4INPREFIXES rule 22 prefix 10.1.0.0/24")

eval $(printf "set policy prefix-list6 BGPV6INPREFIXES rule 10 action deny")
eval $(printf "set policy prefix-list6 BGPV6INPREFIXES rule 10 prefix ::/0")
eval $(printf "set policy prefix-list6 BGPV6INPREFIXES rule 20 action permit")
eval $(printf "set policy prefix-list6 BGPV6INPREFIXES rule 20 prefix 2a03:2260:101a::/64")


eval $(printf "set policy route-map BGPV4IN rule 10 action permit")
eval $(printf "set policy route-map BGPV4IN rule 10 match ip address prefix-list BGPV4INPREFIXES")
eval $(printf "set policy route-map BGPV6IN rule 10 action permit")
eval $(printf "set policy route-map BGPV6IN rule 10 match ipv6 address prefix-list BGPV6INPREFIXES")


eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_1_REMOTE_IPV4 remote-as 65528")
eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_1_REMOTE_IPV4 description 'bgp_en01'")
eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_1_REMOTE_IPV4 route-map import BGPV4IN")
eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_1_REMOTE_IPV4 soft-reconfiguration inbound")
eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_1_REMOTE_IPV4 address-family ipv6-unicast")
eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_1_REMOTE_IPV4 update-source $WIREGUARD_ENDPOINT_1_LOCAL_IPV4")

eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_2_REMOTE_IPV4 remote-as 65528")
eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_2_REMOTE_IPV4 description 'bgp_en02'")
eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_2_REMOTE_IPV4 route-map import BGPV4IN")
eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_2_REMOTE_IPV4 soft-reconfiguration inbound")
eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_2_REMOTE_IPV4 address-family ipv6-unicast")
eval $(printf "set protocols bgp 65528 neighbor $WIREGUARD_ENDPOINT_2_REMOTE_IPV4 update-source $WIREGUARD_ENDPOINT_2_LOCAL_IPV4")
commit

# setup ntp
eval $(printf "delete system ntp server")
commit
eval $(printf "set system ntp server $NTP_SERVER_1 prefer")
eval $(printf "set system ntp server $NTP_SERVER_2")
eval $(printf "set system ntp server $NTP_SERVER_3")
commit

# disable flow-accounting
eval $(printf "delete system flow-accounting")
commit

# enable snmp for slurp
eval $(printf "set service snmp community public client 10.3.0.2")
eval $(printf "set service snmp community public authorization ro")
commit

# setup offloading
grep -q "MediaTek" /proc/cpuinfo && eval $(printf "set system offload hwnat enable")
eval $(printf "set system offload ipv4 table-size 65536")
eval $(printf "set system offload ipv6 table-size 65536")
# setup model dependante offloading settings
grep -q "MediaTek" /proc/cpuinfo || eval $(printf "set system offload ipv4 forwarding enable")
grep -q "MediaTek" /proc/cpuinfo || eval $(printf "set system offload ipv6 forwarding enable")
grep -q "MediaTek" /proc/cpuinfo || eval $(printf "set system offload ipv4 disable-flow-flushing-upon-fib-changes")
grep -q "MediaTek" /proc/cpuinfo || eval $(printf "set system offload ipv6 disable-flow-flushing-upon-fib-changes")
grep -q "MediaTek" /proc/cpuinfo || eval $(printf "set system offload flow-lifetime 120")
commit


save
exit
reboot now
# EOF
