#!/bin/sh
. /usr/share/openclash/log.sh
. /lib/functions.sh

# This script is called by /etc/init.d/openclash
# Add your custom firewall rules here, they will be added after the end of the OpenClash iptables rules

LOG_OUT "Tip: Start Add Custom Firewall Rules..."

# ==============以下是广告过滤规则拉取脚本=================
(
    # 定义最大等待时间（秒）
    MAX_WAIT_TIME=30
    # 定义等待间隔（秒）
    WAIT_INTERVAL=2
    # 初始化已等待时间
    elapsed_time=0

    # 检查系统中是否存在 OpenClash 的 status 命令
    if command -v /etc/init.d/openclash status &>/dev/null; then
        # 如果存在 status 命令，检测 OpenClash 运行状态
        while ! /etc/init.d/openclash status | grep -q "running"; do
            if [ $elapsed_time -ge $MAX_WAIT_TIME ]; then
                # 如果在最大等待时间内未检测到 OpenClash 运行状态，输出日志并退出脚本
                LOG_OUT "[广告过滤规则拉取脚本] 未能在 30 秒内检测到 OpenClash 运行状态，脚本已停止运行..."
                exit 1
            fi
            # 输出正在检查 OpenClash 运行状态的日志
            LOG_OUT "[广告过滤规则拉取脚本] 正在检查 OpenClash 运行状态，请稍后..."
            # 等待指定的时间间隔
            sleep $WAIT_INTERVAL
            # 累加已等待时间
            elapsed_time=$((elapsed_time + WAIT_INTERVAL))
        done
        # 输出检测到 OpenClash 正在运行的日志
        LOG_OUT "[广告过滤规则拉取脚本] 检测到 OpenClash 正在运行，10 秒后开始拉取规则..."
        # 等待 10 秒
        sleep 10
    else
        # 如果不存在 status 命令，等待 10 秒以确保 OpenClash 已启动
        LOG_OUT "[广告过滤规则拉取脚本] 等待 10 秒以确保 OpenClash 已启动..."
        sleep 10
    fi

    # 输出清除已有的 anti-AD 广告过滤规则的日志
    LOG_OUT "[广告过滤规则拉取脚本] 清除已有的 anti-AD 广告过滤规则…"
    # 删除已存在的 anti-AD 规则文件
    rm -f /tmp/dnsmasq.d/anti-ad-for-dnsmasq.conf
    rm -f /tmp/dnsmasq.cfg01411c.d/anti-ad-for-dnsmasq.conf

    # 输出拉取最新的 anti-AD 广告过滤规则的日志
    LOG_OUT "[广告过滤规则拉取脚本] 拉取最新的 anti-AD 广告过滤规则，规则体积较大，请耐心等候…"
    # 下载 anti-AD 规则
    curl -s "https://gh-proxy.com/https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/adblock-for-dnsmasq.conf" -o /tmp/dnsmasq.cfg01411c.d/anti-ad-for-dnsmasq.conf 2> /tmp/anti-ad-curl.log

    # 检查 curl 命令是否成功
    if [ $? -eq 0 ]; then
        # 如果成功，输出拉取成功的日志
        LOG_OUT "[广告过滤规则拉取脚本] anti-AD 规则拉取成功！"
    else
        # 如果失败，输出拉取失败的日志，并提示查看日志文件获取详细信息
        LOG_OUT "[广告过滤规则拉取脚本] anti-AD 规则拉取失败，查看 /tmp/anti-ad-curl.log 获取详细信息。"
    fi

    # 输出清除已有的 GitHub520 加速规则的日志
    LOG_OUT "[广告过滤规则拉取脚本] 清除已有的 GitHub520 加速规则…"
    # 删除旧的 GitHub520 规则
    sed -i '/# GitHub520 Host Start/,/# GitHub520 Host End/d' /etc/hosts

    # 输出拉取最新的 GitHub520 加速规则的日志
    LOG_OUT "[广告过滤规则拉取脚本] 拉取最新的 GitHub520 加速规则…"
    # 下载 GitHub520 规则并追加到 /etc/hosts
    curl -s "https://raw.hellogithub.com/hosts" >> /etc/hosts 2> /tmp/github520-curl.log

    # 检查 curl 命令是否成功
    if [ $? -eq 0 ]; then
        # 如果成功，输出拉取成功的日志
        LOG_OUT "[广告过滤规则拉取脚本] GitHub520 加速规则拉取成功！"
    else
        # 如果失败，输出拉取失败的日志，并提示查看日志文件获取详细信息
        LOG_OUT "[广告过滤规则拉取脚本] GitHub520 加速规则拉取失败，查看 /tmp/github520-curl.log 获取详细信息。"
    fi

    # 清理 /etc/hosts 中的空行和注释行
    sed -i '/^$/d' /etc/hosts
    sed -i '/!/d' /etc/hosts

    # 输出清理 DNS 缓存的日志
    LOG_OUT "[广告过滤规则拉取脚本] 清理 DNS 缓存…"
    # 重新加载 dnsmasq 服务以应用新的规则
    /etc/init.d/dnsmasq reload
    # 输出脚本运行完毕的日志
    LOG_OUT "[广告过滤规则拉取脚本] 脚本运行完毕！"

) &
# ==============广告过滤规则拉取脚本结束==============


exit 0