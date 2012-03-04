#!/bin/sh

cat << "EOF" | sudo tee /etc/yum.repos.d/bismark-mserver.repo > /dev/null
[bismark-mserver]
name=Bismark Measurment Server fc$releasever.$basearch
baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/$basearch/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/RPM-GPG-KEY-bismark

[bismark-mserver-debuginfo]
name=Bismark Measurment Server fc$releasever.$basearch - Debug
baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/$basearch/debug
enabled=0
gpgcheck=1
repo_gpgcheck=1
gpgkey=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/RPM-GPG-KEY-bismark

[bismark-mserver-source]
name=Bismark Measurment Server fc$releasever.$basearch - Source
baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/source/SRPMS
enabled=0
gpgcheck=1
repo_gpgcheck=1
gpgkey=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/RPM-GPG-KEY-bismark
EOF

sudo yum -y clean metadata
sudo yum -y check-update
sudo yum -y update
sudo yum -y install puppet

# sed line prevent errors due to https://projects.puppetlabs.com/issues/9491
sudo puppet agent --genconfig \
                  --server mserver-mgmt.projectbismark.net \
                  --certname bismark.gt.`hostname` \
                  --onetime \
    | sed -r 's/(^\s+)(factsource|factdest)/\1# \2/' \
    | sudo tee /etc/puppet/puppet.conf > /dev/null
sudo puppet agent --test --waitforcert
