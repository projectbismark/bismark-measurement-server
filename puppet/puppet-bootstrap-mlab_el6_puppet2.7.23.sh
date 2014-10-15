#!/bin/sh

cat << "EOF" | sudo tee /etc/yum.repos.d/bismark-mserver.repo > /dev/null
[bismark-mserver]
name=Bismark Measurment Server el$releasever.$arch
baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/el$releasever/$arch/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/el$releasever/RPM-GPG-KEY-bismark

[bismark-mserver-debuginfo]
name=Bismark Measurment Server el$releasever.$arch - Debug
baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/el$releasever/$arch/debug
enabled=0
gpgcheck=1
repo_gpgcheck=1
gpgkey=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/el$releasever/RPM-GPG-KEY-bismark

[bismark-mserver-source]
name=Bismark Measurment Server el$releasever.$arch - Source
baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/el$releasever/source/SRPMS
enabled=0
gpgcheck=1
repo_gpgcheck=1
gpgkey=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/el$releasever/RPM-GPG-KEY-bismark
EOF

cat << "EOF" | sudo tee /etc/yum.repos.d/epel.repo > /dev/null
[epel]
name=Extra Packages for Enterprise Linux 6 - $basearch
baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 6 - $basearch - Debug
#baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch/debug
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-6&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux 6 - $basearch - Source
#baseurl=http://download.fedoraproject.org/pub/epel/6/SRPMS
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-source-6&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
gpgcheck=1
EOF


sudo yum -y clean metadata
sudo yum -y install yum-plugin-versionlock
sudo yum versionlock netperf-2.4.5-1bismark4.el6
sudo yum versionlock iperf-2.0.4-1bismark2.el6
sudo yum versionlock socat-1.7.1.3-1bismark3.el6
sudo yum versionlock paris-traceroute-0.92-3bismark1.el6
sudo yum -y check-update
sudo yum -y update
sudo yum -y install puppet
sudo yum -y install epel-release

# sed line prevent errors due to https://projects.puppetlabs.com/issues/9491
sudo puppet agent --genconfig \
                  --server mserver-mgmt.projectbismark.net \
                  --certname bismark.gt.`hostname` \
                  --req_bits 4096 \
                  --keylength 4096 \
                  --ca_md sha1 \
                  --no-daemonize \
                  --onetime \
    | sed -r 's/(^\s+)(factsource|factdest)/\1# \2/' \
    | sudo tee /etc/puppet/puppet.conf > /dev/null
sudo puppet agent --test --waitforcert 10
