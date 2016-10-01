module Mtg
  class App
    require './app_helpers.rb'
    require './informant.rb'
    include Mtg::AppHelpers

    def self.run; new.run; end

    def run
      print_help

      args = STDIN.gets.chomp.split
      cls
      method = args.shift
      Mtg::Informant.send(method.to_sym, args)
    end

    private

    def print_help
      pp "~~ Available Commands ~~", :cls, :new_line
      pp "update <optional set abbreviation(s)>"
      pp "merge_duplicates"
      pp "info", :new_line
      pp "", :new_line
    end
  end
end

Mtg::App.run
