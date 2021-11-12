module Mtg
  module AppHelpers
    def pp(str, *args)
      cls if args.include?(:cls)
      print "\n#{str}"
      new_line if args.include?(:new_line)
    end

    def section
      new_line
      pp "~"*64
      new_line
    end

    def cls
      system "clear"
    end

    def new_line
      print "\n"
    end
  end
end
