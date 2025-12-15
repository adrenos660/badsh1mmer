#!/bin/sh
# written mostly by mariah carey (xXMariahScaryXx) 
fail(){
  printf "$1\n"
  printf "please attach error logs and report to crosbreaker on discord or github...\n"
  sleep infinity # so people have time to photograph/record error outputs in reports
}
prep_quicksilver() {
	mkdir -p /run/vpd /localroot
	mount "$intdis$intdis_prefix"3 /localroot -o ro
	for rootdir in dev proc run sys; do
		mount --bind /${rootdir} /localroot/${rootdir}
	done
	if vpd -i RW_VPD -l | grep re_enrollment > /dev/null 2>&1; then
		quicksilver=true
	else
		quicksilver=false
	fi
}
do_quicksilver() {
	chroot /localroot /usr/sbin/vpd -i RW_VPD -s re_enrollment_key=$(chroot /localroot /usr/bin/openssl rand -hex 32) > /dev/null 2>&1
}
undo_quicksilver() {
	chroot /localroot /usr/sbin/vpd -i RW_VPD -d re_enrollment_key > /dev/null 2>&1
}
get_internal() {
	local ROOTDEV_LIST=$(cgpt find -t rootfs)
	if [ -z "$ROOTDEV_LIST" ]; then
		fail "could not parse for rootdev devices. this should not have happened."
	fi
	local device_type=$(echo "$ROOTDEV_LIST" | grep -oE 'blk0|blk1|nvme|sda' | head -n 1)
	case $device_type in
	"blk0")
		intdis=/dev/mmcblk0
  		intdis_prefix="p"
		break
		;;
	"blk1")
		intdis=/dev/mmcblk1
			intdis_prefix="p"
		break
		;;
	"nvme")
		intdis=/dev/nvme0
  		intdis_prefix="n"
		break
		;;
	"sda")
		intdis=/dev/sda
  		intdis_prefix=""
		break
		;;
	*)
		fail "an unknown error occured. this should not have happened."
		;;
	esac
}

get_internal
prep_quicksilver
if [ $quicksilver = true ]; then
	read -p "Quicksilver is ENABLED. Would you like to disable it? (y/n)" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		undo_quicksilver
	fi
else
	read -p "Quicksilver is DISABLED. Would you like to enable it? (y/n)" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		do_quicksilver
	fi
fi
