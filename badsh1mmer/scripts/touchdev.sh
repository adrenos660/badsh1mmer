#!/bin/sh
get_internal() {
  # get_largest_cros_blockdev does not work in BadApple.
  local ROOTDEV_LIST=$(cgpt find -t rootfs) # thanks stella
  if [ -z "$ROOTDEV_LIST" ]; then
    fail "could not parse for rootdev devices. this should not have happened."
  fi
  local device_type=$(echo "$ROOTDEV_LIST" | grep -oE 'blk0|blk1||nvme|sda' | head -n 1)
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
mountlvm(){
     vgchange -ay #active all volume groups
     volgroup=$(vgscan | grep "Found volume group" | awk '{print $4}' | tr -d '"')
     echo "found volume group:  $volgroup"
     mount "/dev/$volgroup/unencrypted" /stateful || fail "couldnt mount p1 or lvm group.  Please recover"
}
get_internal
mount "$intdis$intdis_prefix"1 /stateful || mountlvm
touch /stateful/.developer_mode
umount /stateful
echo "5 minute wait skipped"
sleep 2
