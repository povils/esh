module Command
  class Use
    def initialize(profile_name)
      @profile_name = profile_name
    end

    def execute
      config.set_current_profile_name(@profile_name)
      config.save
    end

    private

    def config
      @config ||= Model::Config.new
    end
  end
end
