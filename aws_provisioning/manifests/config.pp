# @summary Manages AWS CLI configuration and credentials
#
# This class ensures AWS CLI is installed and properly configured
# with credentials and default region settings.
#
# @example
#   include aws_provisioning::config
#
class aws_provisioning::config {
  # Require main class parameters
  $aws_access_key_id = $aws_provisioning::aws_access_key_id
  $aws_secret_access_key = $aws_provisioning::aws_secret_access_key
  $region = $aws_provisioning::region

  # Install AWS CLI based on OS
  case $facts['os']['family'] {
    'Debian': {
      package { 'awscli':
        ensure => installed,
      }
    }
    'RedHat': {
      package { 'awscli':
        ensure => installed,
      }
    }
    'windows': {
      # On Windows, assume AWS CLI is installed via MSI
      # or provide download/install logic
      notify { 'aws_cli_windows':
        message => 'Please ensure AWS CLI is installed on Windows',
      }
    }
    default: {
      fail("Unsupported operating system: ${facts['os']['family']}")
    }
  }

  # Create .aws directory for configuration
  $aws_config_dir = $facts['os']['family'] ? {
    'windows' => 'C:/Users/Administrator/.aws',
    default   => '/root/.aws',
  }

  file { $aws_config_dir:
    ensure => directory,
    mode   => '0700',
  }

  # AWS credentials file
  file { "${aws_config_dir}/credentials":
    ensure  => file,
    mode    => '0600',
    content => epp('aws_provisioning/credentials.epp', {
        'aws_access_key_id'     => $aws_access_key_id,
        'aws_secret_access_key' => $aws_secret_access_key,
    }),
    require => File[$aws_config_dir],
  }

  # AWS config file
  file { "${aws_config_dir}/config":
    ensure  => file,
    mode    => '0600',
    content => epp('aws_provisioning/config.epp', {
        'region' => $region,
    }),
    require => File[$aws_config_dir],
  }
}
