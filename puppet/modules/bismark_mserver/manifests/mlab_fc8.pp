class bismark_mserver::mlab_fc8 {
    user { 'gt_bismark_unpriv' :
        ensure   => present,
        shell    => '/bin/bash',
        password => '!'  # lock the password
    }

    file { '/etc/sudoers' :
        require => User['gt_bismark_unpriv'],
        alias  => sudoers,
        owner  => root,
        group  => root,
        mode   => 440,
        ensure => file,
        source => 'puppet:///modules/bismark_mserver/etc/sudoers',
        backup => server_bucket
    }

    filebucket { 'server_bucket' :
        path => false  # backup to server
    }

    package { 'bismark-mserver':
        ensure => latest
    }

    service { 'crond' :
        enable => true,
        ensure => running,
        # hack to deal with non-LSB-compliant status of vixie-cron initscript
        hasstatus => false
    }

    service { 'bismark-mserver' :
        require => [File['/etc/sudoers'], Package['bismark-mserver'], Service['crond']],
        enable => true,
        ensure => running,
        hasstatus => false
    }

    cron { yum_checkupdate :
        command => '/usr/bin/yum clean metadata && sleep $((($RANDOM*600)/32767)) && /usr/bin/yum -y check-update',
        ensure  => present,
        user    => root,
        hour    => [0, 6, 12, 18],
        minute  => 0

    }

    cron { puppet_agent :
        command => 'sleep $((($RANDOM*600)/32767)) && /usr/bin/puppet agent',
        ensure  => present,
        user    => root,
        hour    => [0, 6, 12, 18],
        minute  => 30
    }
}
