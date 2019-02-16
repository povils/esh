class Target
  include Structural::Model

  field :name, default: ''
  field :id
  field :public_ip
  field :privaate_ip
  field :az

  def ip
    public_ip ? public_ip : private_ip
  end
end
