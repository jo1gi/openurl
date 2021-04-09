module Rules
  extend self

  # Stores all of the available rules for urls to be tested against
  @@rules = {
    "protocol"  => /^[^:]+/,
    "domain"    => /(?<=:\/\/)[^\/]+/,
    "last_file" => /[^\/]+$/,
    "filetype"  => /(?<=\.)[^\.\/]+$/,
    "url"       => /./,
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

  # Tests if a set of rules match the url
  def test_command(url : String, option) : Bool
    if !option["command"]?
      return false
    end
    @@rules.each do |name, test|
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
  def find_command(url : String, config)
    config.as_a.each do |c|
      if test_command(url, c)
        if c["subrules"]
          subrules = find_command(url, c["subrules"])
          if subrules
            return subrules
          end
        end
        return c["command"].as_s.not_nil!
      end
    end
  end
end
