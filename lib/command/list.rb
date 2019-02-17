require_relative '../repository/aws_target_repository.rb'
require 'terminal-table'
require 'fuzzy_match'

module Command
  class List
    def execute(destination, profile, region)
      repository = AWSTargetRepository.new(profile, region)
      targets = repository.fetch_by(destination)
      if targets.empty?
        not_found_text = "Could't find any EC2 instance which includes name \"#{destination}\"."
        if destination.length >= 3
          targets = repository.fetch_all
          similar_destination = find_similar_destination(targets, destination)
          if similar_destination
            not_found_text += "\nDid you mean \"#{similar_destination}\"?"
          end
        end
        
        return not_found_text
      end

      rows = []
      targets.sort_by{|t| t.name}.each do |target|
        rows << [target.name, target.id, target.private_ip, target.public_ip, target.az]
      end

      Terminal::Table.new :headings => ['Name', 'Instance ID', 'Private IP', 'Public IP', 'AZ'], :rows => rows
    end

    private

    def find_similar_destination(targets, destination)
      similar_destinations = []

      splitted_names = []
      targets.each do |target|
        splitted_names << target.name.split(/[^0-9a-z]/i)
      end

      FuzzyMatch.new(splitted_names.flatten.uniq).find(destination)
    end
  end
end
