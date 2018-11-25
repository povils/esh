class Executer
  def initialize(user, destination)
    @user, @destination = user, destination
  end

  def self.execute(user, destination)
    new(user, destination).execute
  end

  def execute
    exec("echo Running #{command} && ssh #{command}")
  end

  private

  def command
    "#{@user}@#{@destination}"
  end
end
