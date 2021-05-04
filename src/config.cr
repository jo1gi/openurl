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
    config_dir = ENV["XDG_CONFIG_HOME"]? || "#{ENV["HOME"]?}/.config"
    path = "#{config_dir}/openurl/config.yaml"
    if File.exists?(path)
      return path
    end
    abort "Could not find config file\nThe config should be placed: #{path}"
  end
end
