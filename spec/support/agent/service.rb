shared_context 'zabbix::agent::service' do
  it { should create_class('zabbix::agent::service') }
  it { should contain_class('zabbix::agent') }

  it do
    should contain_service('zabbix-agent').only_with({
      :ensure      => 'running',
      :name        => 'zabbix-agent',
      :enable      => 'true',
      :hasstatus   => 'true',
      :hasrestart  => 'true',
    })
  end
end
