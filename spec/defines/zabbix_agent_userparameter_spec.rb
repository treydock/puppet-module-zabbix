require 'spec_helper'

describe 'zabbix::agent::userparameter' do
  let :facts do
    {
      :fqdn                       => 'foo.example.com',
      :domain                     => 'example.com',
      :osfamily                   => 'RedHat',
      :root_home                  => '/root',
      :operatingsystemmajrelease  => '6',
    }
  end

  let(:title) { 'foo' }

  it { should create_zabbix__agent__userparameter('foo') }
  it { should contain_class('zabbix::agent') }

  it "should create userparameter file" do
    should contain_file('userparameter_foo.conf').only_with({
      :ensure => 'present',
      :path   => '/etc/zabbix_agentd.conf.d/userparameter_foo.conf',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0644',
      :require  => 'File[/etc/zabbix_agentd.conf.d]',
      :notify   => 'Service[zabbix-agent]',
    })
  end

  context 'with content defined' do
    let(:params) {{ :content => 'UserParameter=foo.bar,echo 1' }}

    it "should create userparameter file" do
      should contain_file('userparameter_foo.conf').only_with({
        :ensure => 'present',
        :path   => '/etc/zabbix_agentd.conf.d/userparameter_foo.conf',
        :content  => /^UserParameter=foo.bar,echo 1\n/,
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0644',
        :require  => 'File[/etc/zabbix_agentd.conf.d]',
        :notify   => 'Service[zabbix-agent]',
      })
    end
  end

  context 'with source defined' do
    let(:params) {{ :source => 'puppet:///files/zabbix/userparameters/foo' }}

    it "should create userparameter file" do
      should contain_file('userparameter_foo.conf').only_with({
        :ensure => 'present',
        :path   => '/etc/zabbix_agentd.conf.d/userparameter_foo.conf',
        :source   => 'puppet:///files/zabbix/userparameters/foo',
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0644',
        :require  => 'File[/etc/zabbix_agentd.conf.d]',
        :notify   => 'Service[zabbix-agent]',
      })
    end
  end
end
