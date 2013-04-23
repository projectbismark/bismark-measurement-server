#!/bin/sh

set -o nounset
set -o errexit

usage() {
    echo "USAGE: $0 mlab_hostname [--new-cert]"
    echo "  --new-cert    deletes /etc/puppet/ssl on the target host, if"
    echo "                present, before starting the bootstrap process"
    exit 1
}

if [ -z ${1:-} ]; then
    usage
fi

new_cert_line=''
if [ ! -z ${2:-} ]; then
    if [ "$2" = '--new-cert' ]; then
        new_cert_line="sudo rm -rf /etc/puppet/ssl/;"
    else
        usage
    fi
fi

ssh $1 "wget https://raw.github.com/projectbismark/bismark-measurement-server/master/puppet/puppet-bootstrap-mlab_el6.sh;" \
       "chmod +x puppet-bootstrap-mlab_el6.sh;" \
       "$new_cert_line" \
       "./puppet-bootstrap-mlab_el6.sh;" \
       "rm puppet-bootstrap-mlab_el6.sh;"
