# @summary Manages AWS EC2 instance provisioning
#
# This defined type creates and manages AWS EC2 instances with specified
# configuration including AMI, instance type, security groups, and tags.
#
# @param ami_id
#   The AMI ID to use for the instance
# @param instance_type
#   EC2 instance type (e.g., t2.micro, t3.medium)
# @param key_name
#   SSH key pair name for instance access
# @param security_groups
#   Array of security group IDs to assign
# @param subnet_id
#   VPC subnet ID where instance will be launched
# @param tags
#   Hash of tags to apply to the instance
# @param ensure
#   Whether the instance should exist (present/absent)
#
# @example Create a basic EC2 instance
#   aws_provisioning::instance { 'web-server-01':
#     ami_id          => 'ami-0c55b159cbfafe1f0',
#     instance_type   => 't2.micro',
#     key_name        => 'my-key-pair',
#     security_groups => ['sg-0123456789abcdef0'],
#     subnet_id       => 'subnet-0123456789abcdef0',
#     tags            => {
#       'Name'        => 'web-server-01',
#       'Environment' => 'production',
#       'Role'        => 'webserver',
#     },
#   }
#
define aws_provisioning::instance (
  String $ami_id,
  String $instance_type,
  String $key_name,
  Array[String] $security_groups = [],
  Optional[String] $subnet_id = undef,
  Hash[String, String] $tags = {},
  Enum['present', 'absent'] $ensure = 'present',
) {
  # Validate AMI ID format
  unless $ami_id =~ /^ami-[a-f0-9]{8,17}$/ {
    fail("Invalid AMI ID format: ${ami_id}")
  }

  # Validate instance type format
  unless $instance_type =~ /^[a-z][0-9][a-z]?\.(nano|micro|small|medium|large|[0-9]*xlarge)$/ {
    fail("Invalid instance type format: ${instance_type}")
  }

  # Add Name tag if not specified
  $final_tags = $tags + { 'Name' => $title }

  # Convert tags hash to CLI format
  $tag_specs = $final_tags.map |$key, $value| {
    "Key=${key},Value=${value}"
  }.join(' ')

  # Build security group parameter
  $sg_param = $security_groups.empty ? {
    true  => '',
    false => "--security-group-ids ${security_groups.join(' ')}",
  }

  # Build subnet parameter
  $subnet_param = $subnet_id ? {
    undef   => '',
    default => "--subnet-id ${subnet_id}",
  }

  if $ensure == 'present' {
    # Use exec to create instance via AWS CLI
    exec { "create_ec2_instance_${title}":
      command => "aws ec2 run-instances --image-id ${ami_id} --instance-type ${instance_type} --key-name ${key_name} ${sg_param} ${subnet_param} --tag-specifications 'ResourceType=instance,Tags=[${tag_specs}]' --region ${aws_provisioning::region}",
      path    => ['/usr/local/bin', '/usr/bin', '/bin'],
      unless  => "aws ec2 describe-instances --filters 'Name=tag:Name,Values=${title}' 'Name=instance-state-name,Values=running,pending,stopping,stopped' --region ${aws_provisioning::region} --query 'Reservations[].Instances[]' --output text | grep -q .",
      require => Class['aws_provisioning::config'],
    }
  } else {
    # Terminate instance
    exec { "terminate_ec2_instance_${title}":
      command => "aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filters 'Name=tag:Name,Values=${title}' --region ${aws_provisioning::region} --query 'Reservations[].Instances[].InstanceId' --output text) --region ${aws_provisioning::region}",
      path    => ['/usr/local/bin', '/usr/bin', '/bin'],
      onlyif  => "aws ec2 describe-instances --filters 'Name=tag:Name,Values=${title}' 'Name=instance-state-name,Values=running,pending,stopping,stopped' --region ${aws_provisioning::region} --query 'Reservations[].Instances[]' --output text | grep -q .",
      require => Class['aws_provisioning::config'],
    }
  }
}
