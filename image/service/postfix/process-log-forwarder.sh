#!/bin/sh -e
log-helper level eq trace && set -x

exec tail -F -n 0 /var/log/mail.log > /proc/1/fd/1
