# $id$
# Authority: dag
# Upstream: ditg@comics.unina.it

Summary: Distributed Internet traffic generator (D-ITG)
Name: ditg
Version: 2.8.0
Release: 0bismark1.rc1%{?dist}
License: GPLv2+
Group: Applications/Internet
URL: http://www.grid.unina.it/software/ITG

Source: http://www.grid.unina.it/software/ITG/codice/D-ITG-2.8.0-rc1.tgz
Patch0: D-ITG-2.8.0-rc1.patch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
D-ITG (Distributed Internet Traffic Generator) is a platform capable to produce
traffic at packet level accurately replicating appropriate stochastic processes
for both IDT (Inter Departure Time) and PS (Packet Size) random variables

%prep
%setup -q -n D-ITG-2.8.0-rc1
%patch0 -p1

%build
cd src
make all multiport=on

%install
%{__rm} -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}
cp -p bin/ITGSend %{buildroot}%{_bindir}
cp -p bin/ITGRecv %{buildroot}%{_bindir}
cp -p bin/ITGLog %{buildroot}%{_bindir}
cp -p bin/ITGDec %{buildroot}%{_bindir}
cp -p bin/ITGManager %{buildroot}%{_bindir}

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%doc LICENSE README CHANGELOG
%{_bindir}/ITGSend
%{_bindir}/ITGRecv
%{_bindir}/ITGLog
%{_bindir}/ITGDec
%{_bindir}/ITGManager

%changelog
* Wed Jan 18 2012 Stephen Woodrow <woodrow@gatech.edu> - 2.8.0-0bismark1.rc1
- Initial packaging for BISmark measurement servers.
