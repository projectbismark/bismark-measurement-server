#!/bin/bash

set -o nounset
set -e errexit

function prompt_yn()
# $1 is prompt, $2 is default (Y|N)
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
# $1 is command to look for, $2 (optional) is package to install if not found
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

# determine absolute path to this script (won't work if called through $PATH)
relpath=$(dirname "$0")
abspath="$PWD/$relpath"

# check for essential commands and packages
check_cmd 'rpm' 'rpm'
check_cmd 'rpmdev-setuptree' 'rpmdevtools'

rpmbuild_topdir=$(rpm --eval '%{_topdir}')

# confirm rpmdev-setuptree in $HOME
if [[ "$USER" != 'makerpm' ]] &&
        [[ "$(dirname $rpmbuild_topdir)" != "$HOME" ]]; then
    prompt_yn "User '$USER' doesn't look like a build account.
               Are you sure you want to set up an rpmbuild directory in this
               user's home directory?" "N" || exit 2
fi
# confirm rpmdev-wipetree if $HOME/rpmbuild already exists
if [[ "$(dirname $rpmbuild_topdir)" == "$HOME" ]]; then
    prompt_yn "This will destroy the contents of '$rpmbuild_topdir'.
               Do you want to continue?" "N" || exit 2
fi
# sign packages?
rpmbuild_sign=''
if [[ "$(rpm --eval '%_gpg_name')" != "%_gpg_name" ]] && \
        prompt_yn "Sign RPMs with GPG?" "Y"; then
    rpmbuild_sign='--sign'
fi



rpmdev-setuptree
rpmdev-wipetree

rpmbuild_topdir=$(rpm --eval '%{_topdir}')
rpmbuild_sources=$(rpm --eval '%{_sourcedir}')
rpmbuild_specs=$(rpm --eval '%{_specdir}')

# copy bismark-mserver source from repo directory into %{_sourcedir}
cd $abspath/../../
tar cz bismark-mserver > $rpmbuild_sources/bismark-mserver.tar.gz

# symlink spec files from repo into %{_specdir}
for specdir in $(find $abspath -mindepth 1 -maxdepth 1 -type d)
do
    pkg=$(basename $specdir)
    if [[ -e "$specdir/$pkg.spec" ]]; then
        ln -s "$specdir/$pkg.spec" "$rpmbuild_specs"
        for srcfile in $(find $specdir \
                -mindepth 1 -maxdepth 1 ! -name $pkg.spec)
        do
            cp -a "$srcfile" "$rpmbuild_sources"
        done
    fi
done

specfiles=$(find $rpmbuild_specs -mindepth 1 -maxdepth 1 -name *.spec)

# get sources indicated in specfiles
for specfile in $specfiles
do
    spectool --get-files --directory $rpmbuild_sources $specfile
done

# build RPMs
for specfile in $specfiles
do
    rpmbuild $rpmbuild_sign -ba $specfile
done
