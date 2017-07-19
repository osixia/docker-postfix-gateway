#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# postfix
ln -sf ${CONTAINER_SERVICE_DIR}/postfix/assets/config/* /etc/postfix/

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-postfix-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # postfix port
  sed -i "s|{{ POSTFIX_GATEWAY_SMTP_PORT }}|${POSTFIX_GATEWAY_SMTP_PORT}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/master.cf

  # set mailserver hostname
  sed -i "s|{{ HOSTNAME }}|${HOSTNAME}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf

  # mynetworks
  sed -i "s|{{ POSTFIX_GATEWAY_MYNETWORKS }}|${POSTFIX_GATEWAY_MYNETWORKS}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf

  # smtp bind address
  sed -i "s|{{ POSTFIX_GATEWAY_SMTP_BIND_ADDRESS }}|${POSTFIX_GATEWAY_SMTP_BIND_ADDRESS}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf

  # generate a certificate and key if files don't exists
  # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/assets/tool/ssl-helper
  ssl-helper ${POSTFIX_GATEWAY_SSL_HELPER_PREFIX} "${CONTAINER_SERVICE_DIR}/postfix/assets/certs/$POSTFIX_GATEWAY_SSL_CRT_FILENAME" "${CONTAINER_SERVICE_DIR}/postfix/assets/certs/$POSTFIX_GATEWAY_SSL_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/postfix/assets/certs/$POSTFIX_GATEWAY_SSL_CA_CRT_FILENAME"

  POSTFIX_GATEWAY_SSL_CA_CRT_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${POSTFIX_GATEWAY_SSL_CA_CRT_FILENAME}"
  POSTFIX_GATEWAY_SSL_CRT_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${POSTFIX_GATEWAY_SSL_CRT_FILENAME}"
  POSTFIX_GATEWAY_SSL_KEY_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${POSTFIX_GATEWAY_SSL_KEY_FILENAME}"

  # adapt tls config
  sed -i "s|{{ POSTFIX_GATEWAY_SSL_CA_CRT_PATH }}|${POSTFIX_GATEWAY_SSL_CA_CRT_PATH}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf
  sed -i "s|{{ POSTFIX_GATEWAY_SSL_CRT_PATH }}|${POSTFIX_GATEWAY_SSL_CRT_PATH}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf
  sed -i "s|{{ POSTFIX_GATEWAY_SSL_KEY_PATH }}|${POSTFIX_GATEWAY_SSL_KEY_PATH}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf

  POSTFIX_GATEWAY_SSL_DHPARAM_512_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${POSTFIX_GATEWAY_SSL_DHPARAM_512}"
  POSTFIX_GATEWAY_SSL_DHPARAM_1024_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${POSTFIX_GATEWAY_SSL_DHPARAM_1024}"

  [ -f ${POSTFIX_GATEWAY_SSL_DHPARAM_512_PATH} ] || openssl dhparam -out ${POSTFIX_GATEWAY_SSL_DHPARAM_512_PATH} 512
  [ -f ${POSTFIX_GATEWAY_SSL_DHPARAM_1024_PATH} ] || openssl dhparam -out ${POSTFIX_GATEWAY_SSL_DHPARAM_1024_PATH} 1024

  sed -i "s|{{ POSTFIX_GATEWAY_SSL_DHPARAM_512_PATH }}|${POSTFIX_GATEWAY_SSL_DHPARAM_512_PATH}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf
  sed -i "s|{{ POSTFIX_GATEWAY_SSL_DHPARAM_1024_PATH }}|${POSTFIX_GATEWAY_SSL_DHPARAM_1024_PATH}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf


  if [ "${POSTFIX_GATEWAY_LOG_TO_STDOUT,,}" == "true" ]; then
    touch /var/log/mail.log
    ln -sf /proc/1/fd/1 /var/log/mail.log
  fi

  touch $FIRST_START_DONE
fi

# prevent fatal: unknown service: smtp/tcp
# http://serverfault.com/questions/655116/postfix-fails-to-send-mail-with-fatal-unknown-service-smtp-tcp
cp -f /etc/services /var/spool/postfix/etc/services

# copy dns settings to chroot jail
cp -f /etc/resolv.conf /var/spool/postfix/etc/resolv.conf

# fix files permissions
chmod 644 /etc/postfix/*.cf
chmod 644 ${CONTAINER_SERVICE_DIR}/postfix/assets/config/*.cf

exit 0
