require 'spec_helper'

describe 'w_apache::monit' do

	describe command('monit -V') do
  	its(:stdout) { should match /5.13/ }
	end
		
	describe service('monit') do
		it { should be_enabled }
		it { should be_running }
	end
	
	describe service('apache2') do
  	it { should be_monitored_by('monit') }
	end

#	describe service('haproxy') do
#  	it { should be_monitored_by('monit') }
#	end

	describe file('/etc/monitrc') do
	  it { should be_file }
	  it { should match contain 'username "alert@example.com"' }
	end
	
end