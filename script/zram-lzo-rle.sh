#!/bin/bash
#Does user run script with sudo?
if [ "$EUID" -ne 0 ]
  then echo "Please, run script with sudo"
  exit 1
fi

#First, enable the module
echo "zram" > /etc/modules-load.d/zram.conf

#Configure the number of /dev/zram nodes you need.
echo "options zram num_devices=1" > /etc/modprobe.d/zram.conf

#Read total RAM value in bytes
MEM_CALC="$(cat /proc/meminfo | grep MemTotal | sed 's/[^0-9]*//g')"

#Convert kB to B
MEM_TOTAL=$(expr $MEM_CALC \* 1024)

echo KERNEL==\"zram0\", SUBSYSTEM==\"block\", DRIVER==\"\", ACTION==\"add\", ATTR{initstate}==\"0\", ATTR{comp_algorithm}=\"lzo-rle\", ATTR{disksize}=\"$MEM_TOTAL\", RUN=\"/usr/bin/mkswap /dev/zram0\", TAG+=\"systemd\" > /etc/udev/rules.d/99-zram.rules

#Add /dev/zram to your fstab.
echo "/dev/zram0 none swap defaults 0 0" >> /etc/fstab

#Loading new rules
udevadm control --reload
udevadm trigger
