#!/bin/sh

# 1. 导入 OpenClash 环境函数
. /usr/share/openclash/ruby.sh
. /usr/share/openclash/log.sh

LOG_OUT "Tip: 执行 [MP刮削 + Emby/NAS加速版] 覆写脚本..."

CONFIG_FILE="$1"

# =========================================================
# [核心设置] 策略组名称
# 务必与你 OpenClash 面板里的组名一字不差
# =========================================================
PROXY_GROUP="♻️ 自动选择"

# 备用：
# PROXY_GROUP="🚀 手动切换"
# PROXY_GROUP="DIRECT"

# =========================================================
# [核心设置] PT / qB 端口
# =========================================================
PT_PORTS="8437 63219 51413 8888 56688"

# =========================================================
# [设置] PT 站 / Tracker 域名关键词直连
# =========================================================
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
"

# =========================================================
# [设置] PT / Tracker IP 直连
# =========================================================
DIRECT_IPS="
216.183.230.169/32
"

# =========================================================
# [设置] 域名包含这些关键词时走代理
# =========================================================
PROXY_KEYWORDS="
cloudflare
"

# =========================================================
# [设置] 刮削 / 通知 / 工具域名走代理
# =========================================================
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

# =========================================================
# 执行插入逻辑
# 注意：ruby_arr_insert 插入到 rules 第 0 位
# 所以后执行的规则，最终优先级更高
# =========================================================

# --- 1. 国内 IP 直连，优先级最低 ---
ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "GEOIP,CN,DIRECT"

# --- 2. PT / 下载器端口直连 ---
for port in $PT_PORTS; do
    port=$(echo "$port" | tr -d '\r')
    if [ -n "$port" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "SRC-PORT,$port,DIRECT"
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DST-PORT,$port,DIRECT"
    fi
done

# --- 3. 刮削 / 通知 / 工具域名走代理 ---
for domain in $PROXY_DOMAINS; do
    domain=$(echo "$domain" | tr -d '\r')
    if [ -n "$domain" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DOMAIN-SUFFIX,$domain,$PROXY_GROUP"
    fi
done

# --- 4. cloudflare 等关键词走代理 ---
for kw in $PROXY_KEYWORDS; do
    kw=$(echo "$kw" | tr -d '\r')
    if [ -n "$kw" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DOMAIN-KEYWORD,$kw,$PROXY_GROUP"
    fi
done

# --- 5. PT 站 / Tracker 域名关键词直连，优先级较高 ---
for kw in $DIRECT_KEYWORDS; do
    kw=$(echo "$kw" | tr -d '\r')
    if [ -n "$kw" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DOMAIN-KEYWORD,$kw,DIRECT"
    fi
done

# --- 6. PT / Tracker IP 直连，优先级最高 ---
for ip in $DIRECT_IPS; do
    ip=$(echo "$ip" | tr -d '\r')
    if [ -n "$ip" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "IP-CIDR,$ip,DIRECT,no-resolve"
    fi
done

LOG_OUT "Tip: 修复完成！PT/qB直连、Cloudflare代理、刮削加速规则均已生效。"
exit 0
