module Model
  class AwsConfig
    def profile
      ENV['AWS_PROFILE']
    end

    def region(profile_name)
      @region ||= resolve_region(profile_name)
    end

    private

    def resolve_region(profile_name)
      keys = %w(AWS_REGION AMAZON_REGION AWS_DEFAULT_REGION)
      env_region = ENV.values_at(*keys).compact.first
      env_region = nil if env_region == ''
      config_region = Aws.shared_config.region(profile: profile_name)
      env_region || config_region
    end
  end
end
