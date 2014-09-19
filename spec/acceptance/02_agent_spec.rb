require 'spec_helper_acceptance'

describe 'zabbix::agent class:' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
      class { 'zabbix::agent': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
