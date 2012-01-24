# Original downloaded 2012-01-18 from
#   https://github.com/repoforge/rpms/blob/master/specs/netperf/netperf.spec
#   as of commit aab31c9bf1
# -----------------------------------------------------------------------------

# $id$
# Authority: dag
# Upstream: Rick Jones <netperf-feedback$netperf,org>

Summary: Performance testing tool for TCP/UDP
Name: netperf
Version: 2.4.5
Release: 1bismark1%{?dist}
License: BSD
Group: Applications/Internet
URL: http://www.netperf.org/netperf/NetperfPage.html

#Source: ftp://ftp.netperf.org/netperf/netperf-%{version}.tar.gz
Source: ftp://ftp.netperf.org/netperf/archive/netperf-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
Netperf is a tool to measure TCP/UDP performance.

%prep
%setup -q

%build
%configure \
    --program-prefix="%{?_program_prefix}"
%{__make} %{_smp_mflags}

%install
%{__rm} -rf %{buildroot}
%{__make} install DESTDIR="%{buildroot}"

### Clean up buildroot
%{__rm} -rf %{buildroot}%{_infodir}

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%doc COPYING README Release_Notes
%doc %{_mandir}/man1/netperf.1*
%doc %{_mandir}/man1/netserver.1*
%{_bindir}/netperf
%{_bindir}/netserver

%changelog
* Wed Jan 18 2012 Stephen Woodrow <woodrow@gatech.edu> - 2.4.5-1bismark1
- Update package for BISmark measurement servers -- do not install .info files

* Tue Jun 08 2010 Dag Wieers <dag@wieers.com> - 2.4.5-1
- Updated to release 2.4.5.

* Mon Oct 09 2006 Dag Wieers <dag@wieers.com> - 2.4.2-1
- Initial package. (using DAR)
