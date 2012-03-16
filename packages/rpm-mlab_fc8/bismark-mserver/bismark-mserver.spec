Summary: BISmark Measurement Server
Name: bismark-mserver
Version: 0.1.7
Release: 6%{?dist}
License: GPLv2
Group: Applications/Internet
URL: https://github.com/projectbismark/bismark-measurement-server

Source: bismark-mserver.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildArch: noarch

# bismark-packaged dependencies
Requires: netperf = 2.4.5-1bismark3.fc8
Requires: iperf = 2.0.4-1bismark2.fc8
Requires: ditg = 2.8.0-0bismark4.rc1.fc8
Requires: shaperprobe-server = 0.1-1bismark3.fc8
Requires: socat = 1.7.1.3-1bismark3.fc8
# fedora-packaged dependencies
Requires: traceroute
Requires: iputils
Requires: curl
Requires: binutils
Requires: iproute
Requires: net-tools
Requires: rpm
Requires: grep
Requires: coreutils
Requires: gawk
Requires: sudo
Requires: python
Requires: python-simplejson
# Requires: monit  # save this for later release

Requires(post): chkconfig
Requires(preun): chkconfig, initscripts

# prevent rpmlint errors due to python compilation by brp-python-bytecompile
%define __spec_install_post /usr/lib/rpm/redhat/brp-compress

%description
Sets up a BISmark measurement server capable of sourcing and sinking traffic
for Project BISmark routers.

%prep
%setup -q -n bismark-mserver

%install
%{__rm} -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}
cp -p bin/bismark-mserver* %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_sysconfdir}
cp -p etc/bismark-mserver.conf %{buildroot}%{_sysconfdir}
cp -p etc/hosts.allow.bismark %{buildroot}%{_sysconfdir}
cp -p etc/hosts.deny.bismark %{buildroot}%{_sysconfdir}
mkdir -p %{buildroot}%{_sysconfdir}/cron.d
cp -p etc/cron.d/bismark-mserver %{buildroot}%{_sysconfdir}/cron.d
mkdir -p %{buildroot}%{_initrddir}  # %{_initrddir} is deprecated as of fc10
cp -p etc/init.d/bismark-mserver %{buildroot}%{_initrddir}

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%doc LICENSE README INSTALL.md
%{_bindir}/bismark-mserver*
%config(noreplace) %{_sysconfdir}/bismark-mserver.conf
%config(noreplace) %{_sysconfdir}/hosts.allow.bismark
%config(noreplace) %{_sysconfdir}/hosts.deny.bismark
%config(noreplace) %{_sysconfdir}/cron.d/bismark-mserver
%{_initrddir}/bismark-mserver

%post
/sbin/chkconfig --add %{name}
/sbin/service crond reload

%preun
if [ $1 -eq 0 ]; then
    /sbin/service %{name} stop > /dev/null 2>&1
    /sbin/chkconfig --del %{name}
fi

%postun
if [ $1 -ge 1 ]; then
  /sbin/service %{name} restart >/dev/null 2>&1
fi


%changelog
* Fri Mar 16 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.1.7-6
- Update ditg version to patch infinite loop on connection close bug.
* Mon Mar 05 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.1.7-5
- Add bismark-mserver-iperf_{tcp,udp} wrapper scripts.
- Change config-annotated files to config(noreplace) in spec.
- Depend on patched ditg.
- Depend on updated socat release.
- bismark-mserver-heartbeat tries to include puppet config_version.
- Restart bismark-mserver service on package upgrade.
* Mon Feb 20 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.1.6-1
- Add bismark-mserver-hostsallow to download and construct a hosts.allow file.
- Include default hosts.allow.bismark and hosts.deny.bismark files.
* Tue Jan 31 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.1.4-1
- Start running mserver daemon processes as an unprivileged user.
- Update config variables and fix error in use of socat timeout variable.
- Increase heartbeat frequency.
* Mon Jan 30 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.1.3-2
- Add socat dependency and make other requirements tight to bismark-mserver
  package versions.
* Sun Jan 29 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.1.3-1
- Fixes to itg_dw and heartbeat.
* Fri Jan 27 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.1.2-1
- Minor changes due to further mlab testing.
- Remove (noreplace) from config entries
* Thu Jan 26 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.1.0-1
- Updates to package after initial testing on m-lab.
* Mon Jan 23 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.0.1-1
- Initial packaging of bismark-mserver contents.

