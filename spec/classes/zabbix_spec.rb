require 'spec_helper'

describe 'zabbix' do
  include_context :defaults
  let(:facts) { default_facts }

  it { should create_class('zabbix') }
  it { should contain_class('zabbix::params') }

end
