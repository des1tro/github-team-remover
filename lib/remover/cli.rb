require 'thor'
require 'colorize'

module Remover
  class CLI < Thor
    method_option :organization, aliases: '--o', required: true
    method_option :login, aliases: '--l', required: true
    method_option :password, aliases: '--p', required: true
    method_option :color, default: :white, aliases: '--c'
    method_option :verbose, aliases: '--v'
    method_option :delete, aliases: '--d'

    desc('|Commands:', 'help list for more info')

    long_desc <<-LONGDESC
      Optional commands:
    --c color : will colorize your output.

      You can use red, yellow, green, white and maybe others colors

    --v => additional info, URL for users and repos

    --d => will delete all unused teams
    LONGDESC

    def list
      Remover.configuration.load_from_options!(options)
      puts 'Unused teams:'.colorize(color)
      Remover::List.new(github).unused_teams.each do |unused_team|
        Remover::Reporter.new(unused_team, color, verbose?, delete?).report_to_cli
      end
    end

    default_task :list

    private

    def delete?
      true if options[:delete]
    end

    def verbose?
      true if options[:verbose]
    end

    def color
      Remover.configuration.color.intern
    end

    def github
      Remover::Github.new(octokit)
    end

    def octokit
      Octokit::Client.new(
        login: Remover.configuration.login,
        password: Remover.configuration.password
      )
    end
  end
end
