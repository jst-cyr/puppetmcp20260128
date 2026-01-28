# Example: Multi-tier application infrastructure
#
# This example provisions a complete multi-tier application
# with web servers, application servers, and a database.

class { 'aws_provisioning':
  aws_access_key_id     => lookup('aws::access_key_id'),
  aws_secret_access_key => Sensitive(lookup('aws::secret_access_key')),
  region                => 'us-west-2',
}

# Load balancer tier
['web-01', 'web-02'].each |$server| {
  aws_provisioning::instance { $server:
    ami_id          => 'ami-0c55b159cbfafe1f0',
    instance_type   => 't3.small',
    key_name        => 'prod-keypair',
    security_groups => ['sg-web-tier'],
    subnet_id       => 'subnet-public-1a',
    tags            => {
      'Environment' => 'production',
      'Role'        => 'webserver',
      'Tier'        => 'frontend',
      'Backup'      => 'daily',
    },
  }
}

# Application tier
['app-01', 'app-02'].each |$server| {
  aws_provisioning::instance { $server:
    ami_id          => 'ami-0a1b2c3d4e5f6g7h8',
    instance_type   => 't3.medium',
    key_name        => 'prod-keypair',
    security_groups => ['sg-app-tier'],
    subnet_id       => 'subnet-private-1a',
    tags            => {
      'Environment' => 'production',
      'Role'        => 'application',
      'Tier'        => 'middleware',
      'Backup'      => 'daily',
    },
  }
}

# Database tier
aws_provisioning::instance { 'db-primary':
  ami_id          => 'ami-db0123456789abcd',
  instance_type   => 'r5.large',
  key_name        => 'prod-keypair',
  security_groups => ['sg-db-tier'],
  subnet_id       => 'subnet-private-1b',
  tags            => {
    'Environment' => 'production',
    'Role'        => 'database',
    'Tier'        => 'backend',
    'Backup'      => 'hourly',
    'Type'        => 'primary',
  },
}
