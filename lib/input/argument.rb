class Argument
  def initialize(argument)
    @argument = argument
  end

  def user
    if has_user?
      return @argument.split('@').first
    end

    'ubuntu'
  end

  def hostname
    if has_user?
      return @argument.partition('@').last
    end

    @argument
  end

  private

  def has_user?
    @argument.include? '@'
  end
end
