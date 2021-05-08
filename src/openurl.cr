require "./args"
require "./config"
require "./command"
require "./rules"

def open_link(url : String, config, opts)
  # Finding command
  result = Rules.find_command(url, config)
  if result.nil?
    abort "Could not find matching program"
  end
  # Running command
  command, args = Command.parse_command(result, url)
  Process.run(command, args: args, output: opts.output ? STDOUT : Process::Redirect::Close, input: STDIN, shell: true)
end

# Loading command line arguments
opts = Args.new
# Loading config file
config_path = opts.config || Config.find_config
config = Config.load_config(config_path)
# Opening links
opts.urls.each do |url|
  open_link(url, config, opts)
end
