# bismark-mserver Installation instructions for m-lab (fedora core 8)

1. Add bismark-mserver.repo to /etc/yum.repos.d/:

    ```sh
    $ cat << "EOF" | sudo tee /etc/yum.repos.d/bismark-mserver.repo
    [bismark-mserver]
    name=Bismark Measurment Server Fedora $releasever - $basearch
    baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/$basearch/
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=http://beachmont.noise.gatech.edu/bismark-mserver/mlab_fedora/fc$releasever/RPM-GPG-KEY-bismark

    [bismark-mserver-debuginfo]
    name=Bismark Measurment Server Fedora $releasever - $basearch - Debug
    baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/$basearch/debug
    enabled=0
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=http://beachmont.noise.gatech.edu/bismark-mserver/mlab_fedora/fc$releasever/RPM-GPG-KEY-bismark

    [bismark-mserver-source]
    name=Bismark Measurment Server Fedora $releasever - Source
    baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/source/SRPMS
    enabled=0
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=http://beachmont.noise.gatech.edu/bismark-mserver/mlab_fedora/fc$releasever/RPM-GPG-KEY-bismark
    EOF
    ```

2. Update repositories to pull in the bismark-mserver repository:

    ```sh
    $ sudo yum clean all
    $ sudo yum check-update
    ```

3. Update any other packages:

    ```sh
    $ sudo yum update
    ```

4. Install `bismark-mserver` (it will install the necessary dependencies):

    ```sh
    $ sudo yum install bismark-mserver
    ```

    Answer 'y' when yum asks you about importing RPM-GPG-KEY-bismark. The
    key's fingerprint is currently
    `7AA7 9826 A36D AC88 2455  6E4B 4D6A E2C2 16A7 D193`, 
    or `16A7D193` for short.

5. Set up bismark-mserver and crond to start on startup:

    ```sh
    $ sudo /sbin/chkconfig --level 2345 crond on
    $ sudo /sbin/chkconfig --level 2345 bismark-mserver on
    ```

6. Start bismark-mserver and crond:

    ```sh
    $ sudo /etc/init.d/crond start
    $ sudo /etc/init.d/bismark-mserver start
    ```

