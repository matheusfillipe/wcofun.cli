# wcofun.cli

Watch videos from wcofun.com directly from your terminal. You can search, stream and download videos or playlists. You can also continue from the episode where you were left of.

## Installation

### Dependencies
 - [htmlq](https://github.com/mgdm/htmlq) to scrape easily with css selectors
 - [jq](https://stedolan.github.io/jq/download/) to parse json
 - [fzf](https://github.com/junegunn/fzf) to create the menus (You can change to dmenu or rofi)
 - curl, sed, awk, cut, tr and base64 are also used

#### Arch Linux
```bash
yay -S coreutils htmlq jq fzf  # htmlq is on the AUR
```

## Usage
`./wcofun` or `./wocfun search query here`

```
./wcofun -h
wcofun.cli

Syntax:
Search and stream or download one episode: wcofun [search query]
Download all episodes: wcofun -d [search query]
```
