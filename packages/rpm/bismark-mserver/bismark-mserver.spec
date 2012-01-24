Summary: BISmark Measurement Server
Name: bismark-mserver
Version: 0.0.1
Release: 1%{?dist}
License: GPLv2
Group: Applications/Internet
URL: http://redmine.noise.gatech.edu/projects/bismark-mserver

Source: 
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildArch: noarch
Requires: netperf = 2.4.5
Requires: iperf >= 2.0.4
Requires: ditg = 2.8.0
Requires: shaperprobe-server
Requires: socat
Requires: monit

%description
Sets up a BISmark measurement server capable of sourcing and sinking traffic
for Project BISmark routers.

%prep
%setup -q

%install
%{__rm} -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}
cp -p bin/ %{buildroot}%{_bindir}

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%doc LICENSE README
%{_bindir}/

%changelog
* Mon Jan 23 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.0.1-1
- Initial packaging of bismark-mserver contents.

