require "./args"
require "./config"
require "./command"
require "./rules"

# Loading command line arguments
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
command, args = Command.parse_command(result, opts.url)
Process.run(command, args: args, output: opts.output ? STDOUT : Process::Redirect::Close, input: STDIN, shell: true)
