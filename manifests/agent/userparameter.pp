# == Define: zabbix::agent::userparameter
#
define zabbix::agent::userparameter (
  $ensure   = 'present',
  $content  = undef,
  $source   = undef,
) {

  include zabbix::agent

  validate_re($ensure, '^(present|absent)$')

  if $content != undef {
    $content_real = "${content}\n"
  } else {
    $content_real = undef
  }

  $config_filename = "userparameter_${name}.conf"

  file { $config_filename:
    ensure  => $ensure,
    path    => "${::zabbix::agent::config_d_dir}/${config_filename}",
    content => $content_real,
    source  => $source,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/zabbix_agentd.conf.d'],
    notify  => Service['zabbix-agent'],
  }

}
