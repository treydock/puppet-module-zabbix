shared_context 'zabbix::server::service' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :root_home                  => '/root',
      :operatingsystemmajrelease  => '6',
    }
  end

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
