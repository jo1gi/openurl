require "./args"
require "./rules"
require "./config"

# Loading arguments
opts = Args.new
# Loading config file
config_path = opts.config || Config.find_config
config = Config.load_config(config_path)
# Finding command
result = Rules.find_command(opts.url, config)
if result.nil?
  abort "Could not find matching program"
end
# Running command
result = result.gsub("{URL}", opts.url)
split = result.split(' ')
command = split[0]
args = split[1..]
if !result.includes?(opts.url)
  args.push(opts.url)
end
(0..args.size - 1).each do |i|
  if args[i][0] == '~'
    args[i] = ENV["HOME"] + args[i][1..]
  end
end
Process.run(command, args: args, output: opts.output ? STDOUT : Process::Redirect::Close)
