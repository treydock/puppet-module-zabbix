# == Class: zabbix::agent
#
# Public class
#
class zabbix::agent (
  $manage_user                = $::zabbix::params::agent_manage_user,
  $user_uid                   = $::zabbix::params::agent_user_uid,
  $user_home_dir              = $::zabbix::params::agent_user_home_dir,
  $group_gid                  = $::zabbix::params::agent_group_gid,
  $package_ensure             = 'present',
  $package_name               = $::zabbix::params::agent_package_name,
  $config_d_dir               = $::zabbix::params::agent_config_d_dir,
  $config_file                = $::zabbix::params::agent_config_file,
  $scripts_dir                = $::zabbix::params::agent_scripts_dir,
  $manage_logrotate           = $::zabbix::params::agent_manage_logrotate,
  $use_logrotate_rule         = $::zabbix::params::agent_use_logrotate_rule,
  $logrotate_every            = $::zabbix::params::agent_logrotate_every,
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
  $service_name               = $::zabbix::params::agent_service_name,
  $manage_firewall            = true,
) inherits zabbix::params {

  validate_bool($manage_user)
  validate_bool($manage_logrotate)
  validate_bool($use_logrotate_rule)
  validate_bool($enable_remote_commands)
  validate_bool($log_remote_commands)
  validate_bool($unsafe_user_parameters)
  validate_bool($manage_firewall)

  validate_array($servers)
  validate_array($listen_ip)

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
