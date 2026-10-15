#!/bin/bash

export LC_ALL=C

gpu_choice="${1:-auto}"

rapl_file=""
for zone in /sys/class/powercap/intel-rapl:[0-9]; do
  case "$(cat "$zone/name" 2>/dev/null)" in
  package*)
    [ -r "$zone/energy_uj" ] && rapl_file="$zone/energy_uj"
    break
    ;;
  esac
done

energy_before=0
[ -n "$rapl_file" ] && energy_before=$(cat "$rapl_file")
time_before=$(date +%s%N)

read -r _ u1 n1 s1 i1 w1 q1 sq1 st1 _ </proc/stat
sleep 0.25
read -r _ u2 n2 s2 i2 w2 q2 sq2 st2 _ </proc/stat

energy_after=0
[ -n "$rapl_file" ] && energy_after=$(cat "$rapl_file")
time_after=$(date +%s%N)

cpu=$(awk -v t1=$((u1 + n1 + s1 + i1 + w1 + q1 + sq1 + st1)) -v t2=$((u2 + n2 + s2 + i2 + w2 + q2 + sq2 + st2)) -v d1=$((i1 + w1)) -v d2=$((i2 + w2)) 'BEGIN {
    t = t2 - t1
    if (t > 0) printf "%.1f", (t - (d2 - d1)) * 100 / t
    else print 0
}')

cpu_power_available=0
cpu_power=0
if [ -n "$rapl_file" ]; then
  cpu_power_available=1
  cpu_power=$(awk -v de=$((energy_after - energy_before)) -v dt=$((time_after - time_before)) 'BEGIN {
        if (dt > 0 && de > 0) printf "%.1f", de / dt * 1000
        else print 0
    }')
fi

cpu_temp=0
for hw in /sys/class/hwmon/hwmon*; do
  name=$(cat "$hw/name" 2>/dev/null)
  case "$name" in
  k10temp | coretemp | zenpower | cpu_thermal)
    if [ -r "$hw/temp1_input" ]; then
      cpu_temp=$(($(cat "$hw/temp1_input") / 1000))
      break
    fi
    ;;
  esac
done
if [ "$cpu_temp" -eq 0 ] && [ -r /sys/class/thermal/thermal_zone0/temp ]; then
  cpu_temp=$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))
fi

mem=$(awk '
    /^MemTotal/ {t = $2}
    /^MemAvailable/ {a = $2}
    END {
        printf "ram=%.1f\nram_used=%.1f\nram_total=%.1f\n", (t - a) * 100 / t, (t - a) / 1048576, t / 1048576
    }' /proc/meminfo)

disk=$(df -B1 --output=used,size / | tail -n1 | awk '{
    printf "disk=%.1f\ndisk_used=%.1f\ndisk_total=%.1f\n", ($2 > 0) ? $1 * 100 / $2 : 0, $1 / 1073741824, $2 / 1073741824
}')

device_asleep() {
  [ "$(cat "$1/power/runtime_status" 2>/dev/null)" = "suspended" ]
}

gpu_available=0
gpu=0
gpu_temp=0
gpu_power=0
vram=0
vram_used=0
vram_total=0
best_vram_total=-1

for dev in /sys/class/drm/card?/device; do
  [ "$(cat "$dev/vendor" 2>/dev/null)" = "0x1002" ] || continue
  [ -r "$dev/gpu_busy_percent" ] || continue
  card=$(basename "$(dirname "$dev")")
  case "$gpu_choice" in
  auto) ;;
  "$card") ;;
  *) continue ;;
  esac
  device_asleep "$dev" && continue
  mu=$(cat "$dev/mem_info_vram_used" 2>/dev/null || echo 0)
  mt=$(cat "$dev/mem_info_vram_total" 2>/dev/null || echo 0)
  [ "$mt" -gt "$best_vram_total" ] || continue
  best_vram_total=$mt
  gpu_available=1
  gpu=$(cat "$dev/gpu_busy_percent" 2>/dev/null || echo 0)
  gpu_temp=0
  gpu_power=0
  for hw in "$dev"/hwmon/hwmon*; do
    [ -d "$hw" ] || continue
    if [ -r "$hw/temp1_input" ]; then
      gpu_temp=$(($(cat "$hw/temp1_input") / 1000))
    fi
    for file in power1_average power1_input; do
      pw=$(cat "$hw/$file" 2>/dev/null)
      if [ -n "$pw" ] && [ "$pw" -gt 0 ] 2>/dev/null; then
        gpu_power=$(awk -v p="$pw" 'BEGIN { printf "%.1f", p / 1000000 }')
        break
      fi
    done
    break
  done
  vram=$(awk -v u="$mu" -v t="$mt" 'BEGIN { if (t > 0) printf "%.1f", u * 100 / t; else print 0 }')
  vram_used=$(awk -v u="$mu" 'BEGIN { printf "%.1f", u / 1073741824 }')
  vram_total=$(awk -v t="$mt" 'BEGIN { printf "%.1f", t / 1073741824 }')
done

nvidia_present=0
if [ "$gpu_choice" = "auto" ] || [ "$gpu_choice" = "nvidia" ]; then
  for dev in /sys/bus/pci/devices/*; do
    [ "$(cat "$dev/vendor" 2>/dev/null)" = "0x10de" ] || continue
    case "$(cat "$dev/class" 2>/dev/null)" in
    0x03*) ;;
    *) continue ;;
    esac
    device_asleep "$dev" && continue
    nvidia_present=1
    break
  done
fi

if [ "$nvidia_present" -eq 1 ] && command -v nvidia-smi >/dev/null 2>&1; then
  nv=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw --format=csv,noheader,nounits 2>/dev/null) || nv=""
  nv=${nv%%$'\n'*}
  if [[ "$nv" =~ ^[[:space:]]*[0-9]+, ]]; then
    IFS=',' read -r g t mu mt pw <<<"$nv"
    nv_total=$(awk -v t="$mt" 'BEGIN { printf "%d", t * 1048576 }')
    if [ "$nv_total" -gt "$best_vram_total" ]; then
      best_vram_total=$nv_total
      gpu_available=1
      gpu=$(awk -v v="$g" 'BEGIN { printf "%d", v }')
      gpu_temp=$(awk -v v="$t" 'BEGIN { printf "%d", v }')
      gpu_power=$(awk -v v="$pw" 'BEGIN { printf "%.1f", v }')
      vram=$(awk -v u="$mu" -v t="$mt" 'BEGIN { if (t > 0) printf "%.1f", u * 100 / t; else print 0 }')
      vram_used=$(awk -v u="$mu" 'BEGIN { printf "%.1f", u / 1024 }')
      vram_total=$(awk -v t="$mt" 'BEGIN { printf "%.1f", t / 1024 }')
    fi
  fi
fi

uptime=$(cut -d. -f1 /proc/uptime)

echo "cpu=$cpu"
echo "cpu_temp=$cpu_temp"
echo "cpu_power=$cpu_power"
echo "cpu_power_available=$cpu_power_available"
echo "$mem"
echo "$disk"
echo "gpu_available=$gpu_available"
echo "gpu=$gpu"
echo "gpu_temp=$gpu_temp"
echo "gpu_power=$gpu_power"
echo "vram=$vram"
echo "vram_used=$vram_used"
echo "vram_total=$vram_total"
echo "uptime=$uptime"
