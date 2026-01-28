# aws_provisioning

A Puppet module for automating the provisioning of AWS EC2 virtual machines. This module manages AWS CLI configuration, credentials, and provides defined types for creating and managing EC2 instances following AWS best practices.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with aws_provisioning](#setup)
    * [What aws_provisioning affects](#what-aws_provisioning-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with aws_provisioning](#beginning-with-aws_provisioning)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - Module parameters and defined types](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

The `aws_provisioning` module automates AWS EC2 instance provisioning and management through Puppet. It handles:

* AWS CLI installation and configuration
* Secure credential management
* EC2 instance creation with customizable parameters
* Instance lifecycle management (create/terminate)
* Tagging and resource organization
* Multi-region support

This module is ideal for organizations that want to integrate AWS infrastructure provisioning into their Puppet-based configuration management workflow.

## Setup

### What aws_provisioning affects

* **AWS CLI**: Installs and configures the AWS CLI package
* **Configuration files**: Creates and manages `~/.aws/credentials` and `~/.aws/config`
* **EC2 instances**: Creates, configures, and manages EC2 instances via AWS API
* **System packages**: Installs `awscli` package on Linux systems

### Setup Requirements

**Prerequisites:**

* Puppet >= 7.24
* Valid AWS account with appropriate IAM permissions
* IAM user or role with EC2 management permissions
* On Windows: AWS CLI must be pre-installed

**Required IAM Permissions:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:DescribeInstances",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
```

### Beginning with aws_provisioning

**Basic setup:**

1. Declare the main class with your AWS credentials:

```puppet
class { 'aws_provisioning':
  aws_access_key_id     => 'AKIAIOSFODNN7EXAMPLE',
  aws_secret_access_key => Sensitive('wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'),
  region                => 'us-west-2',
}
```

2. Create an EC2 instance:

```puppet
aws_provisioning::instance { 'my-web-server':
  ami_id          => 'ami-0c55b159cbfafe1f0',
  instance_type   => 't2.micro',
  key_name        => 'my-keypair',
  security_groups => ['sg-0123456789abcdef0'],
  subnet_id       => 'subnet-0123456789abcdef0',
  tags            => {
    'Environment' => 'production',
    'Role'        => 'webserver',
  },
}
```

## Usage

### Configure AWS credentials

```puppet
class { 'aws_provisioning':
  aws_access_key_id     => lookup('aws::access_key_id'),
  aws_secret_access_key => Sensitive(lookup('aws::secret_access_key')),
  region                => 'us-east-1',
  manage_config         => true,
}
```

### Create multiple EC2 instances

```puppet
# Web servers
aws_provisioning::instance { 'web-01':
  ami_id          => 'ami-0c55b159cbfafe1f0',
  instance_type   => 't3.medium',
  key_name        => 'prod-key',
  security_groups => ['sg-web'],
  subnet_id       => 'subnet-public-1a',
  tags            => {
    'Environment' => 'production',
    'Role'        => 'webserver',
    'Tier'        => 'frontend',
  },
}

aws_provisioning::instance { 'web-02':
  ami_id          => 'ami-0c55b159cbfafe1f0',
  instance_type   => 't3.medium',
  key_name        => 'prod-key',
  security_groups => ['sg-web'],
  subnet_id       => 'subnet-public-1b',
  tags            => {
    'Environment' => 'production',
    'Role'        => 'webserver',
    'Tier'        => 'frontend',
  },
}

# Database server
aws_provisioning::instance { 'db-01':
  ami_id          => 'ami-0a1b2c3d4e5f6g7h8',
  instance_type   => 'r5.large',
  key_name        => 'prod-key',
  security_groups => ['sg-database'],
  subnet_id       => 'subnet-private-1a',
  tags            => {
    'Environment' => 'production',
    'Role'        => 'database',
    'Tier'        => 'backend',
  },
}
```

### Terminate an instance

```puppet
aws_provisioning::instance { 'old-server':
  ensure          => 'absent',
  ami_id          => 'ami-0c55b159cbfafe1f0',
  instance_type   => 't2.micro',
  key_name        => 'my-key',
}
```

### Use with Hiera

**hiera.yaml:**

```yaml
---
aws::access_key_id: "AKIAIOSFODNN7EXAMPLE"
aws::secret_access_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
aws::region: "eu-west-1"

aws::instances:
  web-prod-01:
    ami_id: "ami-0c55b159cbfafe1f0"
    instance_type: "t3.small"
    key_name: "prod-keypair"
    security_groups:
      - "sg-0123456789abcdef0"
    subnet_id: "subnet-0123456789abcdef0"
    tags:
      Environment: "production"
      Role: "webserver"
```

**manifest:**

```puppet
class { 'aws_provisioning':
  aws_access_key_id     => lookup('aws::access_key_id'),
  aws_secret_access_key => Sensitive(lookup('aws::secret_access_key')),
  region                => lookup('aws::region'),
}

lookup('aws::instances', Hash).each |$name, $params| {
  aws_provisioning::instance { $name:
    * => $params,
  }
}
```

## Reference

### Classes

#### `aws_provisioning`

Main class for AWS provisioning module.

**Parameters:**

* `aws_access_key_id` (String): AWS access key ID for API authentication
* `aws_secret_access_key` (Sensitive[String]): AWS secret access key (stored securely)
* `region` (String): AWS region (default: 'us-east-1')
* `manage_config` (Boolean): Whether to manage AWS CLI configuration (default: true)

### Defined Types

#### `aws_provisioning::instance`

Creates and manages AWS EC2 instances.

**Parameters:**

* `ami_id` (String): Amazon Machine Image ID (required)
* `instance_type` (String): EC2 instance type, e.g., 't2.micro' (required)
* `key_name` (String): EC2 key pair name for SSH access (required)
* `security_groups` (Array[String]): Security group IDs (default: [])
* `subnet_id` (Optional[String]): VPC subnet ID (default: undef)
* `tags` (Hash[String, String]): Resource tags (default: {})
* `ensure` (Enum['present', 'absent']): Instance state (default: 'present')

## Limitations

**Operating System Support:**

* **Linux**: Fully supported (RHEL, CentOS, Debian, Ubuntu)
* **Windows**: Requires manual AWS CLI installation

**Known Limitations:**

* Idempotency relies on instance Name tags - ensure unique names
* No built-in VPC or security group creation (use existing resources)
* Requires AWS CLI to be functional in system PATH
* No support for advanced EC2 features (auto-scaling, load balancers)
* Instance state changes (stop/start) not currently supported

## Development

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository** and create a feature branch
2. **Use PDK** for development: `pdk validate` and `pdk test unit`
3. **Add tests** for new functionality
4. **Update documentation** in code comments and README
5. **Follow Puppet style guide** and best practices
6. **Submit a pull request** with clear description of changes

### Development Setup

```bash
# Install PDK
# See: https://puppet.com/docs/pdk/latest/pdk_install.html

# Clone the repository
git clone https://github.com/jasonstcyr/aws_provisioning.git
cd aws_provisioning

# Validate code
pdk validate

# Run unit tests
pdk test unit
```

### Testing

```bash
# Validate syntax and style
pdk validate

# Run RSpec tests
pdk test unit

# Run acceptance tests (requires Docker)
pdk bundle exec rake beaker
```

## Contributors

* Jason St. Cyr - Initial development

## License

Apache License 2.0 - See LICENSE file for details

