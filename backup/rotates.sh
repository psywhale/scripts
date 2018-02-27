#!/bin/bash

# Backup up Script
# by Brian Carpenter
# 
#see bottom of file for 'main code'


D=`date +%F`
SERVER="test"

VERBOSE=true
#---Hourly-------
HOURLY=true
#24 hour do not pad with zeros 1 2 3 vs 01 02 03
CURHOUR=`date +%-H`
#24 hour format
#ROTATEHOUR=9
KEEPHOURS=4
#---DAILIES-------
KEEPDAILIES=7


#----WEEKLY--------
WEEKLY=true
KEEPWEEKS=4
DAY=`date +%w`
#%w     day of week (0..6); 0 is Sunday
#U M T W R F S
#0 1 2 3 4 5 6
ROTATEWEEK_ONDAY=0
#-----MONTHLY------
MONTHLY=true
ROTATEMONTH_ONDAY=1
KEEPMONTHS=6
DAYOFMONTH=`date +%-d`


#--- functions------

verbose () {
   if [ "$VERBOSE" == true ]; then
      echo $2 "$1"
   fi
}

initializedirs () {
verbose "init backup directories...."
if [ "$HOURLY" == "true" ]; then
   for num in `seq $((KEEPHOURS-1)) -1 0`; do

      if [ ! -d backup/hour/$num ]; then
	 verbose "creating backup/hour/$num"
         mkdir -p backup/hour/$num
      fi
   done
fi
for num in `seq $((KEEPDAILIES-1)) -1 0`; do
   if [ ! -d backup/daily/$num ]; then
      verbose "creating backup/daily/$num"
      mkdir -p backup/daily/$num
   fi
done
if [ "$WEEKLY" == "true" ]; then
   for num in `seq $KEEPWEEKS -1 0`; do

      if [ ! -d backup/week/$num ]; then
	 verbose "creating backup_week.$num"
         mkdir -p backup/week/$num
      fi
   done
fi
if [ "$MONTHLY" == true ]; then
   for num in `seq $KEEPMONTHS -1 0`; do

      if [ ! -d backup/month/$num ]; then
         verbose "creating backup/month/$num"
         mkdir -p backup/month/$num
      fi
   done
fi
}

rotatedaily() {
verbose "rotating dailies [" -n
for num in `seq $((KEEPDAILIES-1)) -1 0`; do
   if [ ! -d backup/daily/$num ]; then
      mkdir backup/daily/$num
   fi
   verbose "$num -> $((num+1))" -n
   if [ "$num" -gt 0 ]; then 
      verbose ", " -n
   fi
   rm -rf ./backup/daily/$((num+1))
   mv backup/daily/$num backup/daily/$((num+1))
done
verbose "]"
}

rotatehourly() {
verbose "rotate hourly [" -n
for num in `seq $((KEEPHOURS-1)) -1 0`; do
     if [ ! -d backup/hour/$num ]; then
        mkdir backup/hour/$num
     fi
     verbose "$num -> $((num+1))" -n
     if [ "$num" -gt 0 ]; then
        verbose ", " -n
     fi
     rm -rf ./backup/hour/$((num+1))
     mv backup/hour/$num backup/hour/$((num+1))
  done
verbose "]"
}

rotatedirs () {
verbose "rotating directories...."
#if rotate day, rotate weeks and/or month

if [ "$MONTHLY" == true ];then
   if [ "$DAYOFMONTH" == "$ROTATEMONTH_ONDAY" ]; then
       verbose "making monthly newest"
       cp -r backup/daily/0/* backup/month/0
       verbose "rotating monthly [" -n
       for num in `seq $((KEEPMONTHS-1)) -1 0`;do
          verbose "$num -> $((num+1))" -n
	  if [ "$num" -gt 0 ]; then 
		verbose ", " -n
	  fi
	  rm -rf ./backup/month/$((num+1))
          mv ./backup/month/$num ./backup/month/$((num+1))
       done
       verbose "]"
   fi
fi
if [ "$WEEKLY" == true ];then
   if [ "$DAY" == "$ROTATEWEEK_ONDAY" ]; then
       verbose "making weekly newest"
       cp -r backup/daily/0/* backup/week/0
       verbose "rotating weekly [" -n
       for num in `seq $((KEEPWEEKS-1)) -1 0`;do
          verbose "$num -> $((num+1))" -n
	  if [ "$num" -gt 0 ]; then 
		verbose ", " -n
	  fi
	  rm -rf ./backup/week/$((num+1))
          mv ./backup/week/$num ./backup/week/$((num+1))
       done
       verbose "]" 
   fi
fi

#rotate hourly
if [ "$HOURLY" == true ];then
      rotatehourly
      rotatedaily
else
   rotatedaily
fi

}




if [ "$HOURLY" == true ]; then
   BACKUPLOC="backup/hour/$CURHOUR"
else
   BACKUPLOC="backup/daily/0"
fi

#------Main code------

mount -t nfs ip:/volume1/backups /mnt

if [ ! -d /mnt/$SERVER ];then
   mkdir /mnt/$SERVER
fi

cd /mnt/$SERVER
initializedirs
#tar zcvf $BACKUPLOC/"$SERVER$D".tar.gz /etc/
innobackupex --parallel=4 --no-timestamp --safe-slave-backup $BACKUPLOC
rotatedirs

cd /

umount /mnt
