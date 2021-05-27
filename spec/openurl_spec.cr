require "yaml"
require "./spec_helper"
require "../src/rules"

describe "find_command" do
  it "does not find a command on an empty config" do
    Rules.find_command("https://duckduckgo.com", YAML.parse("")).should be_nil
  end

  it "can find a command with from a regex rule" do
    Rules.find_command(
      "https://duckduckgo.com",
      YAML.parse [{"domain" => "duckduckgo.com", "command" => "a"}].to_yaml
    ).should eq "a"
  end

  it "prioritizes subrules over rules" do
    Rules.find_command(
      "https://duckduckgo.com",
      YAML.parse [{"protocol" => "https",
                   "command" => "a",
                   "subrules" => [{"domain" => "duckduckgo.com", "command" => "b"}]
    }].to_yaml
    ).should eq "b"
  end

  it "does not crash when no program is found" do
    Rules.find_command(
      "https://duckduckgo.com",
      YAML.parse [{"protocol" => "magnet", "command" => "a"}].to_yaml
    ).should be_nil
  end
end
