require "yaml"
require "./args"

# Stores all of the available rules for urls to be tested against
tests = {
  "protocol"  => /^[^:]+/,
  "domain"    => /(?<=:\/\/)[^\/]+/,
  "last_file" => /[^\/]+$/,
  "filetype"  => /(?<=\.)[^\.\/]+$/,
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
def find_config : String
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

# Loading arguments
opts = Args.new
# Loading config file
config_path = opts.config || find_config
config = load_config(config_path)
# Finding command
result = find_command(opts.url.not_nil!, config, tests)
if result.nil?
  abort "Could not find matching program"
end
# Running command
result = result.gsub("{URL}", opts.url)
split = result.split(' ')
command = split[0]
args = split[1..]
if !result.includes?("{URL}")
  args.push(opts.url)
end
(0..args.size - 1).each do |i|
  if args[i][0] == '~'
    args[i] = ENV["HOME"] + args[i][1..]
  end
end
Process.run(command, args: args, output: opts.output ? STDOUT : Process::Redirect::Close)
