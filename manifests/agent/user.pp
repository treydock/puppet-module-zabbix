# == Class: zabbix::agent::user
#
# Private class
#
class zabbix::agent::user {

  if $::zabbix::agent::manage_user {
    user { 'zabbix':
      ensure     => 'present',
      comment    => 'Zabbix Monitoring System',
      gid        => 'zabbix',
      home       => $::zabbix::agent::user_home_dir,
      shell      => '/sbin/nologin',
      uid        => $::zabbix::agent::user_uid,
      system     => true,
      forcelocal => true,
    }

    group { 'zabbix':
      ensure     => 'present',
      gid        => $::zabbix::agent::group_gid,
      system     => true,
      forcelocal => true,
    }
  }

}
