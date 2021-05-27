module Rules
  extend self

  # Stores all of the available rules for urls to be tested against
  private RULES = {
    "protocol"  => /^[^:]+/,
    "domain"    => /(?<=:\/\/)[^\/]+/,
    "last_file" => /[^\/]+$/,
    "filetype"  => /(?<=\.)[^\.\/]+$/,
    "url"       => /.+/,
  }

  # Tests a url on a specific regex parameter from `tests`
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
        if make_regex_test(url, test, option[name].as_s)
          next
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
