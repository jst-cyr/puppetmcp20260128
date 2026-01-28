# Changelog

All notable changes to this project will be documented in this file.

## Release 0.1.0 (2026-01-28)

**Features**

* Initial release of aws_provisioning module
* AWS CLI installation and configuration management
* Secure credential management with Sensitive data type
* EC2 instance provisioning via `aws_provisioning::instance` defined type
* Support for instance creation and termination
* Customizable instance parameters (AMI, type, security groups, subnets)
* Resource tagging support
* Multi-region support
* Idempotency based on instance Name tags
* Support for Linux (RHEL, CentOS, Debian, Ubuntu) and Windows

**Known Issues**

* Windows requires manual AWS CLI installation
* No support for VPC or security group creation
* Instance state management (stop/start) not yet implemented
* Idempotency depends on unique Name tags
