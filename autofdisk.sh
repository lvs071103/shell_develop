#!/bin/bash

fdisk /dev/vdb <<'EOF'
n
p
1

+4G
n
p
2


t
1
82
w
EOF
mkswap -L swap /dev/vdb1
swapon /dev/vdb1
vdb1_uuid=$(blkid -o value -s UUID /dev/vdb1)
sed -i '$a\UUID='$vdb1_uuid'       swap    swap    defaults        0 0' /etc/fstab
mkfs.xfs /dev/vdb2
mount -t xfs /dev/vdb2 /data
vdb2_uuid=$(blkid -o value -s UUID /dev/vdb2)
sed -i '$a\UUID='$vdb2_uuid'       /data   xfs     defaults,noatime        0 0' /etc/fstab
exit 0
