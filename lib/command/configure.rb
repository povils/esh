module Command
  class Configure
    attr_reader :profile, :user, :region
    private :profile, :user, :region

    def initialize(profile, user, region)
      @profile = profile
      @user = user
      @region = region
    end

    def execute
      config.add_profile(
        {
          name: profile,
          user: user,
          region: region,
          target: [],
          timestamp:
          Time.now.to_i
        }
      )

      if false == config.has_current_profile_name?
        config.set_current_profile_name("*")
      end

      config.save
    end

    private

    def config
      @config ||= Model::Config.new
    end
  end
end
