# wcofun.cli

Watch videos from wcofun.com directly from your terminal. You can search, stream and download videos or playlists. You can also continue from the episode where you were left of.

## Installation

### Dependencies
 - [htmlq](https://github.com/mgdm/htmlq) to scrape easily with css selectors
 - [jq](https://stedolan.github.io/jq/download/) to parse json
 - [fzf](https://github.com/junegunn/fzf) to create the menus (You can change on the script to [dmenu](https://tools.suckless.org/dmenu/) or [rofi](https://github.com/davatorium/rofi) so you decide)
 - curl, sed, awk, cut, tr and base64 are also used

#### Arch Linux
```bash
yay -S coreutils htmlq jq fzf  # htmlq is on the AUR
```

## Usage
`./wcofun` or `./wocfun search query here`
If you want to download all episodes: `./wcofun -d Search query here`

```
./wcofun -h
wcofun.cli

Syntax:
Search and stream or download one episode: wcofun [search query]
Download all episodes: wcofun -d [search query]
```

## Customization

By default it will use fzf from a terminal and rofi if no terminal output is available. You can have a configuration file at `~/.wcofunrc` where you can export some relevant variables:

```bash
# MENU_CMD: Choose your menu command. Tested with dmenu, fzf and rofi only
# NOTIFY_CMD. How to tell you about the status. Leave empty for a simple echo to stdout
export MENU_CMD="fzf"
export MENU_CMD="rofi -dmenu -i"
# MENU_CMD="dmenu"
export NOTIFY_CMD="notify-send WCOFUN"

# User agent. Maybe you have problems so try changing this.
export UA="User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0"

# Maybe you want to use a proxy? (Helps when getting blocked by cloudflare, or if you want to debug)
export CURL_EXTRA_PARAMS=""
# CURL_EXTRA_PARAMS="-k --tlsv1 -x http://localhost:8080"
export PRE_COMMAND=""
# PRE_COMMAND="mitmdump 2>&1 /dev/null"
```
