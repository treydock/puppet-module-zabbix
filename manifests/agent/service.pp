# == Class: zabbix::agent::service
#
# Private class
#
class zabbix::agent::service {

  include ::zabbix::agent

  service { 'zabbix-agent':
    ensure     => 'running',
    name       => $::zabbix::agent::service_name,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
