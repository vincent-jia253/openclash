#!/bin/sh

# 1. 导入 OpenClash 环境函数
. /usr/share/openclash/ruby.sh
. /usr/share/openclash/log.sh

LOG_OUT "Tip: 执行 [MP刮削 + DMP饥荒加速版] 覆写脚本..."

CONFIG_FILE="$1"

# =========================================================
# [设置] 策略组名称
# =========================================================
PROXY_GROUP="♻️ 自动选择"

# =========================================================
# [设置] 端口与IP
# =========================================================
PT_PORTS="63219 51413 8888 56688"
DEVICE_IP="192.168.0.200/32"

# =========================================================
# [设置] 强制直连 (PT站)
# =========================================================
DIRECT_KEYWORDS="
m-team ptcafe pttime lemonhd ptskit xingyungept open.cd
desync demonii stealth opentracker opentrackr anirena bt4g tracker.wf torrent.eu.org
"

# =========================================================
# [设置] 强制走代理 (MP刮削 + Telegram + Steam全家桶)
# =========================================================
PROXY_DOMAINS="
#GitHub_解决MoviePilot插件库拉取报错
github.com
githubusercontent.com
github.io

#MoviePilot_刮削与元数据
themoviedb.org
tmdb.org
thetvdb.com
fanart.tv
omdbapi.com

#Telegram_通知推送
telegram.org
t.me
tx.me
tdesktop.com

#Docker_解决飞牛拉取镜像超时
docker.com
docker.io
dockerapi.com
registry-1.docker.io
production.cloudflare.docker.com

#Steam_登录与数据下载强制代理提速
steampowered.com
steamcommunity.com
steamgames.com
steamusercontent.com
steamserver.net
steamcontent.com
steamstatic.com
steamcdn-a.akamaihd.net
steambroadcast.com

#Google_Gemini_API_谷歌AI的api调用
googleapis.com
google.com
gstatic.com
googleusercontent.com
"

# =========================================================
# 执行插入逻辑 (倒序插入)
# =========================================================

# --- 5. [兜底] 192.168.0.200 剩余流量直连 ---
ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "SRC-IP-CIDR,$DEVICE_IP,DIRECT"

# --- 4. [通用] 国内 IP 直连 ---
ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "GEOIP,CN,DIRECT"

# --- 3. [端口] BT/管理端口直连 ---
for port in $PT_PORTS; do
    ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "SRC-PORT,$port,DIRECT"
    ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DST-PORT,$port,DIRECT"
done

# --- 2. [PT域名] 直连 ---
for kw in $DIRECT_KEYWORDS; do
    if [ -n "$kw" ] && [ "${kw#\#}" = "$kw" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DOMAIN-KEYWORD,$kw,DIRECT"
    fi
done

# --- 1. [代理域名] 强制代理 ---
for domain in $PROXY_DOMAINS; do
     if [ -n "$domain" ] && [ "${domain#\#}" = "$domain" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DOMAIN-SUFFIX,$domain,$PROXY_GROUP"
     fi
done

LOG_OUT "Tip: 修复完成！MP刮削与Steam下载均已强制走代理。"
exit 0