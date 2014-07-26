# == Class: zabbix
#
class zabbix (
  $purge_conflicting_packages = $::zabbix::params::purge_conflicting_packages,
  $conflicting_packages       = $::zabbix::params::conflicting_packages,
) inherits zabbix::params {

  validate_bool($purge_conflicting_packages)

  if $purge_conflicting_packages and $conflicting_packages and ! empty($conflicting_packages) {
    $conflicting_package_defaults = {
      'ensure'  => 'purged',
    }

    ensure_packages($conflicting_packages, $conflicting_package_defaults)
  }

}
