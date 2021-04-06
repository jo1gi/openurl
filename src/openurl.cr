require "yaml"

# Stores all of the available rules for urls to be tested against
tests = {
  "protocol" => /^[^:]+/,
  "domain" => /(?<=:\/\/)[^\/]+/,
  "last_file" => /[^\/]+$/
}

# Tests a url on a specific regex parameter from `tests`
def make_regex_test(url : String, test : Regex, value : String) : Bool
  matches = url.match(test)
  if matches && matches.size >= 1
    part = matches[0].not_nil!
    return !Regex.new(value).match(part).nil?
  end
  return false
end

# Loads config file
def load_config(path)
  File.open(path) do |file|
    YAML.parse(file)
  end
end

# Returns the path of the default config file
def find_config() : String
  "#{ENV["XDG_CONFIG_HOME"]}/openurl/config.yaml"
end

# Tests if a set of rules match the url
def test_command(url, option, tests) : Bool
  if !option["command"]?
    return false
  end
  tests.each do |name, test|
      if option[name]?
        if make_regex_test(url, test, option[name].as_s)
          next
        end
	return false
      end
  end
  return true
end

# Finds a command in the rules which the url matches
def find_command(url : String, config, tests)
  config.as_a.each do |c|
    if test_command(url, c, tests)
      if c["subcommands"]?
        subcommand = find_command(url, c["subcommands"], tests)
        if subcommand
          return subcommand
        end
      end
      return c["command"].as_s.not_nil!
    end
  end
end

if ARGV.size > 0
  config = load_config(find_config)
  result = find_command(ARGV[0], config, tests)
  if result.nil?
    abort "Could not find matching program"
  end
  split = result.split(' ')
  command = split[0]
  args = split[1..]
  args.push(ARGV[0])
  Process.run(command, args: args)
else
  abort "An argument is required"
end
