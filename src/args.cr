require "option_parser"

class Args
  getter config : String | Nil
  getter url : String = ""

  def initialize()
    OptionParser.parse do |parser|
      parser.banner = "Usage: openurl [options] URL"
      parser.on("-c CONFIG", "--config CONFIG", "Path to alternative config file") { |c| @config = c }
      parser.on("-h", "--help", "Show help menu") do
        puts parser
        exit
      end
      parser.unknown_args() do |args|
        if args.size != 0
          @url = args[0]
        else
          abort "An url is required"
        end
      end
    end
  end
end
