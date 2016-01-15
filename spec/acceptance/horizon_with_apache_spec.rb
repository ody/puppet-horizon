require 'spec_helper_acceptance'

describe 'horizon class' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos

      class { '::horizon':
        secret_key       => 'big_secret',
        # need to disable offline compression due to
        # https://bugs.launchpad.net/ubuntu/+source/horizon/+bug/1424042
        compress_offline => false,
        allowed_hosts    => 'localhost',
        server_aliases   => [$::fqdn, 'localhost'],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    # basic test for now, to make sure Apache serve /horizon dashboard
    if os[:family] == 'Debian'
      describe command('curl --connect-timeout 5 -sL -w "%{http_code} %{url_effective}\n" http://localhost/horizon/auth/login -o /dev/null') do
        it { is_expected.to return_exit_status 0 }
        it { is_expected.to return_stdout(/^200/) }
      end
    elsif os[:family] == 'RedHat'
      describe command('curl --connect-timeout 5 -sL -w "%{http_code} %{url_effective}\n" http://localhost/dashboard/auth/login -o /dev/null') do
        it { is_expected.to return_exit_status 0 }
        it { is_expected.to return_stdout(/^200/) }
      end
    end

  end

  context 'parameters with modified root' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos

      class { '::horizon':
        secret_key       => 'big_secret',
        # need to disable offline compression due to
        # https://bugs.launchpad.net/ubuntu/+source/horizon/+bug/1424042
        compress_offline => false,
        allowed_hosts    => 'localhost',
        server_aliases   => [$::fqdn, 'localhost'],
        root_url         => '',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    # basic test for now, to make sure Apache serve /horizon dashboard
    if os[:family] == 'Debian'
      describe command('curl --connect-timeout 5 -sL -w "%{http_code} %{url_effective}\n" http://localhost/auth/login -o /dev/null') do
        it { is_expected.to return_exit_status 0 }
        it { is_expected.to return_stdout(/^200/) }
      end
    elsif os[:family] == 'RedHat'
      describe command('curl --connect-timeout 5 -sL -w "%{http_code} %{url_effective}\n" http://localhost/auth/login -o /dev/null') do
        it { is_expected.to return_exit_status 0 }
        it { is_expected.to return_stdout(/^200/) }
      end
    end

  end

end
