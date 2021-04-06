# openurl
[![GitHub release](https://img.shields.io/github/release/jo1gi/openurl.svg)](https://github.com/jo1gi/openurl/releases)
![GitHub top language](https://img.shields.io/github/languages/top/jo1gi/openurl)
![License](https://img.shields.io/github/license/jo1gi/openurl)

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
  subcommands:
    - domain: youtube.com
      command: vlc

- protocol: gemini
  command: amfora
```
