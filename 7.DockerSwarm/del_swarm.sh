#!/bin/bash

containers=()
for i in {1..3}; do
        containers+=("mgr$i")
        containers+=("wrk$i")
done
for i in ${containers[@]};do
	lxc exec $i -- docker swarm leave --force
	lxc exec $i -- docker system prune --all --force
done
