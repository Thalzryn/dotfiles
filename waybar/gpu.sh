#!/usr/bin/env bash

gpu_usage="N/A"
gpu_temp="N/A"

for device in /sys/class/drm/card*/device; do
    [[ -r "$device/vendor" ]] || continue

    # 仅读取 AMD 显卡
    [[ "$(cat "$device/vendor" 2>/dev/null)" == "0x1002" ]] || continue

    # GPU 使用率
    if [[ -r "$device/gpu_busy_percent" ]]; then
        gpu_usage="$(cat "$device/gpu_busy_percent")%"
    fi

    # GPU 温度
    for sensor in "$device"/hwmon/hwmon*/temp1_input; do
        [[ -r "$sensor" ]] || continue
        raw_temp="$(cat "$sensor" 2>/dev/null)"

        if [[ "$raw_temp" =~ ^[0-9]+$ ]]; then
            gpu_temp="$((raw_temp / 1000))°C"
            break
        fi
    done

    break
done

printf '{"text":"GPU %s %s","tooltip":"AMD GPU\\n使用率: %s\\n温度: %s"}\n' \
    "$gpu_usage" "$gpu_temp" "$gpu_usage" "$gpu_temp"
