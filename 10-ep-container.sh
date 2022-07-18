#!/bin/ash
#
# Launch the podman service/process if not previously launched. If parameters are not provided
# launch as a process. If parameters provided fork the podman as a service.

RETURN_VALUE=0
echo "---------- [ ACME(certbot) ] ----------"
if [ -z "$ENTRYPOINT_PARAMS" ] ; then
   TEST="$(/usr/bin/pgrep /usr/sbin/crond)"
 if [ $? -eq 0 ] ; then
   /usr/bin/sudo /usr/bin/killall crond
 fi
 /usr/bin/sudo /usr/sbin/crond -f -l 8
 unset TEST
fi
unset ENTRYPOINT_PARAM
return $RETURN_VALUE
