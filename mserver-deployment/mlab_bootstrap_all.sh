#!/bin/sh

set -o nounset
set -o errexit

usage() {
    echo "USAGE: $0 mlab_hosts_file"
    echo "       mlab_hosts_file is a list of hosts to bootstrap, one per"
    echo "       line. Lines with a any amount of whitespace, follwed by a"
    echo "       leading # are ignored."
    echo ""
    echo "       NOTE: This bootstrapping operation will delete any existing"
    echo "       puppet certificates on the target hosts -- use with caution."
    exit 1
}

if [ -z ${1:-} ]; then
    usage
fi
cat $1 | grep -vP "^\s*#" | xargs -n 1 -I{} \
        ./bootstrap_single_mlab_node.sh {} --new-cert
