# Example: Basic EC2 instance provisioning
#
# This example demonstrates how to use the aws_provisioning module
# to create a simple EC2 instance.

class { 'aws_provisioning':
  aws_access_key_id     => 'AKIAIOSFODNN7EXAMPLE',
  aws_secret_access_key => Sensitive('wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'),
  region                => 'us-east-1',
}

aws_provisioning::instance { 'web-server-01':
  ami_id          => 'ami-0c55b159cbfafe1f0',
  instance_type   => 't2.micro',
  key_name        => 'my-keypair',
  security_groups => ['sg-0123456789abcdef0'],
  subnet_id       => 'subnet-0123456789abcdef0',
  tags            => {
    'Name'        => 'web-server-01',
    'Environment' => 'development',
    'Role'        => 'webserver',
    'ManagedBy'   => 'Puppet',
  },
}
