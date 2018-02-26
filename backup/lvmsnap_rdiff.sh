#!/bin/bash
umount /mnt/backup-to-prit

mount -t nfs 10.250.20.211:/volume1/backups /mnt/backup-to-prit

lvcreate -L2G -s -p r -n snaps /dev/1404Template-vg/root

mkdir /mnt/snaps
mount /dev/1404Template-vg/snaps /mnt/snaps

cd /mnt/snaps

rdiff-backup -v 4 var/www/moodle /mnt/backup-to-prit/moodle30/moodle
rdiff-backup -v 4 var/www/gappskeys /mnt/backup-to-prit/moodle30/gappskeys

rdiff-backup -v 4 etc/apache2/sites-available /mnt/backup-to-prit/moodle30/sites-available

rdiff-backup -v 4 --force var/moodledata /mnt/backup-to-prit/moodle30/moodledata

umount /mnt/backup-to-prit

cd /

umount /mnt/snaps
lvremove -f /dev/1404Template-vg/snaps

