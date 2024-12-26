# Google DNS server addition

    sudo sh -c "echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > /etc/resolv.conf"
    sudo resolvconf -u

    