require_relative 'repository/aws_target_repository.rb'
require 'terminal-table'
require 'structural'

class Esh
  def list(destination)
    repository = AWSTargetRepository.new
    targets = repository.fetch_by(destination)
    if targets.empty?
      targets = repository.fetch_all
    end

    filtered_targets = targets.select {|t| t.name.include? destination}
    rows = []
    filtered_targets.sort_by{|t| t.name}.each do |target|
      rows << [target.name, target.id, target.private_ip, target.public_ip, target.az]
    end

    Terminal::Table.new :headings => ['Name', 'Instance ID', 'Private IP', 'Public IP', 'AZ'], :rows => rows
  end
end
