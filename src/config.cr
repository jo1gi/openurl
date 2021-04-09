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
