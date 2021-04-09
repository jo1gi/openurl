require "yaml"
require "mime"

module Config
  extend self

  # Loads config file
  def load_config(path)
    File.open(path) do |file|
      YAML.parse(file)
    end
  end

  # Returns the path of the default config file
  def find_config : String
    dirs = ["#{ENV["XDG_CONFIG_HOME"]}/openurl", "~/.config/openurl"]
    dirs.each do |dir|
      path = "#{dir}/config.yaml"
      if File.exists?(path)
        return path
      end
    end
    abort "Could not find config file"
  end
end
