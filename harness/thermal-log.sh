#!/bin/sh
# Log CPU temperature and frequency every 2 seconds on the HOST while benchmarks run.
#   thermal-log.sh OUT.csv      (stop it with kill)
out=$1
echo "epoch,max_temp_c,avg_mhz,pkg_temp_c" > "$out"
while :; do
    t=0; pkg=""
    for z in /sys/class/thermal/thermal_zone*; do
        v=$(cat "$z/temp" 2>/dev/null || echo 0)
        [ "$v" -gt "$t" ] && t=$v
        [ "$(cat "$z/type" 2>/dev/null)" = "x86_pkg_temp" ] && pkg=$((v / 1000))
    done
    mhz=$(awk '/cpu MHz/{s+=$4;n++} END{if(n) printf "%.0f", s/n}' /proc/cpuinfo)
    echo "$(date +%s),$((t / 1000)),$mhz,$pkg" >> "$out"
    sleep 2
done
