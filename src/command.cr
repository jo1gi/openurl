module Command
  extend self

  # Replace ~ with home path
  private def add_homepath(args : Array(String)) : Array(String)
    (0..args.size - 1).each do |i|
      if args[i][0] == '~'
        args[i] = ENV["HOME"] + args[i][1..]
      end
    end
    return args
  end

  # Parses command and splits it up into the command and arguments
  def parse_command(command : String, url : String) : Tuple(String, Array(String))
    part_added = false
    if command.includes?("{URL}")
      part_added = true
      command = command.gsub("{URL}", url)
    end
    parts = command.split(' ')
    if !part_added
      parts.push(url)
    end
    return {parts[0], parts[1..]}
  end
end
