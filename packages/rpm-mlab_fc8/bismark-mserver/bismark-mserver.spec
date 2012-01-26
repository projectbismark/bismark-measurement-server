Summary: BISmark Measurement Server
Name: bismark-mserver
Version: 0.0.1
Release: 1%{?dist}
License: GPLv2
Group: Applications/Internet
URL: http://redmine.noise.gatech.edu/projects/bismark-mserver

Source: bismark-mserver.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildArch: noarch
Requires: netperf = 2.4.5
Requires: iperf >= 2.0.4
Requires: ditg = 2.8.0
Requires: shaperprobe-server
Requires: socat
Requires: curl
Requires(post): chkconfig
Requires(preun): chkconfig, initscripts
# Requires: monit  # save this for later release

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
mkdir -p %{buildroot}%{_sysconfdir}/cron.d
cp -p etc/cron.d/bismark-mserver %{buildroot}%{_sysconfdir}/cron.d
mkdir -p %{buildroot}%{_initrddir}  # %{_initrddir} is deprecated as of fc10
cp -p etc/init.d/bismark-mserver %{buildroot}%{_initrddir}

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%doc LICENSE README
%{_bindir}/bismark-mserver*
%config(noreplace) %{_sysconfdir}/bismark-mserver.conf
%config(noreplace) %{_sysconfdir}/cron.d/bismark-mserver
%{_initrddir}/bismark-mserver

%post
/sbin/chkconfig --add %{name}

%preun
if [ $1 -eq 0 ]; then
    /sbin/service %{name} stop > /dev/null 2>&1
    /sbin/chkconfig --del %{name}
fi

%changelog
* Mon Jan 23 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.0.1-1
- Initial packaging of bismark-mserver contents.

