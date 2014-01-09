$puppetsever = 'mserver-mgmt.projectbismark.net'

node /bismark\.gt\.mlab\d+\.[^.]+\.measurement-lab.org/ {
    include bismark_mserver
}

node /bismark\.eko-konnect\.net\.ng/ {
    include bismark_mserver
}

node /localhost\.localdomain/ {
    include bismark_mserver
}
