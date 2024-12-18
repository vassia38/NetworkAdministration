https://ubuntu.com/tutorials/how-to-run-docker-inside-lxd-containers#4-test-your-docker-container
running docker inside lxc containers needs special settings

https://stackoverflow.com/questions/51930407/docker-compose-error-cannot-restrict-inter-container-communication
https://stackoverflow.com/questions/60894640/no-networking-from-host-to-docker-container
config of loaded kernel modules is very important

https://docs.docker.com/reference/cli/docker/swarm/init/
when having more than 1 network interfaces on each node, it is crucial to explicitly set
--advertise-addr and --listen-addr when initializing/joining

https://stackoverflow.com/questions/76768718/how-to-resize-an-ubuntu-lxc-lxd-container
have enough lxc storage and volume space
