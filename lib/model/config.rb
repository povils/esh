require_relative 'profile.rb'

module Model
  class Config
    include Structural::Model

    field :current_profile_name

    has_many :profiles, type: Profile, default: []

    def initialize
      super(config_hash)
    end

    def current_profile
      profiles.find do |profile|
        profile.name == get_current_profile_name
      end
    end

    def add_profile(profile_hash)
      if profile = profiles.find { |p| p.name == profile_hash[:name] }
        profiles.delete(profile)
      end

      profiles << Profile.new(profile_hash)
      data.merge!({profiles: profiles.map(&:data)})
    end

    def profile_by_name(profile_name)
      profiles.find { |profile| profile.name == profile_name }
    end

    def set_current_profile_name(profile_name)
      if profile_names.include?(profile_name) || profile_name == '*'
        data.merge!({current_profile_name: profile_name})
      else
        puts "Configure profile, use 'esh configure #{profile_name}'"
      end
    end

    def get_current_profile_name
      if current_profile_name == '*'
        if Model::AwsConfig.new.profile.nil?
          raise "Set 'AWS_PROFILE' environment variable or run: 'esh use profile_name'"
        end
        return Model::AwsConfig.new.profile
      end

      current_profile_name
    end

    def has_current_profile_name?
      begin
        if current_profile_name
          return true
        end
      rescue
        false
      end

      false
    end

    def save
      File.open(path, "w+") do |f|
        f.puts JSON.pretty_generate(data)
      end
    end

    private

    def profile_names
      profiles.map { |profile| profile.name }
    end

    def config_hash
      if file
        JSON.parse(File.read(path))
      else
        {}
      end
    end

    def file
      @file ||= File.file?(path)
    end

    def path
      "#{Dir.home}/.esh.json"
    end
  end
end
