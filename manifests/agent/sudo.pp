# == Define: zabbix::agent::userparameter
#
define zabbix::agent::sudo ($command) {

  $data = {
    "${title}" => any2array($command)
  }

  datacat_fragment { "zabbix::agent::sudo ${title}":
    target => 'zabbix-agent-sudo',
    data   => $data,
  }

}
