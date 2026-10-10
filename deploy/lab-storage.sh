#!/usr/bin/env bash
set -euo pipefail

MD_UUID=18f02013:7d03b8ea:04340b51:2d8216fb
RAID_FS_UUID=829ee9cd-0985-4750-96e2-08ae050b014e
LOG_FS_UUID=e86159e3-08b1-48a2-8cf4-147e5ed63ba4

for number in 1 2 3; do
    test -f "/mnt/raid-lab/disk${number}.img"
done

LOOP1=$(losetup --find --show --nooverlap /mnt/raid-lab/disk1.img)
LOOP2=$(losetup --find --show --nooverlap /mnt/raid-lab/disk2.img)
losetup --find --show --nooverlap /mnt/raid-lab/disk3.img
udevadm settle

# udev мог уже собрать массив, в том числе под другим именем.
if ! blkid -c /dev/null -U "$RAID_FS_UUID" >/dev/null; then
    if ! mdadm --assemble /dev/md0 --uuid="$MD_UUID" "$LOOP1" "$LOOP2"; then
        udevadm settle
        blkid -c /dev/null -U "$RAID_FS_UUID" >/dev/null
    fi
fi

vgchange -ay vg_data
udevadm settle

mount_volume() {
    local uuid=$1 target=$2
    mkdir -p "$target"

    if mountpoint -q "$target"; then
        if [[ $(findmnt -n -o UUID --mountpoint "$target") != "$uuid" ]]; then
            echo "Unexpected filesystem at $target" >&2
            exit 1
        fi
    else
        mount -U "$uuid" "$target"
    fi
}

mount_volume "$RAID_FS_UUID" /mnt/raid
mount_volume "$LOG_FS_UUID" /mnt/logs
test -d /mnt/logs/my-app
echo "Lab storage is ready"
