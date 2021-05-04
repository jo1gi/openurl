module Command
  extend self

  # Replace ~/ in the start of an argument with home path
  private def add_homepath(args : Array(String)) : Array(String)
    (1..args.size - 1).each do |i|
      if args[i][0..1] == "~/"
        args[i] = ENV["HOME"] + args[i][1..]
      end
    end
    return args
  end

  # Splits command into individual parts with support for quotation
  private def split_command(command : String) : Array(String)
    output = [] of String
    quote = false
    current = ""
    command.each_char do |c|
      case c
      when '"'
	quote = !quote
      when ' '
	if !quote
	  output.push(current)
	  current = ""
	else
	  current += c
	end
      else
	current += c
      end
    end
    output.push(current)
    return output
  end

  # Parses command and splits it up into the command and arguments
  def parse_command(command : String, url : String) : Tuple(String, Array(String))
    part_added = false
    if command.includes?("{URL}")
      part_added = true
      command = command.gsub("{URL}", url)
    end
    parts = add_homepath split_command command
    puts parts
    if !part_added
      parts.push(url)
    end
    return {parts[0], parts[1..]}
  end
end
