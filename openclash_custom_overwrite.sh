#!/bin/sh

. /usr/share/openclash/ruby.sh
. /usr/share/openclash/log.sh

LOG_OUT "Tip: 执行 [MP刮削 + Emby/NAS加速版] 覆写脚本..."

CONFIG_FILE="$1"

PROXY_GROUP="♻️ 自动选择"

PT_PORTS="8437 63219 51413 8888 56688"
DEVICE_IP="192.168.0.200/32"

DIRECT_KEYWORDS="
audiences
m-team
ptcafe
pttime
lemonhd
ptskit
xingyungept
open.cd
desync
demonii
stealth
opentracker
opentrackr
anirena
bt4g
tracker.wf
torrent.eu.org
216.183.230.169
"

PROXY_KEYWORDS="
cloudflare
"

PROXY_DOMAINS="
themoviedb.org
tmdb.org
thetvdb.com
fanart.tv
omdbapi.com
tvmaze.com
imdb.com
mb3admin.com
opensubtitles.org
opensubtitles.com
github.com
githubusercontent.com
github.io
docker.com
docker.io
dockerapi.com
registry-1.docker.io
production.cloudflare.docker.com
telegram.org
t.me
tx.me
tdesktop.com
steampowered.com
steamcommunity.com
steamgames.com
steamusercontent.com
steamserver.net
steamcontent.com
steamstatic.com
steamcdn-a.akamaihd.net
steambroadcast.com
googleapis.com
google.com
gstatic.com
googleusercontent.com
"

# 国内 IP 直连
ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "GEOIP,CN,DIRECT"

# PT/下载器相关端口直连
for port in $PT_PORTS; do
    port=$(echo "$port" | tr -d '\r')
    if [ -n "$port" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "SRC-PORT,$port,DIRECT"
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DST-PORT,$port,DIRECT"
    fi
done

# PT站 / Tracker 直连
for kw in $DIRECT_KEYWORDS; do
    kw=$(echo "$kw" | tr -d '\r')
    if [ -n "$kw" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DOMAIN-KEYWORD,$kw,DIRECT"
    fi
done

# 域名包含 cloudflare 的全部走代理
for kw in $PROXY_KEYWORDS; do
    kw=$(echo "$kw" | tr -d '\r')
    if [ -n "$kw" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DOMAIN-KEYWORD,$kw,$PROXY_GROUP"
    fi
done

# 刮削 / 通知 / 工具域名走代理
for domain in $PROXY_DOMAINS; do
    domain=$(echo "$domain" | tr -d '\r')
    if [ -n "$domain" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DOMAIN-SUFFIX,$domain,$PROXY_GROUP"
    fi
done

LOG_OUT "Tip: 修复完成！Emby刮削与所有服务均已生效。"
exit 0
