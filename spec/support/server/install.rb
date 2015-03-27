shared_context 'zabbix::server::install' do
  it { should create_class('zabbix::server::install') }
  it { should contain_class('zabbix::server') }
  it { should contain_class('epel') }

  it do
    should contain_package('zabbix-server').only_with({
      :ensure   => 'present',
      :name     => 'zabbix22-server-mysql',
      :require  => 'Yumrepo[epel]',
    })
  end

  context 'when version is 2.0' do
    let(:params) {{ :version => '2.0' }}

    it 'should install zabbix20-server-mysql' do
      should contain_package('zabbix-server').with_name('zabbix20-server-mysql')
    end
  end
end
