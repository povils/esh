require_relative 'repository/aws_target_repository.rb'
require 'terminal-table'
require 'structural'

class Esh
  def list(destination)
    repository = AWSTargetRepository.new
    targets = repository.fetch_all
    filtered_targets = targets.select {|t| t.name.include? destination}
    sleep 5
    rows = []
    filtered_targets.sort_by{|t| t.name}.each do |target|
      rows << [target.name, target.id, target.private_ip, target.public_ip, target.az]
    end

    Terminal::Table.new :headings => ['Name', 'Instance ID', 'Private IP', 'Public IP', 'AZ'], :rows => rows
  end
end
