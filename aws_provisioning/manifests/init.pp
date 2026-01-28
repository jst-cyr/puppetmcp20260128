# @summary Automates AWS EC2 VM provisioning
#
# This class manages AWS EC2 instance provisioning including
# credentials configuration, instance creation, and security groups.
#
# @param aws_access_key_id
#   AWS access key ID for authentication
# @param aws_secret_access_key
#   AWS secret access key (sensitive)
# @param region
#   AWS region where resources will be created
# @param manage_config
#   Whether to manage AWS configuration files
#
# @example Basic usage
#   class { 'aws_provisioning':
#     aws_access_key_id     => 'AKIAIOSFODNN7EXAMPLE',
#     aws_secret_access_key => Sensitive('wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'),
#     region                => 'us-east-1',
#   }
#
class aws_provisioning (
  String $aws_access_key_id,
  Sensitive[String] $aws_secret_access_key,
  String $region = 'us-east-1',
  Boolean $manage_config = true,
) {
  # Validate region format
  unless $region =~ /^[a-z]{2}-[a-z]+-\d+$/ {
    fail("Invalid AWS region format: ${region}")
  }

  # Include configuration management
  if $manage_config {
    contain aws_provisioning::config
  }
}
