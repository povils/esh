class Target
  def initialize(data)
    @data = data
  end

  def name
    @data[:name] || ''
  end


  def id
    @data[:id]
  end

  def public_ip
    @data[:public_ip]
  end

  def private_ip
    @data[:private_ip]
  end

  def ip
    public_ip ? public_ip : private_ip
  end
  def az
    @data[:az]
  end
end
