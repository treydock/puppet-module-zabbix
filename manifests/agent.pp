# == Class: zabbix::agent
#
# Public class
#
class zabbix::agent (
  # Version support
  $version                    = $::zabbix::params::version,
  # User / Group
  $manage_user                = $::zabbix::params::agent_manage_user,
  $user_uid                   = $::zabbix::params::agent_user_uid,
  $user_home_dir              = $::zabbix::params::agent_user_home_dir,
  $group_gid                  = $::zabbix::params::agent_group_gid,
  # Package
  $package_ensure             = 'present',
  $package_name               = undef,
  # Config locations
  $config_d_dir               = $::zabbix::params::agent_config_d_dir,
  $purge_config_d_dir         = true,
  $config_file                = $::zabbix::params::agent_config_file,
  $scripts_dir                = $::zabbix::params::agent_scripts_dir,
  # Logrotate
  $manage_logrotate           = $::zabbix::params::agent_manage_logrotate,
  $logrotate_defaults         = $::zabbix::params::agent_logrotate_defaults,
  $use_logrotate_rule         = $::zabbix::params::agent_use_logrotate_rule,
  $logrotate_every            = $::zabbix::params::agent_logrotate_every,
  # Config values
  $servers                    = $::zabbix::params::servers,
  $listen_port                = $::zabbix::params::agent_listen_port,
  $log_dir                    = $::zabbix::params::agent_log_dir,
  $log_file                   = $::zabbix::params::agent_log_file,
  $pid_dir                    = $::zabbix::params::agent_pid_dir,
  $pid_file                   = $::zabbix::params::agent_pid_file,
  $enable_remote_commands     = $::zabbix::params::agent_config_defaults['enable_remote_commands'],
  $log_remote_commands        = $::zabbix::params::agent_config_defaults['log_remote_commands'],
  $listen_ip                  = $::zabbix::params::agent_config_defaults['listen_ip'],
  $start_agents               = $::zabbix::params::agent_config_defaults['start_agents'],
  $host_metadata              = $::zabbix::params::agent_config_defaults['host_metadata'],
  $refresh_active_checks      = $::zabbix::params::agent_config_defaults['refresh_active_checks'],
  $buffer_send                = $::zabbix::params::agent_config_defaults['buffer_send'],
  $buffer_size                = $::zabbix::params::agent_config_defaults['buffer_size'],
  $max_lines_per_second       = $::zabbix::params::agent_config_defaults['max_lines_per_second'],
  $timeout                    = $::zabbix::params::agent_config_defaults['timeout'],
  $allow_root                 = $::zabbix::params::agent_config_defaults['allow_root'],
  $unsafe_user_parameters     = $::zabbix::params::agent_config_defaults['unsafe_user_parameters'],
  # Service
  $service_name               = $::zabbix::params::agent_service_name,
  # Firewall
  $manage_firewall            = true,
  # Sudo
  $manage_sudo                = true,
  $sudo_ensure                = 'present',
  $sudo_priority              = 10,
) inherits zabbix::params {

  validate_bool($manage_user)
  validate_bool($purge_config_d_dir)
  validate_bool($manage_logrotate)
  validate_bool($use_logrotate_rule)
  validate_bool($enable_remote_commands)
  validate_bool($log_remote_commands)
  validate_bool($unsafe_user_parameters)
  validate_bool($manage_firewall)
  validate_bool($manage_sudo)

  validate_array($servers)
  validate_array($listen_ip)

  validate_re($version, ['^2.0', '^2.2'])
  validate_re($sudo_ensure, ['^present$', '^absent$'])

  validate_hash($logrotate_defaults)

  $package_name_real = pick($package_name, $::zabbix::params::agent_package_name[$version])

  $logrotate_local_params = {
    'path'          => $log_file,
    'rotate_every'  => $logrotate_every
  }

  $logrotate_params = merge($logrotate_defaults, $logrotate_local_params)

  include ::zabbix

  anchor { 'zabbix::agent::start': }->
  Class['zabbix']->
  class { 'zabbix::agent::user': }->
  class { 'zabbix::agent::install': }->
  class { 'zabbix::agent::config': }~>
  class { 'zabbix::agent::service': }->
  anchor { 'zabbix::agent::end': }

  # Ensure updates to package restart service
  Class['zabbix::agent::install']~>Class['zabbix::agent::service']

  if $manage_firewall {
    firewall { '100 allow zabbix-agent':
      ensure => 'present',
      port   => $listen_port,
      proto  => 'tcp',
      action => 'accept',
    }
  }

}
