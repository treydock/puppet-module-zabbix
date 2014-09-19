# zabbix_agent_version.rb

Facter.add(:zabbix_agent_version) do
  setcode do
    if Facter::Util::Resolution.which("zabbix_agentd")
      zabbix_agentd_v = Facter::Util::Resolution.exec("zabbix_agentd -V")
      zabbix_agentd_version = zabbix_agentd_v.scan(/v([0-9].[0-9].[0-9])/m).flatten.last unless zabbix_agentd_v.nil?
    end
  end
end
