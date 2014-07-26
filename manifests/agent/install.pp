# == Class: zabbix::agent::install
#
# Private class
#
class zabbix::agent::install {

  include ::zabbix::agent

  case $::osfamily {
    'RedHat': {
      include ::epel
      $package_require = Yumrepo['epel']
    }
    default: {
      # Do nothing
    }
  }

  package { 'zabbix-agent':
    ensure  => $::zabbix::agent::package_ensure,
    name    => $::zabbix::agent::package_name,
    require => $package_require,
  }

}
