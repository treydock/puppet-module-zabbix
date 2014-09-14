# == Class: zabbix::server::user
#
# Private class
#
class zabbix::server::user {

  if $::zabbix::server::manage_user {
    user { 'zabbixsrv':
      ensure  => 'present',
      comment => 'Zabbix Monitoring System -- Proxy or server',
      gid     => 'zabbixsrv',
      home    => $::zabbix::server::user_home_dir,
      shell   => '/sbin/nologin',
      uid     => $::zabbix::server::user_uid,
      system  => true,
      #forcelocal  => true,
    }

    group { 'zabbixsrv':
      ensure => 'present',
      gid    => $::zabbix::server::group_gid,
      system => true,
      #forcelocal  => true,
    }
  }

}
