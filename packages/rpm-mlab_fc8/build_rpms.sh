#!/bin/bash

set -o nounset
set -o errexit

# globals
dont_prompt_use_default='n'

function prompt_yn()
# $1 is prompt
# $2 is default (Y|N)
{
    ([[ ! -z ${1:-} ]] && [[ ! -z ${2:-} ]]) || \
            (echo "prompt_yn requires 2 arguments." && exit 1)

    local response=''
    local prompt="$1"
    local default="$( echo $2 | tr '[A-Z]' '[a-z]' )"

    if [ "$dont_prompt_use_default" = 'y' ]; then
        response="$default"
    else
        if [[ $default == 'y' ]]; then
            prompt="$prompt [Y/n] "
        else
            prompt="$prompt [y/N] "
        fi
        read -e -p "$prompt" response
        if [[ -z $response ]]; then
            response="$default"
        fi
    fi
    response="$( echo $response | tr '[A-Z]' '[a-z]' )"
    if [[ $response == 'y' ]]; then
        return 0
    else
        return 1
    fi
}

function check_cmd()
# $1 is command to look for
# $2 (optional) is package to install if not found
{
    [[ ! -z ${1:-} ]] || \
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

function rpmlint_specs()
# $1, if set, this function will prompt to continue or exit (and use a pager)
{
    [ ! -z ${1:-} ] && prompt="y" || prompt="n"
    rpmlint_generic 'rpmlint_specs' $rpmbuild_specs 'spec' $prompt
}

function rpmlint_rpms()
# $1, if set, this function will prompt to continue or exit (and use a pager)
{
    [ ! -z ${1:-} ] && prompt="y" || prompt="n"
    rpmlint_generic 'rpmlint_rpms' $rpmbuild_rpms 'rpm' $prompt
}

function rpmlint_generic()
# $1 is the calling function name
# $2 is the directory to search
# $3 is the extension to search for
# $4 if set, prompt the user to continue and use a pager
{
    [ ! -z ${2:-} ] || \
            (echo "$1 requires at least 1 argument." && exit 1)
    ([ ! -z ${4:-} ] && [ "$4" = "y" ] && prompt="y") || prompt="n"

    check_cmd 'find' 'findutils'
    check_cmd 'xargs' 'findutils'
    check_cmd 'rpmlint' 'rpmlint'
    rpmlint_cmd="find $2 -name *.$3"
    if [[ $prompt = 'y' ]]; then
        $rpmlint_cmd | xargs rpmlint | less
        prompt_yn "Continue?" "Y" || exit 0
    else
        $rpmlint_cmd | xargs rpmlint
    fi
}

function setup_rpmvars()
{
    rpmbuild_topdir=$(rpm --eval '%{_topdir}')
    rpmbuild_sources=$(rpm --eval '%{_sourcedir}')
    rpmbuild_specs=$(rpm --eval '%{_specdir}')
    rpmbuild_rpms=$(rpm --eval '%{_rpmdir}')
    rpmbuild_srpms=$(rpm --eval '%{_srcrpmdir}')
}

function clean_and_setup()
{
    check_cmd 'rpmdev-setuptree' 'rpmdevtools'
    check_cmd 'rpmdev-wipetree' 'rpmdevtools'

    # confirm rpmdev-wipetree if $HOME/rpmbuild already exists
    if [[ "$(dirname $(rpm --eval '%{_topdir}'))" == "$HOME" ]]; then
        prompt_yn "This will destroy the contents of '$(dirname $(rpm --eval '%{_topdir}'))'. Do you want to continue?" "N" || exit 2
    else
        rpmdev-setuptree
        echo "Setting up rpmbuild directory..."
    fi
    setup_rpmvars
    rm "$rpmbuild_topdir/.setup_done"
    rpmdev-wipetree
    echo "Cleaning rpmbuild directory..."

    # symlink spec files from repo into %{_specdir}
    echo "Symlinking .spec files from repository..."
    for specdir in $(find $abspath -mindepth 1 -maxdepth 1 -type d)
    do
        pkg=$(basename $specdir)
        if [[ -e "$specdir/$pkg.spec" ]]; then
            ln -s -f "$specdir/$pkg.spec" "$rpmbuild_specs"
            echo "    $pkg.spec"
        fi
    done
    touch "$rpmbuild_topdir/.setup_done"
    echo "Setup done."
}

function get_sources()
{
    # symlink local source/patch files from repo into %{_sourcedir}
    echo "Symlinking local source & patch files from repository..."
    for specdir in $(find $abspath -mindepth 1 -maxdepth 1 -type d)
    do
        pkg=$(basename $specdir)
        if [[ -e "$specdir/$pkg.spec" ]]; then
            for srcfile in $(find $specdir \
                    -mindepth 1 -maxdepth 1 ! -name $pkg.spec)
            do
                cp -f -a "$srcfile" "$rpmbuild_sources"
            done
        fi
    done

    # copy bismark-mserver source from repo directory into %{_sourcedir}
    cd $abspath/../../
    tar cz bismark-mserver > $rpmbuild_sources/bismark-mserver.tar.gz

    # get sources indicated in specfiles
    echo "Downloading remote source files..."
    specfiles=$(find $rpmbuild_specs -mindepth 1 -maxdepth 1 -name *.spec)
    for specfile in $specfiles
    do
        spectool --get-files --directory $rpmbuild_sources $specfile
    done
    echo "Got all sources."
}

function build_bismarkmserver_only()
{
    # copy bismark-mserver source from repo directory into %{_sourcedir}
    cd $abspath/../../
    tar cz bismark-mserver > $rpmbuild_sources/bismark-mserver.tar.gz

    # clean build dirs for specific package
    rm -rf "$rpmbuild_rpms"/bismark-mserver*
    rm -rf "$rpmbuild_srpms"/bismark-mserver*

    rpmbuild -ba $rpmbuild_specs/bismark-mserver.spec
}


function build_all()
{
    # clean build dirs
    rm -rf "$rpmbuild_rpms"/*
    rm -rf "$rpmbuild_srpms"/*

    # build RPMs
    specfiles=$(find $rpmbuild_specs -mindepth 1 -maxdepth 1 -name *.spec)
    for specfile in $specfiles
    do
        rpmbuild -ba $specfile
    done
}

function compile_repo()
{
    check_cmd 'find' 'findutils'
    check_cmd 'xargs' 'findutils'
    check_cmd 'rpmlint' 'rpmlint'
    # sign packages?
    sign_rpms=false
    if [[ "$(rpm --eval '%_gpg_name')" != "%_gpg_name" ]] && \
            prompt_yn "Sign RPMs with GPG?" "Y"; then
        find $rpmbuild_rpms $rpmbuild_srpms -name *.rpm | xargs rpm --addsign
        sign_rpms=true
    fi

    # start creating web repository
    webdir="$rpmbuild_topdir/www/mlab_fedora/fc8/"
    rm -rf "$rpmbuild_topdir"/www/*

    # copy RPMs & make repodata
    mkdir -p "$webdir/i386"
    find "$rpmbuild_rpms/i386/" -mindepth 1 -maxdepth 1 ! -name '*-debuginfo-*' \
            -exec cp '{}' "$webdir/i386/" \;
    cp -a "$rpmbuild_rpms/noarch/"*.rpm "$webdir/i386/"
    createrepo -o "$webdir/i386" -v -d "$webdir/i386"
    $sign_rpms && gpg -a --detach-sign "$webdir/i386/repodata/repomd.xml"

    # copy debuginfo RPMs & make repodata
    mkdir -p "$webdir/i386/debug"
    find "$rpmbuild_rpms/i386/" -mindepth 1 -maxdepth 1 -name '*-debuginfo-*' \
            -exec cp '{}' "$webdir/i386/debug/" \;
    createrepo -o "$webdir/i386/debug" -v -d "$webdir/i386/debug"
    $sign_rpms && gpg -a --detach-sign "$webdir/i386/debug/repodata/repomd.xml"

    # copy SRPMs & make repodata
    mkdir -p "$webdir/source/SRPMS"
    cp -a "$rpmbuild_srpms"/*.src.rpm "$webdir/source/SRPMS/"
    createrepo -o "$webdir/source/SRPMS" -v -d "$webdir/source/SRPMS"
    $sign_rpms && gpg -a --detach-sign "$webdir/source/SRPMS/repodata/repomd.xml"

    # export GPG key
    $sign_rpms && gpg --export --armor > "$webdir/RPM-GPG-KEY-bismark"
}

function upload()
{
    webdir="$rpmbuild_topdir/www/mlab_fedora/fc8/"
    ssh woodrow@beachmont.noise.gatech.edu \
        "rm -rf ~/bismark-mserver/mlab_fedora/*"
    scp -r "$webdir" \
        woodrow@beachmont.noise.gatech.edu:~/bismark-mserver/mlab_fedora/
}

function usage()
{
    echo "USAGE: $0 command"
    echo "where command is one of:"
    echo "  clean         delete contents of rpmbuild directory"
    echo "  speclint      run rpmlint on .spec files"
    echo "  updatesource  download source files specified in spec files"
    echo "  build         build all packages"
    echo "  bismark       build bismark-mserver package only"
    echo "  rpmlint       run rpmlint on .rpm files"
    echo "  makerepo      compile repository (with or without GPG signing)"
    echo "  upload        upload repository to HTTP server"
    echo "  all           run all steps in order, with prompts"
    echo "  most          updatesource, build, makerepo, upload"
    exit 2
}

function main()
{
    # determine absolute path to this script (won't work if called through $PATH)
    relpath=$(dirname "$0")
    abspath="$PWD/$relpath"

    # check for essential commands and packages
    check_cmd 'rpm' 'rpm'

    # confirm rpmdev-setuptree in $HOME
    if [[ "$USER" != 'makerpm' ]] &&
            [[ "$(dirname $(rpm --eval '%{_topdir}'))" != "$HOME" ]]; then
        prompt_yn "User '$USER' doesn't look like a build account.
                   Are you sure you want to set up an rpmbuild directory in this
                   user's home directory?" "N" || exit 2
    fi

    if [ "$(dirname $(rpm --eval '%{_topdir}'))" != "$HOME" ] || \
            [ ! -f "$(rpm --eval '%{_topdir}')/.setup_done" ]; then
        clean_and_setup
    fi

    if [ -z ${1:-} ]; then
        usage
    fi

    setup_rpmvars

    case "$1" in
    clean)
        clean_and_setup
        ;;
    speclint)
        rpmlint_specs
        ;;
    updatesource)
        get_sources
        ;;
    build)
        build_all
        ;;
    bismark)
        build_bismarkmserver_only
        ;;
    rpmlint)
        rpmlint_rpms
        ;;
    makerepo)
        compile_repo
        ;;
    upload)
        upload
        ;;
    all)
        prompt_yn "Clean build directory [clean]?" "Y" && \
                clean_and_setup
        prompt_yn "Run rpmlint on spec files [speclint]?" "Y" && \
                rpmlint_specs 'y'
        prompt_yn "Download source files [updatesource]?" "Y" && \
                get_sources
        prompt_yn "Build packages [build]?" "Y" && \
                build_all
        prompt_yn "Run rpmlint on rpm packages [rpmlint]?" "Y" && \
                rpmlint_rpms 'y'
        prompt_yn "Compile packages into repository [makerepo]?" "Y" && \
                compile_repo
        prompt_yn "Upload to repository server [upload]?" "Y" && \
                upload
        ;;
    most)
        get_sources
        build_all
        compile_repo
        upload
        ;;
    *)
        usage
    esac
}

if [ ! -z ${1:-} ]; then
    main $1
else
    main
fi
