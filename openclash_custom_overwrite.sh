#!/bin/sh

# 1. 导入 OpenClash 环境函数
. /usr/share/openclash/ruby.sh
. /usr/share/openclash/log.sh

LOG_OUT "Tip: 执行 [MP刮削 + Emby/NAS加速版] 覆写脚本..."

CONFIG_FILE="$1"

# =========================================================
# [核心设置] 策略组名称 (⚠️ 务必与你面板里的组名一字不差！)
# =========================================================
PROXY_GROUP="♻️ 自动选择"

# 备用
#      ♻️ 自动选择
#      🔯 故障转移
#      🔮 负载均衡
#      🇭🇰 香港节点
#      🇨🇳 台湾节点
#      🇸🇬 狮城节点
#      🇯🇵 日本节点
#      🇺🇲 美国节点
#      🇰🇷 韩国节点
#      🚀 手动切换
#      DIRECT

# =========================================================
# [核心设置] 端口与 NAS IP
# =========================================================
# 已根据截图新增监听端口 8437
PT_PORTS="8437 63219 51413 8888 56688"
DEVICE_IP="192.168.0.200/32"

# =========================================================
# [设置] 强制直连 (PT站/Tracker，防封号)
# =========================================================
# 已新增 audiences，确保观众 PT 站走直连
DIRECT_KEYWORDS="
audiences
m-team ptcafe pttime lemonhd ptskit xingyungept open.cd
desync demonii stealth opentracker opentrackr anirena bt4g tracker.wf torrent.eu.org
216.183.230.169
"

# =========================================================
# [设置] 强制走代理 (刮削 + 通知 + 工具全家桶)
# =========================================================
PROXY_DOMAINS="
# --- Emby & MoviePilot 刮削核心 ---
themoviedb.org
tmdb.org
thetvdb.com
fanart.tv
omdbapi.com
tvmaze.com
imdb.com
# --- Emby 官方验证与字幕 ---
mb3admin.com
opensubtitles.org
opensubtitles.com
# --- GitHub & Docker (解决飞牛拉取失败) ---
github.com
githubusercontent.com
github.io
docker.com
docker.io
dockerapi.com
registry-1.docker.io
production.cloudflare.docker.com
# --- Telegram 推送 ---
telegram.org
t.me
tx.me
tdesktop.com
# --- Steam 下载与登录提速 ---
steampowered.com
steamcommunity.com
steamgames.com
steamusercontent.com
steamserver.net
steamcontent.com
steamstatic.com
steamcdn-a.akamaihd.net
steambroadcast.com
# --- Google AI (Gemini 等 API) ---
googleapis.com
google.com
gstatic.com
googleusercontent.com
"

# =========================================================
# 执行插入逻辑 (倒序插入，保证最底部的规则在Clash中最先被匹配)
# =========================================================

# --- 5. [兜底] 192.168.0.200 剩余流量直连 ---
# ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "SRC-IP-CIDR,$DEVICE_IP,DIRECT"

# --- 4. [通用] 国内 IP 直连 (避免国内流量被全局代理) ---
ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "GEOIP,CN,DIRECT"

# --- 3. [端口] PT/下载器管理端口直连 ---
for port in $PT_PORTS; do
    ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "SRC-PORT,$port,DIRECT"
    ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DST-PORT,$port,DIRECT"
done

# --- 2. [PT域名] 强制直连 ---
for kw in $DIRECT_KEYWORDS; do
    # 强制剔除回车符，防止Windows换行格式导致规则失效
    kw=$(echo "$kw" | tr -d '\r')
    if [ -n "$kw" ] && [ "${kw#\#}" = "$kw" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DOMAIN-KEYWORD,$kw,DIRECT"
    fi
done

# --- 1. [代理域名] 强制代理 (最先匹配) ---
for domain in $PROXY_DOMAINS; do
    # 强制剔除回车符，防止匹配失败
    domain=$(echo "$domain" | tr -d '\r')
    if [ -n "$domain" ] && [ "${domain#\#}" = "$domain" ]; then
        ruby_arr_insert "$CONFIG_FILE" "['rules']" 0 "DOMAIN-SUFFIX,$domain,$PROXY_GROUP"
    fi
done

LOG_OUT "Tip: 修复完成！Emby刮削与所有服务均已生效。"
exit 0
