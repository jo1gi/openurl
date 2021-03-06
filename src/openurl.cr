require "yaml"

tests = {
  "protocol" => /^[^:]+/,
  "domain" => /(?<=:\/\/)[^\/]+/
}

def make_test(url, regex)
  url.match(regex)
end

def load_config(path)
  File.open(path) do |file|
    YAML.parse(file)
  end
end

def find_config() : String
  "#{ENV["XDG_CONFIG_HOME"]}/openurl/config.yaml"
end

def test_command(url, option, tests)
  if !option["command"]?
    return false
  end
  tests.each do |name, test|
      if option[name]?
        part = url.match(test).not_nil!.to_a[0].not_nil!
        if !Regex.new(option[name].as_s).match(part).nil?
          next
        else
          return false
        end
      end
  end
  return true
end

def find_command(url : String, config, tests)
  config.as_a.each do |c|
    if test_command(url, c, tests)
      if c["subcommands"]?
        subcommand = find_command(url, c["subcommands"], tests)
        if !subcommand.nil?
          return subcommand
        end
      end
      return c["command"].as_s
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
