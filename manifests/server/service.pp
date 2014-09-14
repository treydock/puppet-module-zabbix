# == Class: zabbix::server::service
#
# Private class
#
class zabbix::server::service {

  include ::zabbix::server

  service { 'zabbix-server':
    ensure     => 'running',
    name       => $::zabbix::server::service_name,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
