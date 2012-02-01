# bismark-mserver Installation instructions for m-lab (fedora core 8)

1. Add bismark-mserver.repo to /etc/yum.repos.d/:

    ```sh
    $ cat << "EOF" | sudo tee /etc/yum.repos.d/bismark-mserver.repo > /dev/null
    [bismark-mserver]
    name=Bismark Measurment Server Fedora $releasever - $basearch
    baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/$basearch/
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/RPM-GPG-KEY-bismark

    [bismark-mserver-debuginfo]
    name=Bismark Measurment Server Fedora $releasever - $basearch - Debug
    baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/$basearch/debug
    enabled=0
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/RPM-GPG-KEY-bismark

    [bismark-mserver-source]
    name=Bismark Measurment Server Fedora $releasever - Source
    baseurl=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/source/SRPMS
    enabled=0
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=http://mserver-mgmt.projectbismark.net/bismark-mserver/mlab_fedora/fc$releasever/RPM-GPG-KEY-bismark
    EOF
    ```

2. Update repositories to pull in the bismark-mserver repository:

    ```sh
    $ sudo yum clean all
    $ sudo yum check-update
    ```

    Answer 'y' if yum asks you about importing RPM-GPG-KEY-bismark. The key's
    fingerprint is shown below in the _RPM-GPG-KEY-bismark_ section.

3. Update any other packages:

    ```sh
    $ sudo yum update
    ```

4. Install `bismark-mserver` (it will install the necessary dependencies):

    ```sh
    $ sudo yum install bismark-mserver
    ```

    Answer 'y' if yum asks you about importing RPM-GPG-KEY-bismark. The key's
    fingerprint is shown below in the _RPM-GPG-KEY-bismark_ section.

5. Create an unprivileged user to run the bismark-mserver daemons:

    ```sh
    $ sudo /usr/sbin/useradd gt_bismark_unpriv
    $ sudo /usr/sbin/usermod -L gt_bismark_unpriv
    ```

    The username must match the `MSERVER_UNPRIV_USER` variable, so either
    create a user with the default username `gt_bismark_unpriv`, or create a
    user named as you like and change the value of `MSERVER_UNPRIV_USER` in
    `/etc/bismark-mserver.conf` accordingly.

6. Enable the unprivileged user to perform ICMP and TCP traceroutes by
   appending the following to your sudoers file with `sudo /usr/bin/visudo`:

    ```
    ## Traceroutes requiring root, used by bismark-mserver
    Cmnd_Alias BISMARK_TRACEROUTE = \
            /bin/traceroute -n -q 1 -T [0-9]*.[0-9]*.[0-9]*.[0-9]*, \
            /bin/traceroute -n -q 1 -I [0-9]*.[0-9]*.[0-9]*.[0-9]*
    gt_bismark_unpriv ALL = NOPASSWD: BISMARK_TRACEROUTE
    ```

    Note that if you picked a username other that `gt_bismark_unpriv` in step
    5, you must use the same username here.

7. Set up bismark-mserver and crond to start on startup:

    ```sh
    $ sudo /sbin/chkconfig --level 2345 crond on
    $ sudo /sbin/chkconfig --level 2345 bismark-mserver on
    ```

8. Start bismark-mserver and crond:

    ```sh
    $ sudo /etc/init.d/crond start
    $ sudo /etc/init.d/bismark-mserver start
    ```

## RPM-GPG-KEY-bismark

The fingerprint of the GPG key used to sign these packages and the repo
metadata is:

```sh
$ gpg --fingerprint 16A7D193
pub   1024D/16A7D193 2012-01-25
      Key fingerprint = 7AA7 9826 A36D AC88 2455  6E4B 4D6A E2C2 16A7 D193
uid                  BISmark Developer <bismark-admin@projectbismark.net>
```
