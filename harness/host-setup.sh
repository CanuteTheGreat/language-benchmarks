#!/bin/sh
# Prepare (or restore) a Linux host for benchmarking. Run as root on the HOST, not in the container.
#   host-setup.sh prepare  -> governor "performance" and a FIXED clock: every core's min and max
#                             frequency set to FREQ_KHZ (default 2500000 = 2.5 GHz). Turbo stays enabled
#                             only so the cores can run above their base clock; the cap keeps the clock flat.
#                             FREQ_KHZ=off -> turbo off instead (cores at base clock).
#   host-setup.sh restore  -> puts back what prepare saved
#   host-setup.sh info     -> hardware/OS facts for the results README
set -eu
STATE=/var/tmp/langbench-host-state
case "${1:-info}" in
prepare)
    mkdir -p $STATE
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor > $STATE/governor
    for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > "$g"; done
    FREQ_KHZ=${FREQ_KHZ:-2500000}
    if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        cat /sys/devices/system/cpu/intel_pstate/no_turbo > $STATE/no_turbo
        [ "$FREQ_KHZ" = off ] && echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo || echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo
    fi
    if [ "$FREQ_KHZ" != off ]; then
        for c in /sys/devices/system/cpu/cpu[0-9]*/cpufreq; do
            echo "$(cat $c/scaling_min_freq) $(cat $c/scaling_max_freq)" > $STATE/freq.$(basename $(dirname $c))
            echo "$FREQ_KHZ" > $c/scaling_max_freq; echo "$FREQ_KHZ" > $c/scaling_min_freq
        done
    fi
    if [ -f /sys/module/zfs/parameters/zfs_arc_max ]; then
        cat /sys/module/zfs/parameters/zfs_arc_max > $STATE/zfs_arc_max
        echo 2147483648 > /sys/module/zfs/parameters/zfs_arc_max   # leave RAM for the benchmarks
    fi
    echo "governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor) no_turbo=$(cat /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null) freq_khz=$FREQ_KHZ min/max cpu0=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)/$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)"
    ;;
restore)
    for f in $STATE/freq.cpu*; do
        [ -f "$f" ] || continue
        c=/sys/devices/system/cpu/${f##*freq.}/cpufreq; set -- $(cat "$f")
        echo "$1" > $c/scaling_min_freq; echo "$2" > $c/scaling_max_freq; rm -f "$f"
    done
    [ -f $STATE/governor ] && for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do cat $STATE/governor > "$g"; done
    [ -f $STATE/no_turbo ] && cat $STATE/no_turbo > /sys/devices/system/cpu/intel_pstate/no_turbo
    [ -f $STATE/zfs_arc_max ] && cat $STATE/zfs_arc_max > /sys/module/zfs/parameters/zfs_arc_max
    echo "restored governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor) no_turbo=$(cat /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null)"
    ;;
info)
    echo "system: $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) $(cat /sys/class/dmi/id/product_version 2>/dev/null)"
    echo "cpu: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')"
    echo "logical_cpus: $(nproc)"
    for t in cpu_core cpu_atom; do [ -f /sys/devices/$t/cpus ] && echo "$t: $(cat /sys/devices/$t/cpus)"; done
    echo "max_mhz: $(lscpu | awk -F: '/CPU max MHz/{gsub(/ /,"",$2);print $2}')"
    echo "base_mhz: $(cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency 2>/dev/null)"
    echo "ram_kb: $(awk '/MemTotal/{print $2}' /proc/meminfo)"
    echo "kernel: $(uname -r)"
    echo "os: $(. /etc/os-release; echo "$PRETTY_NAME")"
    echo "governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
    echo "no_turbo: $(cat /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null)"
    echo "scaling_min_max_khz: $(for c in 0 4; do printf "cpu%s=%s/%s " $c $(cat /sys/devices/system/cpu/cpu$c/cpufreq/scaling_min_freq) $(cat /sys/devices/system/cpu/cpu$c/cpufreq/scaling_max_freq); done)"
    echo "rapl_domains: $(cat /sys/class/powercap/intel-rapl:*/name 2>/dev/null | tr '\n' ' ')"
    echo "docker: $(docker --version 2>/dev/null)"
    echo "ac_power: $(cat /sys/class/power_supply/A*/online 2>/dev/null | head -1)"
    ;;
esac
