require 'spec_helper_acceptance'

describe 'zabbix::server class:' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
      class { 'zabbix::server': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
