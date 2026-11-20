#!/bin/sh
# Print the kernel's per-CPU thermal throttle counters (events and total ms, core and package), one line per CPU,
# prefixed with a label and timestamp. measure-all.sh/extras.sh call it before and after a run.
#   throttle-counters.sh LABEL >> FILE
label=${1:-snapshot}
now=$(date -Is)
for d in /sys/devices/system/cpu/cpu[0-9]*; do
    t=$d/thermal_throttle
    [ -d "$t" ] || continue
    echo "$label $now $(basename $d) core_count=$(cat $t/core_throttle_count) core_ms=$(cat $t/core_throttle_total_time_ms) pkg_count=$(cat $t/package_throttle_count) pkg_ms=$(cat $t/package_throttle_total_time_ms)"
done
