require_relative '../spec_helper'

describe 'w_memcached::default' do

  context 'with default setting' do

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['monit_enabled'] = true
      end.converge(described_recipe)
    end

    let(:group_memcache) { chef_run.group('memcache') }
    let(:template_memcached) { chef_run.template('/etc/memcached.conf')}

    before do
      stub_command('getent passwd memcache').and_return(false)
      stub_command('dpkg -s memcached').and_return(false)
    end

    it 'runs recipe memcached' do
      expect(chef_run).to include_recipe('memcached')
    end

    describe 'memcached::pakcage recipe' do

      it 'prevents memcached service to start automatically by putting exit code 101 action not allowed' do
        expect(chef_run).to create_file('/usr/sbin/policy-rc.d with exit 101').with(path: '/usr/sbin/policy-rc.d', content: 'exit 101', mode: '0755')
      end

      it 'installs memcached package' do
        expect(chef_run).to install_package('memcached')
      end

      it 'bring back memcached service to be able to start by putting exit code 0 action allowed' do
        expect(chef_run).to create_file('/usr/sbin/policy-rc.d with exit 0').with(path: '/usr/sbin/policy-rc.d', content: 'exit 0', mode: '0755')
      end

      it 'enables firewall and runs resoruce firewall_rule to open port 11211' do
      	expect(chef_run).to install_firewall('default')
        expect(chef_run).to create_firewall_rule('memcached').with(port: 11211)
      end

      it 'installs package libmemcached-dev' do
        expect(chef_run).to install_package('libmemcached-dev')
      end

      it 'creates group memcache' do
        expect(chef_run).to create_group('memcache').with(system: true)
        expect(group_memcache).to notify('user[memcache]').immediately
      end

      it 'creates user memcache' do
        expect(chef_run).not_to create_user('memcache').with(system: true, manage_home: false ,gid: 'memcache' ,home: '/nonexistent' ,comment: 'Memcached' ,shell: '/bin/false')
      end
    end

    describe 'memcached::configure recipe' do

      it 'creates log dir' do
        expect(chef_run).to create_directory('/var/log/')
      end

      it 'enables service memcached' do
        expect(chef_run).to enable_service('memcached').with(supports: {status: true, start: true, stop: true, restart: true, enable: true})
      end

      it 'creates config file from template' do
        expect(chef_run).to create_template('/etc/memcached.conf').with(source: 'memcached.conf.erb', owner: 'root', group: 'root', mode: '0644')
        expect(template_memcached).to notify('service[memcached]').to(:restart)
      end
    end

    it 'runs recipe w_memcached::monit' do
      expect(chef_run).to include_recipe('w_memcached::monit')
    end
  end

  context 'when memcached already installed' do

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['monit_enabled'] = true
      end.converge(described_recipe)
    end

    before do
      stub_command('getent passwd memcache').and_return(true)
      stub_command('dpkg -s memcached').and_return(true)
    end

    it 'prevents memcached service to start automatically' do
      expect(chef_run).not_to create_file('/usr/sbin/policy-rc.d with exit 101').with(path: '/usr/sbin/policy-rc.d', content: 'exit 101', mode: '0755')
    end

    it 'does not creates group memcache' do
      expect(chef_run).not_to create_group('memcache').with(system: true)
    end
  end
end
