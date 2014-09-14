# == Class: zabbix::server::config
#
class zabbix::server::config {

  include ::zabbix::server

  File {
    owner => 'zabbixsrv',
    group => 'zabbixsrv',
  }

  file { '/var/lib/zabbixsrv':
    ensure => 'directory',
    path   => $::zabbix::server::user_home_dir,
    mode   => '0750',
  }

  file { '/var/lib/zabbixsrv/alertscripts':
    ensure  => 'directory',
    path    => $::zabbix::server::alert_scripts_path,
    mode    => '0750',
    require => File['/var/lib/zabbixsrv'],
  }

  file { '/var/lib/zabbixsrv/externalscripts':
    ensure  => 'directory',
    path    => $::zabbix::server::external_scripts,
    mode    => '0750',
    require => File['/var/lib/zabbixsrv'],
  }

  file { '/var/lib/zabbixsrv/tmp':
    ensure  => 'directory',
    path    => $::zabbix::server::tmp_dir,
    mode    => '0750',
    require => File['/var/lib/zabbixsrv'],
  }

  file { '/var/log/zabbixsrv':
    ensure => 'directory',
    path   => $::zabbix::server::log_dir,
    owner  => 'root',
    mode   => '0775',
  }

  file { '/var/run/zabbixsrv':
    ensure => 'directory',
    path   => $::zabbix::server::pid_dir,
    owner  => 'root',
    mode   => '0775',
  }

  file { '/etc/zabbix_server.conf':
    ensure  => 'file',
    path    => $::zabbix::server::config_file,
    owner   => 'root',
    mode    => '0640',
    content => template('zabbix/server/zabbix_server.conf.erb'),
  }

  file { '/etc/zabbix_server.conf.d':
    ensure  => 'directory',
    path    => $::zabbix::server::config_d_dir,
    owner   => 'root',
    mode    => '0750',
    recurse => true,
    purge   => true,
  }

  if $::zabbix::server::manage_logrotate {
    # Make using logrotate::rule optional
    # because the version that supports 'su' is
    # not yet in the Forge.
    if $::zabbix::server::use_logrotate_rule {
      logrotate::rule { 'zabbix-server':
        path         => $::zabbix::server::log_file,
        missingok    => true,
        rotate_every => $::zabbix::server::logrotate_every,
        ifempty      => false,
        compress     => true,
        create       => true,
        create_mode  => '0664',
        create_owner => 'zabbixsrv',
        create_group => 'zabbixsrv',
        su           => true,
        su_owner     => 'zabbixsrv',
        su_group     => 'zabbixsrv',
      }
    } else {
      file { '/etc/logrotate.d/zabbix-server':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('zabbix/server/logrotate/zabbix-server.erb'),
      }
    }
  }

}
