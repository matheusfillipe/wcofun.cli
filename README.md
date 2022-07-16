### I wont longer be actively maitaining this in favor or blackbeard: https://github.com/matheusfillipe/blackbeard

# wcofun.cli

Watch videos from wcofun.com directly from your terminal. You can search, stream and download videos or playlists. You can also continue from the episode where you were left of.


1. [Installation](#installation)
   * [Dependencies](#dependencies)
     * [Ubuntu](#ubuntu)
     * [Arch Linux](#arch-linux)
     * [OSX](#osx)
2. [Usage](#usage)
3. [Customization](#customization)
4. [No results problem](#no-results-problem)
   * [1. Proxy](#1.-proxy)
   * [2. Ubuntu's openssl 1.1.1f](#2.-ubuntu's-openssl-1.1.1f)
   * [3. Curl impersonate](#3.-curl-impersonate)


## Installation

Just download [wcofun](https://raw.githubusercontent.com/matheusfillipe/wcofun.cli/master/wcofun) script, install the dependencies listed bellow and run it.

```bash
wget https://raw.githubusercontent.com/matheusfillipe/wcofun.cli/master/wcofun
chmod +x wcofun
./wcofun
```

### Dependencies
 - bash shell
 - [htmlq](https://github.com/mgdm/htmlq) to scrape easily with css selectors
 - [jq](https://stedolan.github.io/jq/download/) to parse json
 - [fzf](https://github.com/junegunn/fzf) to create the menus (You can change on the script to [dmenu](https://tools.suckless.org/dmenu/) or [rofi](https://github.com/davatorium/rofi) so you decide)
 - curl, sed, awk, cut, tr, tac and base64 are also used (coreutils)
 - mpv is hardcoded to be the stream player since you can pipe curl to it.

#### Ubuntu
```bash
sudo apt install coreutils jq fzf rofi mpv -y
```
Unfortunately you will still need htmlq that can be either installed with cargo:
```bash
cargo install htmlq
```
Or downloaded from their releases page and put on your path:
```bash
# Notice this might not be the earliest version!
wget https://github.com/mgdm/htmlq/releases/download/v0.4.0/htmlq-x86_64-linux.tar.gz
tar -xvzf htmlq-x86_64-linux.tar.gz
sudo cp htmlq /usr/bin/  # or anywhere in your path
```

#### Arch Linux

You can install from the AUR: https://aur.archlinux.org/packages/wcofun

```bash
yay -S wcofun
```

Or if you download the script you can get the dependencies with:

```bash
yay -S coreutils mpv htmlq jq fzf rofi  # htmlq is on the AUR
```

To avoid "Not found" problems:

```bash
yay -S curl-impersonate-chrome
```

#### OSX

```bash
brew install coreutils htmlq jq fzf mpv
```

## Usage
`./wcofun` or `./wocfun search query here`
If you want to download all episodes: `./wcofun -d Search query here`

```
                     WCOFUN.CLI
---------------------------------------------------------------------------------
Syntax:
  /home/matheus/Projects/wcofun/wcofun [-n] [-s | -D | -d [range]] [search query]
  All parameters are optional.

Example:
  Search and stream or download one episode: wcofun [search query]
  Download all episodes: wcofun -D [search query]
  Watch next episode: wcofun -n

Options:
  -D: Download all episodes of selected anime.
  -d [ep-number|start-end]: Download a range of episodes by specifying the beginning and end. You can also specify a single episode number or a range like n- to download all starting from the nth or -n to download all until the nth. An empty range (-) will cause cause it to prompt for the episode number and then download.
  -s: Stream selectped episode
  -n: Play next episode of lastly watched anime
  -p: Play previous episode of lastly watched anime
  -P [command]: Pre execution command. Useful for launching an http proxy.
  -e: Edit config with nvim
  -c: Edit cached searches with nvim
  -h: Show this help
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
export CURL_EXTRA_PARAMS=""  # this option is not used for stream and download
# CURL_EXTRA_PARAMS="-k --tlsv1 -x http://localhost:8080"
export PRE_COMMAND=""
# PRE_COMMAND="mitmdump 2>&1 /dev/null"
```

## No results problem

If you are getting no results for everything you are probably being blocked by cloudflare. This problem happens because curl's tls handshake is not the same as a browser's one. Here are some solutions for this:

### 1. Proxy

 Install a proxy like `mitmproxy` : `pacman -S mitmproxy` or `brew install mitmproxy` and create a config like:

```bash
export CURL_EXTRA_PARAMS="-k --tlsv1 -x http://localhost:8080"
export PRE_COMMAND="mitmdump 2>&1 /dev/null"

```
This will launch the proxy locally before wcofun search starts.


### 2. Ubuntu's openssl 1.1.1f

If you are on linux I've found out that this is due to the newer version of openssl that is somehow detected by cloudflare. You can get ubuntu's 20.04 `libssl.so.1.1` from a ubuntu machine or from [here](http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f26). Extract the library from it, and launch wcofun setting `LD_LIBRARY_PATH` accordingly.

```bash
mkdir libssl
cd libssl
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
ar xar x libssl1.1_1.1.1f-1ubuntu2_amd64.deb
tar xf data.tar.xz
mkdir -p ~/curlibs
cp usr/lib/x86_64-linux-gnu/libssl.so.1.1 ~/curlibs
cd ..
rm -r libssl

# And finally run it like:
LD_LIBRARY_PATH=~/curlibs wcofun
```
Or you can add `export LD_LIBRARY_PATH=~/curlibs` to your `~/.wcofunrc`.

### 3. Curl impersonate

* [https://github.com/lwthiker/curl-impersonate](https://github.com/lwthiker/curl-impersonate)

Build this project as described on their readme choosing either firefox or chrome, copy the built curl executable to somewhere on your system and set `CURL_PATH` to it.

``` bash
git clone --depth=1 https://github.com/lwthiker/curl-impersonate
cd curl-impersonate
docker build -t curl-impersonate-chrome chrome/

# Wait for a while and let's check it out
docker run -it curl-impersonate-chrome /bin/bash
ls /build/out
```

If you see `curl-impersonate  curl_chrome98 ` means it worked. Don't close the container shell yet.

rom another terminal type:

```bash
docker cp curl-impersonate-chrome:/build/out/curl-impersonate /some/important/path/curl-impersonate
```

Now just set `CURL_PATH="/some/important/path/curl-impersonate"` on your `~/.wcofunrc`

On arch linux you can easilly install it with:

```bash
yay -S curl-impersonate-bin
```

And set `CURL_PATH="/usr/local/bin/curl-impersonate-chrome"` on your `~/.wcofunrc`
