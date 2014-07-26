# == Class: zabbix
#
class zabbix (
  $remove_conflicting_packages  = $::zabbix::params::remove_conflicting_packages,
  $conflicting_packages         = $::zabbix::params::conflicting_packages,
) inherits zabbix::params {

  validate_bool($remove_conflicting_packages)

  if $remove_conflicting_packages and $conflicting_packages and ! empty($conflicting_packages) {
    $conflicting_package_defaults = {
      'ensure'  => 'absent',
    }

    ensure_packages($conflicting_packages, $conflicting_package_defaults)
  }

}
