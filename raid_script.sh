#!/bin/bash
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk
# предполагаем пока, что занулять суперблоки не обязательно
# создаём массив
mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}
# пропишем конфигурацию в файле
mkdir /etc/mdadm
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
# создаём пять gpt-разделов
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
# создаём на разделах ФС
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
# создаём точки монтирования для разделов, прописываем разделы в fstab, монтируем их
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do
    echo "/dev/md0p$i /raid/part$i auto defaults 0 2" >> /etc/fstab
done
systemctl daemon-reload
for i in $(seq 1 5); do mount /dev/md0p$i; done
