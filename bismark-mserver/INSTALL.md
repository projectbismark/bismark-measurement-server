# bismark-mserver General installation instructions/requirements:

1. Create an unprivileged user to run the bismark-mserver daemons:

    ```sh
    $ /usr/sbin/useradd gt_bismark_unpriv
    $ /usr/sbin/usermod -L gt_bismark_unpriv
    ```

2. Add the following to the sudoers file via `sudo /usr/sbin/visudo`
   to enable TCP and ICMP traceroutes:

    ```
    ## Traceroutes requiring root, used by bismark-mserver
    Cmnd_Alias BISMARK_TRACEROUTE = \
            /bin/traceroute -n -q 1 -T [0-9]*.[0-9]*.[0-9]*.[0-9]*, \
            /bin/traceroute -n -q 1 -I [0-9]*.[0-9]*.[0-9]*.[0-9]*
    gt_bismark_unpriv ALL = NOPASSWD: BISMARK_TRACEROUTE
    ```

3. Install files as follows:

    ```
    /bismark-mserver/bin/           -> /usr/bin/
    /bismark-mserver/etc/           -> /etc/
    /bismark-mserver/etc/cron.d/    -> /etc/cron.d/
    /bismark-mserver/init.d/        -> /etc/init.d/ or /etc/rc.d/init.d/
    ```

4. Start crond if not already running.

5. Start bismark-mserver daemons by calling the initscript:

    ```sh
    $ sudo /etc/init.d/bismark-mserver start
    ```
