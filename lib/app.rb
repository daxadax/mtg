module Mtg
  class App
    include AppHelpers

    def self.run
      new.run
    end

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
      pp "info"
      pp "top_cards", :new_line
      pp "", :new_line
    end
  end
end
