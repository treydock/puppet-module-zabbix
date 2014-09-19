require 'spec_helper'

describe 'zabbix::agent::sudo' do
  include_context :defaults

  let(:facts){ default_facts }

  let(:title) { 'foo' }
  let(:params) {{ :command => '/usr/bin/bar' }}

  it { should create_zabbix__agent__sudo('foo') }

  it do
    should contain_datacat_fragment('zabbix::agent::sudo foo').with_data({'foo' => ['/usr/bin/bar']})
  end

  context 'when command is an Array' do
    let(:title) { 'bar' }
    let(:params) {{ :command => ['/usr/bin/foo', '/usr/bin/baz'] }}

    it { should create_zabbix__agent__sudo('bar') }

    it do
      should contain_datacat_fragment('zabbix::agent::sudo bar').with_data({'bar' => ['/usr/bin/foo','/usr/bin/baz']})
    end
  end
end