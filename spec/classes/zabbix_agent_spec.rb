require 'spec_helper'

describe 'zabbix::agent' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :root_home => '/root',
        })
      end

      it { should compile.with_all_deps }
    end
  end

  on_supported_os({
    :hardwaremodels => ['x86_64'],
    :supported_os   => [
      {
        "operatingsystem" => "CentOS",
        "operatingsystemrelease" => [
          "6",
          "7"
        ]
      }
    ]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :root_home => '/root',
        })
      end

      it { should create_class('zabbix::agent') }
      it { should contain_class('zabbix::params') }

      it { should contain_anchor('zabbix::agent::start').that_comes_before('Class[zabbix]') }
      it { should contain_class('zabbix').that_comes_before('Class[zabbix::agent::user]') }
      it { should contain_class('zabbix::agent::user').that_comes_before('Class[zabbix::agent::install]') }
      it { should contain_class('zabbix::agent::install').that_comes_before('Class[zabbix::agent::config]') }
      it { should contain_class('zabbix::agent::config').that_notifies('Class[zabbix::agent::service]') }
      it { should contain_class('zabbix::agent::service').that_comes_before('Anchor[zabbix::agent::end]') }
      it { should contain_anchor('zabbix::agent::end') }

      it { should contain_class('zabbix::agent::install').that_notifies('Class[zabbix::agent::service]') }

      include_context 'zabbix::agent::user'
      include_context 'zabbix::agent::install'
      include_context 'zabbix::agent::config', facts
      include_context 'zabbix::agent::service'

      it 'manages Firewall for zabbix-agent' do
        should contain_firewall('100 allow zabbix-agent').with({
          :ensure  => 'present',
          :port    => '10050',
          :proto   => 'tcp',
          :action  => 'accept',
        })
      end

      # Test validate_bool parameters
      [
        :manage_user,
        :manage_logrotate,
        :use_logrotate_rule,
        :enable_remote_commands,
        :log_remote_commands,
        :unsafe_user_parameters,
        :manage_firewall,
      ].each do |p|
        context "when #{p} => 'foo'" do
          let(:params) {{ p => 'foo' }}
          it 'should raise an error' do
            expect { should compile }.to raise_error(/is not a boolean/)
          end
        end
      end

      # Test validate_array parameters
      [
        :servers,
        :listen_ip,
      ].each do |p|
        context "when #{p} => 'foo'" do
          let(:params) {{ p => 'foo' }}
          it 'should raise an error' do
            expect { should compile }.to raise_error(/is not an Array/)
          end
        end
      end

      # Test validate_hash parameters
      [
        :logrotate_defaults,
      ].each do |p|
        context "when #{p} => 'foo'" do
          let(:params) {{ p => 'foo' }}
          it 'should raise an error' do
            expect { should compile }.to raise_error(/is not a Hash/)
          end
        end
      end

      context 'unsupported version' do
        let(:params) {{ :version => '1.8' }}
        it 'should raise an error' do
          expect { should compile }.to raise_error(/does not match/)
        end
      end

    end
  end
end
