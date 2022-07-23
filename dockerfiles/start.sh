#!/bin/sh
/home/pi/pialert/dockerfiles/user-mapping.sh

# if custom variables not set we do not need to do anything
if [ -n "${TZ}" ]; then  
  sed -ie "s|Europe/London|${TZ}|g" /home/pi/pialert/install/pialert.cron   
  crontab < /home/pi/pialert/install/pialert.cron
fi
if [ -n "${PORT}" ]; then  
  sed -ie 's/= 20211/= '${PORT}'/g' /etc/lighttpd/lighttpd.conf 
fi

/etc/init.d/lighttpd start
cron -f