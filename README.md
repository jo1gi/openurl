# openurl
[![GitHub release](https://img.shields.io/github/release/jo1gi/openurl.svg)](https://github.com/jo1gi/openurl/releases)
![GitHub top language](https://img.shields.io/github/languages/top/jo1gi/openurl)
![License](https://img.shields.io/github/license/jo1gi/openurl)
![Build](https://img.shields.io/github/workflow/status/jo1gi/openurl/tests)

Opens urls based on rules in a yaml file.

## Usage
To run, just execute the program with a url as the argument. The program will
expect a config file located at `$XDG_CONFIG_HOME/openurl/config.yaml`. The
program will then open the url with the command specified in the config.

## Configuration
The Configuration file specifies which programs should open which urls. It
consists of a list of rules for opening urls.

Here is an example where youtube is opened in vlc, all other websites are
opened through firefox, and gemini capsules are opened in amfora.
```yaml
- protocol: https?
  command: firefox
  subrules:
    - domain: youtube.com
      command: vlc

- protocol: gemini
  command: amfora
```

The program checks each rule one by one. When it finds a rule set that matches
the url, it will check if any subrules match the url. When the first matching
rule is found, the corresponding command will be run with the url appended.

Each rules is comprised of a list of attributes that can be tested. Each
attribute corresponds with a part of the url. This part will be checked to see
if the given regex matches.

| Attribute | Description                                     | Example                                                                        |
|-----------|-------------------------------------------------|--------------------------------------------------------------------------------|
| protocol  | Communication protocol                          | **https**://channels.nixos.org/nixos-21.05/latest-nixos-gnome-x86_64-linux.iso |
| domain    | Website domain name and subdomain               | https://**channels.nixos.org**/nixos-21.05/latest-nixos-gnome-x86_64-linux.iso |
| last_file | Last part of path                               | https://channels.nixos.org/nixos-21.05/**latest-nixos-gnome-x86_64-linux.iso** |
| filetype  | File extension if it exists                     | https://channels.nixos.org/nixos-21.05/latest-nixos-gnome-x86_64-linux.**iso** |
| path      | Anything after the domain and before parameters | https://channels.nixos.org/**nixos-21.05/latest-nixos-gnome-x86_64-linux.iso** |
| url       | Matches everything                              | **https://channels.nixos.org/nixos-21.05/latest-nixos-gnome-x86_64-linux.iso** |
