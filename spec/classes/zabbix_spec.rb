require 'spec_helper'

describe 'zabbix' do
  include_context :defaults
  let(:facts) { default_facts }

  it { should create_class('zabbix') }
  it { should contain_class('zabbix::params') }

  it { should have_package_resource_count(0) }
  it { should_not contain_package('zabbix') }
  it { should_not contain_package('zabbix20') }

  context 'when purge_conflicting_packages => true' do
    let(:params) {{ :purge_conflicting_packages => true }}
    it { should have_package_resource_count(2) }
    it { should contain_package('zabbix').with_ensure('purged') }
    it { should contain_package('zabbix20').with_ensure('purged') }

    context "when operatingsystemmajversion => 7" do
      let(:facts) { default_facts.merge({
        :operatingsystemmajrelease => '7',
      })}
      let(:params) {{ :purge_conflicting_packages => true }}

      it { should have_package_resource_count(1) }
      it { should_not contain_package('zabbix') }
      it { should contain_package('zabbix20').with_ensure('purged') }
    end

    [
      false,
      '',
      [],
    ].each do |v|
      context "when conflicting_packages => #{v}" do
        let(:params) {{ :purge_conflicting_packages => true, :conflicting_packages => v }}
        it { should have_package_resource_count(0) }
        it { should_not contain_package('zabbix') }
        it { should_not contain_package('zabbix20') }
      end
    end
  end

  # Test validate_bool parameters
  [
    :purge_conflicting_packages,
  ].each do |p|
    context "when #{p} => 'foo'" do
      let(:params) {{ p => 'foo' }}
      it { expect { should create_class('zabbix') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end

end
