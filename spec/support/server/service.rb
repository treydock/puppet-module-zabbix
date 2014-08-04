shared_context 'zabbix::server::service' do
  let(:facts) { default_facts }

  it { should create_class('zabbix::server::service') }
  it { should contain_class('zabbix::server') }

  it do
    should contain_service('zabbix-server').only_with({
      :ensure      => 'running',
      :name        => 'zabbix-server',
      :enable      => 'true',
      :hasstatus   => 'true',
      :hasrestart  => 'true',
    })
  end
end
