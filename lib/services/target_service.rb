require 'pry'
class TargetService
  def initialize(argument)
    @argument = argument
  end

  def target
    if profile.expired? || cache_target.nil?
      update_cache
      aws_target
    else
      cache_target
    end
  end

  private

  def update_cache
    ###################### TO DO #################
    profile.set_targets(aws.fetch_all)
    #############################################
  end

  def aws_target
    @aws_target ||= find_target(aws.fetch_all)
  end

  def cache_target
    @cache_target ||= find_target(profile.targets)
  end

  def find_target(targets)
    targets.find { |target| target.name == @argument.hostname }
  end

  def aws
    AWSTargetRepository.new
  end

  def profile
    config.current_profile
  end

  def config
    Model::Config.new
  end
end
