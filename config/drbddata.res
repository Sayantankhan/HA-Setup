resource drbddata {
    protocol C;
    meta-disk  internal;
    device     /dev/drbd0;
    
    on node1 {
        disk       /dev/loop10;
        address ipv4 10.0.0.11:7789;
    }

    on node2 {
        disk       /dev/loop11;
        address ipv4 10.0.0.12:7789;
    }
}

