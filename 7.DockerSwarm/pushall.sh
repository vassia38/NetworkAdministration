for i in 1 2 3
do 
cat dockerinstall.sh | lxc shell mgr$i
cat dockerinstall.sh | lxc shell wrk$i
done
