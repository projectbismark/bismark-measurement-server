#!/bin/bash
# File Name:     restart-puppetd.sh
# Author:        Ryan Uber <ryan@blankbmx.com>
#
# Description:   This script is a hack! However, it solves a very important
#                issue with puppet. Normally, if you subscribe the puppet
#                service to the puppet.conf file, the puppet service will
#                be restarted too soon, interrupting the current puppet
#                run. Various attempts at using configure_delayed_restart
#                among other things have not proven to be 100% effective.
#                This script will watch the puppetdlock file, which can
#                determine whether or not there is a run in progress. If
#                there is a run in progress, we sleep for a second and then
#                test again until the process is unlocked. Once unlocked, we
#                can safely call a puppet restart. The checker process
#                itself gets forked into the background. If it were not
#                forked into the background, the puppet run would sit and
#                wait for the process to return, or for the exec timeout,
#                whichever came first. This would cause serious trouble if
#                timeouts were disabled or very long periods of time.
#
# Source URL:    http://www.ryanuber.com/puppet-self-management.html

# Begin waiting for the current puppet run to finish, then restart.
/bin/sh -c "
    until [ ! -f /var/lib/puppet/state/puppetdlock ]
    do
        sleep 1
    done
    /sbin/service puppet restart" &

# Always return true, since this script just forks another process.
exit 0

# EOF

