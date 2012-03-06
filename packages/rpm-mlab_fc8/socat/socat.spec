# Original downloaded 2012-01-30 from
#   https://github.com/repoforge/rpms/blob/master/specs/socat/socat.spec
#   as of commit e39ce2d9cb17342479460d36cae1ce4fa6d360d0
# -----------------------------------------------------------------------------
# $Id: socat.spec 8995 2010-08-02 10:59:31Z dag $
# Authority: dag
# Upstream: <socat$dest-unreach,org>

Summary: Relay for bidirectional data transfer between 2 channels
Name: socat
Version: 1.7.1.3
Release: 1bismark3%{?dist}
License: GPLv2
Group: Applications/Internet
URL: http://www.dest-unreach.org/socat/

#Packager: Dag Wieers <dag@wieers.com>
Vendor: Dag Apt Repository, http://dag.wieers.com/apt/

Source: http://www.dest-unreach.org/socat/download/socat-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: readline-devel, openssl-devel, tcp_wrappers-devel
Requires: tcp_wrappers

%description
socat is a relay for bidirectional data transfer between two independent data
channels. Each of these data channels may be a file, pipe, device (serial line
etc. or a pseudo terminal), a socket (UNIX, IP4, IP6 - raw, UDP, TCP), an
SSL socket, proxy CONNECT connection, a file descriptor (stdin etc.), the GNU
line editor, a program, or a combination of two of these.

%prep
%setup -q

%build
%configure --disable-fips
%{__make} %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
%{__make} install DESTDIR="%{buildroot}"

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%doc BUGREPORTS CHANGES COPYING* DEVELOPMENT EXAMPLES FAQ FILES PORTING README SECURITY
%doc *.sh doc/*.css doc/*.help doc/*.html
%doc %{_mandir}/man1/socat.1*
%{_bindir}/filan
%{_bindir}/procan
%{_bindir}/socat

%changelog
* Mon Mar 05 2012 Stephen Woodrow <woodrow@gatech.edu> - 1.7.1.3-1bismark3
- Make setup quiet.

* Thu Feb 02 2012 Stephen Woodrow <woodrow@gatech.edu> - 1.7.1.3-1bismark2
- Add tcp_wrappers headers to BuildRequires.

* Mon Jan 30 2012 Stephen Woodrow <woodrow@gatech.edu> - 1.7.1.3-1bismark1
- Include in bismark-mserver.

* Mon Aug 02 2010 Dag Wieers <dag@wieers.com> - 1.7.1.3-1 - 8995/dag
- Updated to release 1.7.1.3.

* Mon Jan 11 2010 Dag Wieers <dag@wieers.com> - 1.7.1.2-1
- Updated to release 1.7.1.2.

* Sun May 10 2009 Dag Wieers <dag@wieers.com> - 1.7.1.1-1
- Updated to release 1.7.1.1.

* Fri Apr 03 2009 Dag Wieers <dag@wieers.com> - 1.7.1.0-1
- Updated to release 1.7.1.0.

* Sat Nov 08 2008 Dag Wieers <dag@wieers.com> - 1.7.0.0-1
- Updated to release 1.7.0.0.

* Sun Feb 10 2008 Dag Wieers <dag@wieers.com> - 1.6.0.1-1
- Updated to release 1.6.0.1.

* Sat Mar 10 2007 Dag Wieers <dag@wieers.com> - 1.6.0.0-1
- Updated to release 1.6.0.0.

* Wed Jul 19 2006 Dag Wieers <dag@wieers.com> - 1.5.0.0-1
- Updated to release 1.5.0.0.

* Tue Jan 31 2006 Dag Wieers <dag@wieers.com> - 1.4.3.1-1
- Updated to release 1.4.3.1.

* Sun Sep 11 2005 Dag Wieers <dag@wieers.com> - 1.4.3.0-1
- Updated to release 1.4.3.0.

* Sat Mar 19 2005 Dag Wieers <dag@wieers.com> - 1.4.2.0-1
- Updated to release 1.4.2.0.

* Sun Nov 14 2004 Dag Wieers <dag@wieers.com> - 1.4.0.3-1
- Updated to release 1.4.0.3.

* Sat Sep 25 2004 Dag Wieers <dag@wieers.com> - 1.4.0.2-1
- Updated to release 1.4.0.2.

* Thu Jun 24 2004 Dag Wieers <dag@wieers.com> - 1.4.0.0-1
- Updated to release 1.4.0.0.

* Mon Mar 22 2004 Dag Wieers <dag@wieers.com> - 1.3.2.2-1
- Initial package. (using DAR)
