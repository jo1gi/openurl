module Rules
  extend self

  # Stores all of the available rules for urls to be tested against
  private RULES = {
    "protocol"  => /^([^:]+)/,
    "domain"    => /(?<=:\/\/)([^\/]+)/,
    "last_file" => /([^\/]+)(?:\?.*)?$/,
    "filetype"  => /(?<=\.)([^\/\.\?]+)(?:\?.*)?$/,
    "url"       => /(.+)/,
    "path"      => /(?::\/\/[^\/]+)([^\?]+)/,
    "params"    => ->test_params(String, YAML::Any),
  }

  # Returns a Hash with each url parameter
  private def find_params(url : String) : Hash(String, String)
    params = {} of String => String
    matches = url.match(/(?:[\?&])([^=]+=[^=&]+)/)
    if matches
      matches.captures.each do |param|
        split = param.not_nil!.split("=")
        params[split[0]] = split[1]
      end
    end
    return params
  end

  # Tests if the params in the url matches the params in the config
  private def test_params(url : String, options : YAML::Any) : Bool
    if options.as_h?
      params = find_params(url)
      options.as_h.each do |key, value|
        if params[key]? && value.as_s? && !Regex.new(value.as_s).match(params[key]).nil?
          next
        else
          return false
        end
      end
      return true
    else
      return false
    end
  end

  # Tests a url on a regex from `RULES`
  private def make_regex_test(url : String, test : Regex, value : String) : Bool
    matches = url.match(test)
    if matches && matches.size >= 1
      part = matches[0].not_nil!
      return !Regex.new(value).match(part).nil?
    end
    return false
  end

  # Tests if a set of rules match the url
  private def test_rule(url : String, option) : Bool
    if !option["command"]?
      return false
    end
    RULES.each do |name, test|
      if option[name]?
        # Running regex test
        if test.is_a?(Regex)
          if make_regex_test(url, test, option[name].as_s)
            next
          end
          # TODO Running function test
        elsif test.is_a?(Proc(String, YAML::Any, Bool))
          if test.call(url, option[name])
            next
          end
        end
        return false
      end
    end
    return true
  end

  # Finds a command in the rules which the url matches
  def find_command(url : String, config : YAML::Any)
    if !config.as_a?
      return nil
    end
    config.as_a.each do |c|
      if test_rule(url, c)
        if c["subrules"]?
          subrule = find_command(url, c["subrules"])
          if subrule
            return subrule
          end
        end
        if c["command"].as_s?
          return c["command"].as_s
        end
      end
    end
  end
end
