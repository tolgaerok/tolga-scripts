sudo bash -c 'echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control'
sudo echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler
