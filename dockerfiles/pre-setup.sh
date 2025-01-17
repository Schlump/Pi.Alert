#!/bin/bash

export INSTALL_DIR=/home/pi

# php-fpm setup
install -d -o nginx -g www-data /run/php/
sed -i "/^;pid/c\pid = /run/php/php8.2-fpm.pid" /etc/php82/php-fpm.conf
sed -i "/^listen/c\listen = /run/php/php8.2-fpm.sock" /etc/php82/php-fpm.d/www.conf
sed -i "/^;listen.owner/c\listen.owner = nginx" /etc/php82/php-fpm.d/www.conf
sed -i "/^;listen.group/c\listen.group = www-data" /etc/php82/php-fpm.d/www.conf
sed -i "/^user/c\user = nginx" /etc/php82/php-fpm.d/www.conf
sed -i "/^group/c\group = www-data" /etc/php82/php-fpm.d/www.conf

# s6 overlay setup
mkdir -p /etc/s6-overlay/s6-rc.d/{SetupOneshot,php-fpm/dependencies.d,nginx/dependencies.d}
mkdir -p /etc/s6-overlay/s6-rc.d/{SetupOneshot,php-fpm/dependencies.d,nginx/dependencies.d,pialert/dependencies.d}
echo "oneshot" > /etc/s6-overlay/s6-rc.d/SetupOneshot/type
echo "longrun" > /etc/s6-overlay/s6-rc.d/php-fpm/type
echo "longrun" > /etc/s6-overlay/s6-rc.d/nginx/type
echo "longrun" > /etc/s6-overlay/s6-rc.d/pialert/type
echo -e "${INSTALL_DIR}/pialert/dockerfiles/setup.sh" > /etc/s6-overlay/s6-rc.d/SetupOneshot/up
echo -e "#!/bin/execlineb -P\n/usr/sbin/php-fpm82 -F" > /etc/s6-overlay/s6-rc.d/php-fpm/run
echo -e '#!/bin/execlineb -P\nnginx -g "daemon off;"' > /etc/s6-overlay/s6-rc.d/nginx/run
echo -e '#!/bin/execlineb -P\n\nwith-contenv\nimportas -i PORT PORT\nif { echo "[INSTALL] 🚀 Starting app - navigate to your <server IP>:${PORT}" }' > /etc/s6-overlay/s6-rc.d/pialert/run
echo -e "python ${INSTALL_DIR}/pialert/pialert" >> /etc/s6-overlay/s6-rc.d/pialert/run
touch /etc/s6-overlay/s6-rc.d/user/contents.d/{SetupOneshot,php-fpm,nginx} /etc/s6-overlay/s6-rc.d/{php-fpm,nginx}/dependencies.d/SetupOneshot
touch /etc/s6-overlay/s6-rc.d/user/contents.d/{SetupOneshot,php-fpm,nginx,pialert} /etc/s6-overlay/s6-rc.d/{php-fpm,nginx,pialert}/dependencies.d/SetupOneshot
touch /etc/s6-overlay/s6-rc.d/nginx/dependencies.d/php-fpm
touch /etc/s6-overlay/s6-rc.d/pialert/dependencies.d/nginx

rm -f $0
