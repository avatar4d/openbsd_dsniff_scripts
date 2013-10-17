#!/bin/ksh

#VARIABLES
  CMD=$@
##Logs
  LOGDIR=/var/log/dsniff
  DSNIFF_LOG=dsniff
  MAILSNARF_LOG=mailsnarf
  MSGSNARF_LOG=msgsnarf
  URLSNARF_LOG=urlsnarf
##App Flags
##CHANGE THESE TO WHATEVER IS APPROPRIATE FOR YOU
  DSNIFF_FLAGS="not host youtube.com"
  URLSNARF_FLAGS=""
  INTERFACE=vr0 


#FUNCTIONS
die(){
#
#Kills each app if it is running
#
## Make cleaner with a for loop
  if [ -n `pgrep dsniff` ];
  then
    pkill dsniff
  fi

  if [ -n `pgrep mailsnarf` ];
  then
    pkill mailsnarf
  fi

  if [ -n `pgrep urlsnarf` ];
  then
    pkill urlsnarf
  fi

  if [ -n `pgrep msgsnarf` ];
  then
    pkill msgsnarf
  fi
}

logrotate(){
#
#This checks for each application's log, checks if it is 50MB or more.
#It then proceeds to rotate the compressed archives (it keeps 5) and
#compresses the current log after renaming it.
#
for LOG in [[ $DSNIFF_LOG $MAILSNARF_LOG $MSGSNARF_LOG $URLSNARF_LOG ]]; 
do
  if [[ -e $LOGDIR/$LOG && `ls -la $LOGDIR/$LOG | awk '{print $5}'` -ge 52428800 ]];
  then
##Make the following repetatives cleaner with a for loop
    if [ -e $LOGDIR/$LOG.4.gz ];
    then
      mv $LOGDIR/$LOG.4.gz $LOGDIR/$LOG.5.gz
    fi

    if [[ -e $LOGDIR/$LOG.3.gz ]];
    then
      mv $LOGDIR/$LOG.3.gz $LOGDIR/$LOG.4.gz
    fi

    if [[ -e $LOGDIR/$LOG.2.gz ]];
    then
      mv $LOGDIR/$LOG.2.gz $LOGDIR/$LOG.3.gz
    fi

    if [[ -e $LOGDIR/$LOG.1.gz ]];
    then
      mv $LOGDIR/$LOG.1.gz $LOGDIR/$LOG.2.gz
    fi

    mv $LOGDIR/$LOG $LOGDIR/$LOG.1
    gzip -o $LOGDIR/$LOG.1.gz $LOGDIR/$LOG.1 & 

  fi
done
}

start(){
#
#Starts each application with any necessary flags (configured in the VARIABLES section above)
#
/usr/local/sbin/dsniff -i $INTERFACE -m -w $LOGDIR/$DSNIFF_LOG $DSNIFF_FLAGS &
/usr/local/sbin/mailsnarf -i $INTERFACE >> $LOGDIR/$MAILSNARF_LOG &
/usr/local/sbin/msgsnarf -i $INTERFACE >> $LOGDIR/$MSGSNARF_LOG &
/usr/local/sbin/urlsnarf -i $INTERFACE >> $LOGDIR/$URLSNARF_LOG $URLSNARF_FLAGS &
}

#EXECUTION
case $CMD in 
start)
  logrotate
  start
  ;;

stop)
  die
  ;;

restart)
  shutdown
  logrotate
  start
  ;;
esac
