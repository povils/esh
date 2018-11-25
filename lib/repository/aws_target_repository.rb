require 'aws-sdk-ec2'
require_relative '../model/target.rb'

class AWSTargetRepository
  def fetch_all
    data = [
      {
        :name => 'jenkins',
        :id => 'i-321637812da',
        :public_ip => '5.32.1.41',
        :private_ip => '172.10.2.1',
      },
      {
        :name => 'test',
        :id => 'i-12397132',
        :public_ip => '-',
        :private_ip => '192.10.2.1',
      }
    ]

    targets = []
    data.each do |result|
      targets << Target.new(result)
    end

    return targets
    ec2 = Aws::EC2::Client.new(
      region: 'eu-central-1',
      profile: 'staging'
    )

    valid_security_groups = []
    security_groups = ec2.describe_security_groups.security_groups
    security_groups.each do |security_group|
      if ssh_allowed? security_group
        valid_security_groups << security_group.group_id
      end
    end

    described_instances = ec2.describe_instances(
      filters: [
        {
          name: "instance-state-name",
          values: ["running", "pending"],
        },
      ],
    )

    targets = []
    described_instances.reservations.each do |reservation|
      reservation.instances.each do |instance|
        if has_valid_security_group(instance, valid_security_groups)
          targets << Target.new(
            {
              :name => tag_name(instance),
              :id => instance.instance_id,
              :public_ip => instance.public_ip_address,
              :private_ip => instance.private_ip_address,
              :az => instance.placement.availability_zone
            }
          )
        end
      end
    end

    targets
  end

  private

  def tag_name(instance)
    instance.tags.each do |tag|
      if tag.key == 'Name'
        return tag.value
      end
    end

    nil
  end

  def has_valid_security_group(instance, valid_security_group_ids)
    instance.security_groups.each do |security_group|
      if valid_security_group_ids.include? security_group.group_id
        return true
      end
    end

    false
  end

  def ssh_allowed?(security_group)
    security_group.ip_permissions.each do |ip_permission|
      if (ip_permission.ip_protocol == 'tcp' || ip_permission.ip_protocol == '-1') && ((ip_permission.from_port && ip_permission.to_port && 22.between?(ip_permission.from_port, ip_permission.to_port)) || (ip_permission.from_port.nil? && ip_permission.to_port.nil?))
          return true
      end
    end

    false
  end
end
