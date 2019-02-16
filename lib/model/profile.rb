module Model
  class Profile
    include Structural::Model

    field :name
    field :user
    field :region
    field :expiration, default: 60
    field :timestamp, default: Time.now.to_i

    has_many :targets, type: Target

    def set_targets(new_targets)
      targets = new_targets
    end

    def expired?
      Time.now.to_i - timestamp > expiration
    end
  end
end
