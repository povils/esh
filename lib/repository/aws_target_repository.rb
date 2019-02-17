require 'aws-sdk-ec2'
require 'aws-sdk-core'
require_relative '../model/target.rb'
require 'fuzzy_match'

class AWSTargetRepository
  def initialize(profile)
    @ec2 = Aws::EC2::Client.new(
      region: profile.region_name,
      profile: profile.name
    )
  end

  def fetch_by(destination)
    # p FuzzyMatch.new(['seamus', 'aaaa', 'livve']).find(destination)
    # data = [
    #   {
    #     :name => 'fake',
    #     :id => 'i-321637812da',
    #     :public_ip => '5.32.1.41',
    #     :private_ip => '172.10.2.1',
    #   },
    #   {
    #     :name => 'test',
    #     :id => 'i-12397132',
    #     :public_ip => '-',
    #     :private_ip => '192.10.2.1',
    #   }
    # ]
    #
    # targets = []
    # data.each do |result|
    #   targets << Target.new(result)
    # end
    #
    # return targets

    #   provider = Aws::SharedConfig.new(
    #     profile_name: 'live-eu',
    #     config_enabled: true
    #   )
    #   p provider
    # p provider.region
    # return []

    begin
      described_instances = @ec2.describe_instances({
        filters: [
          {
            name: "instance-state-name",
            values: ["running", "pending"],
          },
          {
            name: "tag:Name",
            values: [
              "*#{destination}*",
            ],
          },
        ],
      })
    rescue => error
      abort error.message
    end

    create_targets described_instances
  end

  def fetch_all
    fetch_by ('')
  end

  private

  def create_targets(described_instances)
    targets = []
    described_instances.reservations.each do |reservation|
      reservation.instances.each do |instance|
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

    targets
  end

  def tag_name(instance)
    instance.tags.each do |tag|
      if tag.key == 'Name'
        return tag.value
      end
    end

    nil
  end
end
