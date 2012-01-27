#!/bin/bash

set -o nounset
set -o errexit

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

# globals

rebuild='y'

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
    if [[ ! -z ${1:-} ]] && [[ "$1" == "--norebuild" ]]; then
        rebuild='n'
    else
        prompt_yn "This will destroy the contents of '$rpmbuild_topdir'.
                   Do you want to continue?" "N" || exit 2
    fi
fi
# sign packages?
rpmbuild_sign=''
if [[ "$(rpm --eval '%_gpg_name')" != "%_gpg_name" ]] && \
        prompt_yn "Sign RPMs with GPG?" "Y"; then
    rpmbuild_sign='--sign'
fi

if [[ "$rebuild" == 'y' ]]; then
    rpmdev-setuptree
fi

rpmbuild_topdir=$(rpm --eval '%{_topdir}')
rpmbuild_sources=$(rpm --eval '%{_sourcedir}')
rpmbuild_specs=$(rpm --eval '%{_specdir}')
rpmbuild_rpms=$(rpm --eval '%{_rpmdir}')
rpmbuild_srpms=$(rpm --eval '%{_srcrpmdir}')

if [[ "$rebuild" == 'y' ]]; then
    rpmdev-wipetree
else
    # partially clean
    rm -rf "$rpmbuild_rpms"/*
    rm -rf "$rpmbuild_srpms"/*
fi

# symlink spec files from repo into %{_specdir}
for specdir in $(find $abspath -mindepth 1 -maxdepth 1 -type d)
do
    pkg=$(basename $specdir)
    if [[ -e "$specdir/$pkg.spec" ]]; then
        ln -s -f "$specdir/$pkg.spec" "$rpmbuild_specs"
        for srcfile in $(find $specdir \
                -mindepth 1 -maxdepth 1 ! -name $pkg.spec)
        do
            cp -f -a "$srcfile" "$rpmbuild_sources"
        done
    fi
done

specfiles=$(find $rpmbuild_specs -mindepth 1 -maxdepth 1 -name *.spec)

if [[ "$rebuild" == 'y' ]]; then
    # get sources indicated in specfiles
    for specfile in $specfiles
    do
        spectool --get-files --directory $rpmbuild_sources $specfile
    done
fi

# copy bismark-mserver source from repo directory into %{_sourcedir}
cd $abspath/../../
tar cz bismark-mserver > $rpmbuild_sources/bismark-mserver.tar.gz

# build RPMs
for specfile in $specfiles
do
    rpmbuild $rpmbuild_sign -ba $specfile
done

# start creating web repository
webdir="$rpmbuild_topdir/www/mlab_fedora/fc8/"
rm -rf "$rpmbuild_topdir"/www/*

# copy RPMs & make repodata
mkdir -p "$webdir/i386"
find "$rpmbuild_rpms/i386/" -mindepth 1 -maxdepth 1 ! -name '*-debuginfo-*' \
        -exec cp '{}' "$webdir/i386/" \;
cp -a "$rpmbuild_rpms/noarch/"*.rpm "$webdir/i386/"
createrepo -o "$webdir/i386" -v -d "$webdir/i386"

# copy debuginfo RPMs & make repodata
mkdir -p "$webdir/i386/debug"
find "$rpmbuild_rpms/i386/" -mindepth 1 -maxdepth 1 -name '*-debuginfo-*' \
        -exec cp '{}' "$webdir/i386/debug/" \;
createrepo -o "$webdir/i386/debug" -v -d "$webdir/i386/debug"

# copy SRPMs & make repodata
mkdir -p "$webdir/source/SRPMS"
cp -a "$rpmbuild_srpms"/*.src.rpm "$webdir/source/SRPMS/"
createrepo -o "$webdir/source/SRPMS" -v -d "$webdir/source/SRPMS"

# export GPG key
gpg --export --armor > "$webdir/RPM-GPG-KEY-bismark"

if prompt_yn "Upload repository to beachmont?" "Y"; then
    ssh woodrow@beachmont.noise.gatech.edu \
        rm -rf ~/bismark-mserver/mlab_fedora/*
    scp -r "$webdir" \
        woodrow@beachmont.noise.gatech.edu:~/bismark-mserver/mlab_fedora/
fi
