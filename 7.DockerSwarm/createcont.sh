#!/bin/bash

containers=()
ips=()

# Save the IP address of the lxdbr0 device using 'lxc network list' and cut the last byte
lxdbr0_pref=$(lxc network list | grep lxdbr0 | awk -F '|' '{print $5}' | awk -F. '{print $1"."$2"."$3}' | xargs)
echo "The lxdbr0 network prefix is: $lxdbr0_pref"

for i in {1..3}; do
	containers+=("mgr$i")
	ips+=("${lxdbr0_pref}.1${i}")
	containers+=("wrk$i")
	ips+=("${lxdbr0_pref}.2${i}")
done

end=$(( ${#containers[@]} - 1 ))
for (( i=0; i<=end; i++ )); do
	lxc launch ubuntu:24.04 "${containers[$i]}"
 	lxc network attach lxdbr0 "${containers[$i]}" eth0 eth0
	lxc config device set "${containers[$i]}" eth0 ipv4.address "${ips[$i]}" 
	lxc config set "${containers[$i]}" \
	security.nesting=true \
	security.privileged=true \
	security.syscalls.intercept.mknod=true \
	security.syscalls.intercept.setxattr=true
	lxc restart "${containers[$i]}"
done
