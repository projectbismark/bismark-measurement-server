#!/bin/bash

set -o nounset
set -e errexit

function prompt_yn() # $1 is prompt, $2 is default (Y|N)
{
    ([[ ! -z ${1:-} ]] && [[ ! -z ${2:-} ]]) || \
            (echo "prompt_yn requires 2 arguments." && exit 1)

    local response=''
    local prompt="$1"
    local default="$( echo $2 | tr '[A-Z]' '[a-z]' )"

    echo -n $1
    if [[ $default == 'y' ]]; then
        echo " [Y/n]"
    else
        echo " [y/N]"
    fi

    read -e response
    if [[ -z $response ]]; then
        response="$default"
    fi
    response="$( echo $response | tr '[A-Z]' '[a-z]' )"
    if [[ $response == 'y' ]]; then
        return 0
    else
        return 1
    fi
}

function check_cmd()
{
    [[ ! -z ${1:-} ]] ||
            (echo "check_cmd requires at least 1 argument." && exit 1)

    local cmd="$1"
    local pkg="${2:-}"

    if ! $(which $cmd &> /dev/null); then
        if [[ -z "$pkg" ]]; then
            echo "Command '$cmd' not found."
        else
            echo "Command '$cmd' not found; install '$pkg' package."
        fi
        exit 1
    fi
}

check_cmd 'rpm' 'rpm'
check_cmd 'rpmdev-setuptree' 'rpmdevtools'

rpmbuild_topdir=$(rpm --eval '%topdir')

if [[ "$USER" != 'makerpm' ]] &&
        [[ "$(dirname $rpmbuild_topdir)" != "$HOME" ]]; then
    prompt_yn "User '$USER' doesn't look like a build account.
               Are you sure you want to set up an rpmbuild directory in this
               user's home directory?" "N" || exit 1
fi
if [[ "$(dirname $rpmbuild_topdir)" == "$HOME" ]]; then
    prompt_yn "This will destroy the contents of '$topdir'.
               Do you want to continue?" "N" || exit 0
fi

rpmdev-setuptree
rpmdev-wipetree

rpmbuild_topdir=$(rpm --eval '%topdir')
rpmbuild_sources=$(rpm --eval '%sourcedir')
rpmbuild_specs=$(rpm --eval '%specdir')

for specdir in $(find ./ -mindepth 1 -maxdepth 1 -type d)
do
    pkg=$(basename $specdir)
    #ln -s "$specdir/$pkg.spec" "$rpmbuild_specs"
    echo "ln -s" "$specdir/$pkg.spec" "$rpmbuild_specs"
    for srcfile in $(find $specdir -mindepth 1 -maxdepth 1 ! -name $pkg.spec)
    do
        #cp -a "$srcfile" "$rpmbuild_sources"
        echo "cp -a" "$srcfile" "$rpmbuild_sources"
    done
done

specfiles=$(find $rpmbuild_specs -mindepth 1 -maxdepth 1 -name *.spec)

for specfile in $specfiles
do
    #spectool --get-files --directory $rpmbuild_sources $specfile
    echo "spectool --get-files --directory $rpmbuild_sources $specfile"
done

for specfile in $specfiles
do
    #rpmbuild -ba $specfile
    echo "rpmbuild -ba $specfile"
done
