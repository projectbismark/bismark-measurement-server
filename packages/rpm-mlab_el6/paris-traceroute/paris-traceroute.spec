Name:           paris-traceroute
Version:        0.92
Release:        3bismark1%{?dist}
Summary:        A network diagnosis and measurement tool

Group:          Development/Languages
License:        GPLv2
URL:            http://www.paris-traceroute.net
Source0:        http://www.paris-traceroute.net/downloads/%{name}-%{version}-dev.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
Paris Traceroute is a fundamental upgrade to the standard Traceroute tool
that exists on all of the major operating systems. Standard Traceroute was
not designed to take into account the presence of load balancing routers,
which are widely deployed in today’s Internet, both at the core and at its
edges. As a result, standard Traceroute is not aware that there are often
multiple paths between a source and a destination in the Internet: the
paths will split at a load balancing router at one point along the route
and then reconverge some hops later. Standard traceroute is incapable of
furnishing this information to its users and instead reports what it states
to be a single path but is instead a confusing mixture of pieces of multiple
paths. Paris Traceroute is aware of the multiple paths and can report on any
single one of them accurately, as well as on all of them. 

%prep
%setup -q -n paris-traceroute-current

%build
%configure --enable-shared
make %{?_smp_mflags}


%install
make install DESTDIR=%{buildroot} INSTALL="install -p"
install -Dp -m 0644 man/%{name}.8 %{buildroot}%{_mandir}/man8/%{name}.8


%files
%attr(-,root, root) %doc AUTHORS COPYING README
%attr(-,root, root) %{_mandir}/man*/*.8*
%attr(-,root, root) %{_bindir}/%{name}


%changelog
* Wed Apr 23 2013 Srikanth Sundaresan <srikanth@gatech.edu> - 0.92-3bismark1
- Release update for bismark-mserver dependency

* Wed Feb 13 2013 Fabian Affolter <mail@fabian-affolter.ch> - 0.92-3
- Man page path fixed (BZ #910640)

* Sun Oct 21 2012 Fabian Affolter <mail@fabian-affolter.ch> - 0.92-2
- Minor changes

* Fri Mar 30 2012 Fabian Affolter <mail@fabian-affolter.ch> - 0.92-1
- Initial package for Fedora
