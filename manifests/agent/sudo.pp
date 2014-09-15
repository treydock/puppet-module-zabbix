# == Define: zabbix::agent::userparameter
#
define zabbix::agent::sudo ($command) {

  datacat_fragment { "zabbix::agent::sudo ${title}":
    target => 'zabbix-agent-sudo',
    data   => {
      "${title}" => any2array($command),
    },
  }

}
