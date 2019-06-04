from fedora:30
MAINTAINER Guilherme Martins, gmartins princeton edu
RUN yum upgrade -y
RUN yum install -y sudo binutils initscripts iproute iputils findutils mlocate cronie vim curl wget links net-tools nc python python-simplejson traceroute chkconfig
RUN yum install -y glibc tcp_wrappers-libs.i686 tcp_wrappers libstdc++.i686
RUN useradd gt_bismark_unpriv && usermod -L gt_bismark_unpriv
COPY sudoers /etc/sudoers
COPY sudoers.bismark /etc/sudoers.d/
COPY rpm /root/rpm
RUN rpm -i --nodeps --nosignature /root/rpm/openssl098e-0.9.8e-29.el7.centos.3.i686.rpm
RUN rpm -i --nosignature /root/rpm/ncurses-libs-6.1-10.20180923.fc30.i686.rpm
RUN rpm -i --nosignature /root/rpm/compat-readline5-5.2-32.fc29.i686.rpm
RUN rpm -i --nosignature /root/rpm/ditg-2.8.0-0bismark4.rc1.fc8.i386.rpm
RUN rpm -i --nosignature /root/rpm/iperf-2.0.4-1bismark2.fc8.i386.rpm
RUN rpm -i --nosignature /root/rpm/netperf-2.4.5-1bismark4.fc8.i386.rpm
RUN rpm -i --nosignature /root/rpm/paris-traceroute-0.92-3.fc8.i386.rpm
RUN rpm -i --nosignature /root/rpm/shaperprobe-server-0.1-1bismark3.fc8.i386.rpm
RUN rpm -i --nosignature /root/rpm/socat-1.7.1.3-1bismark3.fc8.i386.rpm
RUN rpm -i --nosignature /root/rpm/bismark-mserver-0.1.14-1.fc8.noarch.rpm
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
EXPOSE 1430 55005 12865 9000 5001 1100 1101 1102
CMD ["./entrypoint.sh"]
