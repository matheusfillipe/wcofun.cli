#!/bin/bash

baseurl="https://www.wcofun.com/"
ua="user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"


trap exit INT

sel_menu (){
  fzf
}

chru() { printf "\\U$(printf '%08x' "$1")"; }

menu () {
  list=$1
  titles=$2
  choosen=$(echo "$titles" | awk '{print NR  "> " $s}' | sel_menu) 
  if [ -z "$choosen" ]; then
    return
  fi
  n=${choosen:0:1}
  echo "$list" | htmlq 'a' -a href | awk 'NR=='"$n"
}

get_link() {
  link=$1
  script=$(curl --silent "$link" | htmlq 'body > div:nth-child(3) > div.twelve.columns > div > div.fourteen.columns > div:nth-child(7) > script:nth-child(2)' | sed 's/<script>\(.*\)<\/script>/\1/')
  offset=$(echo "$script" | sed 's/.*- \([0-9]*\).*).*/\1/')

  innerscript=$(
  echo "$script" | cut -d "[" -f2 | cut -d "]" -f1 | tr "," "\n" | while read -r LINE; do
    n=$(echo "$LINE" | tr -d \" | base64 --decode | sed 's/[^[:digit:]]//g')
    n=$((n - offset))
    printf "%s" "$(chru $n)"
  done
  )

  url=$baseurl$(echo "$innerscript" | sed 's/^.*src="\([^"]*\)".*$/\1/')
  url=$baseurl$(curl --silent "$url" | grep "$.getJSON" | sed 's/^.*"\(.*\)".*$/\1/')

  curl --silent "$url" \
    -H 'authority: www.wcofun.com' \
    -H 'pragma: no-cache' \
    -H 'cache-control: no-cache' \
    -H 'accept: application/json, text/javascript, */*; q=0.01' \
    -H "$ua" \
    -H 'x-requested-with: XMLHttpRequest' \
    -H 'sec-gpc: 1' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-dest: empty' \
    -H 'Referer: https://www.wcofun.com/' \
    -H 'accept-language: en-US,en;q=0.9' \
    --compressed | jq -r '(.cdn + "/getvid?evid=" + .enc)'
}

download () {
  curl "$1" \
    -H 'Connection: keep-alive' \
    -H "$ua" \
    -H 'Accept: */*' \
    -H 'Sec-GPC: 1' \
    -H 'Sec-Fetch-Site: cross-site' \
    -H 'Sec-Fetch-Mode: no-cors' \
    -H 'Sec-Fetch-Dest: video' \
    -H 'Referer: https://www.wcofun.com/' \
    -H 'Accept-Language: en-US,en;q=0.9' \
    -H 'Range: bytes=0-' \
    --compressed --output "$2"
}

stream () {
  # mpv --http-header-fields='Connection: keep-alive',"$ua",'Accept: */*','Sec-GPC: 1','Sec-Fetch-Site: cross-site','Sec-Fetch-Mode: no-cors','Sec-Fetch-Dest: video','Referer: https://www.wcofun.com/','Accept-Language: en-US,en;q=0.9','Range: bytes=0-' "$1"
  curl "$1" \
    -H 'Connection: keep-alive' \
    -H "$ua" \
    -H 'Accept: */*' \
    -H 'Sec-GPC: 1' \
    -H 'Sec-Fetch-Site: cross-site' \
    -H 'Sec-Fetch-Mode: no-cors' \
    -H 'Sec-Fetch-Dest: video' \
    -H 'Referer: https://www.wcofun.com/' \
    -H 'Accept-Language: en-US,en;q=0.9' \
    -H 'Range: bytes=0-' \
    --compressed | mpv -
}

search () {
  list=$(curl --silent 'https://www.wcofun.com/search' \
    -H 'authority: www.wcofun.com' \
    -H 'cache-control: max-age=0' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'origin: https://www.wcofun.com' \
    -H 'content-type: application/x-www-form-urlencoded' \
    -H "$ua" \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
    -H 'sec-gpc: 1' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-mode: navigate' \
    -H 'sec-fetch-user: ?1' \
    -H 'sec-fetch-dest: document' \
    -H 'Referer: https://www.wcofun.com/' \
    -H 'accept-language: en-US,en;q=0.9' \
    --data-raw "catara=${1// /+}&konuara=series" \
    --compressed | htmlq 'div.img') 
  titles=$(echo "$list" | htmlq 'img' -a alt)
  menu "$list" "$titles"
}
choose_ep () {
  list=$(curl --silent "$1" \
  -H 'authority: www.wcofun.com' \
  -H 'pragma: no-cache' \
  -H 'cache-control: no-cache' \
  -H 'upgrade-insecure-requests: 1' \
  -H "$ua" \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
  -H 'sec-gpc: 1' \
  -H 'sec-fetch-site: none' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-user: ?1' \
  -H 'sec-fetch-dest: document' \
  -H 'accept-language: en-US,en;q=0.9' \
  --compressed | htmlq '#sidebar_right3 a' | tac)
  titles=$(echo "$list" | htmlq 'a' -a title)
  menu "$list" "$titles"
}


anime=$(search "$@")
if [ -z "$anime" ]; then
  echo "No results found"
  exit 1
fi

ep=$(choose_ep "$anime")
if [ -z "$ep" ]; then
  exit 1
fi

url=$(get_link "$ep")
echo "Got link: $url"
stream "$url"
# mkdir -p /tmp/wcofun/
# video="/tmp/wcofun/${ep##*/}"
# download "$url" "$video"
