$puppetsever = 'mserver-mgmt.projectbismark.net'

node /bismark\.gt\.mlab\d+\.[^.]+\.measurement-lab.org/ {
    include bismark_mserver
}
