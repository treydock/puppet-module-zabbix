require 'spec_helper'

describe 'zabbix::agent::userparameter' do
  include_context :defaults

  let(:facts){ default_facts }

  let(:title) { 'foo' }

  it { should create_zabbix__agent__userparameter('foo') }

  it "should create userparameter file" do
    should contain_file('userparameter_foo.conf').only_with({
      :ensure => 'present',
      :path   => '/etc/zabbix_agentd.conf.d/userparameter_foo.conf',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0644',
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
        :notify   => 'Service[zabbix-agent]',
      })
    end
  end
end