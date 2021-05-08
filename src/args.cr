require "option_parser"

class Args
  getter config : String | Nil
  getter output = false
  getter urls = [] of String

  def initialize
    OptionParser.parse do |parser|
      parser.banner = "Usage: openurl [options] URL"
      parser.on("-c CONFIG", "--config CONFIG", "Path to alternative config file") { |c| @config = c }
      parser.on("-s", "--show-output", "Display the output of the command") { @output = true }
      parser.on("-f FILE", "--file FILE", "Open all links in a file") { |f|
	if !File.exists?(f)
	  abort "File '#{f}' does not exist"
	end
	@urls = @urls.concat(File.read_lines(f))
      }
      parser.on("-h", "--help", "Show help menu") do
        puts parser
        exit
      end
      parser.unknown_args() do |args|
        if args.size != 0
	  @urls = @urls.concat(args)
	elsif @urls.size == 0
          abort "An url is required"
        end
      end
      parser.invalid_option do |flag|
        abort "ERROR: '#{flag}' is not a valid option."
      end
    end
  end
end
