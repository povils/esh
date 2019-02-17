module Model
  class Profile
    include Structural::Model

    field :name
    field :user
    field :region
    field :expiration, default: 60
    field :timestamp, default: Time.now.to_i

    has_many :targets, type: Target, default: []

    def set_targets(new_targets)
      targets = new_targets
    end

    def expired?
      Time.now.to_i - timestamp > expiration
    end

    def region_name
      if region == "*"
        return Model::AwsConfig.new.region(name)
      end
      region
    end
  end
end
