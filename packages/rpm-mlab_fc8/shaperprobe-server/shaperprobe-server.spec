# $id$
# Authority: dag
# Upstream: Partha Kanuparthy <partha@cc.gatech.edu>

Summary: Server for network capacity and traffic shaping measurement tool
Name: shaperprobe-server
Version: 0.1
Release: 1bismark3%{?dist}
License: GPLv2+
Group: Applications/Internet
URL: http://www.cc.gatech.edu/~partha/diffprobe/shaperprobe.html

Source: spserver.tar.gz
Patch0: 001-shaperprobe-server-bismark.patch
Patch1: 002-shaperprobe-server-tcp_wrappers.patch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: libpcap-devel, tcp_wrappers-devel

%description
ShaperProbe, part of the DiffProbe suite, actively probes the network path to
measure the capacity and the nature and extent of any traffic discrimination
(traffic shaping). This package offer probeserver, the server component which
works together with the prober client to carry out ShaperProbe  measurements.

%prep
%setup -q -n spserver
%patch0 -p2
%patch1 -p2

%build
make all

%install
%{__rm} -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}
cp -p probeserver %{buildroot}%{_bindir}

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%{_bindir}/probeserver

%changelog
* Sun Feb 05 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.1-1bismark3
- Add tcp_wrappers-devel to BuildRequires.

* Sat Feb 04 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.1-1bismark2
- Patch to use tcp_wrappers/libwrap for server access control.

* Wed Jan 18 2012 Stephen Woodrow <woodrow@gatech.edu> - 0.1-1bismark1
- Initial packaging for BISmark measurement servers.
