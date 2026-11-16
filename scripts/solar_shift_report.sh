#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

CSV="$PROJECT_DIR/data/inverter_readings.csv"
REPORT="$PROJECT_DIR/reports/shift-report.txt"

# Check input file
if [[ ! -f "$CSV" ]]; then
    echo "ERROR: inverter_readings.csv not found."
    exit 1
fi

# Calculate statistics
read OK LOW OFFLINE POWER < <(
    awk -F, '
    NR > 1 {
        if ($5 == "OK") {
            ok++
            power += $4
        }
        else if ($5 == "LOW") {
            low++
        }
        else if ($5 == "OFFLINE") {
            offline++
        }
    }
    END {
        printf "%d %d %d %.2f\n", ok, low, offline, power
    }' "$CSV"
)

TOTAL=$((OK + LOW + OFFLINE))

GENERATED=$(date '+%Y-%m-%d %H:%M:%S')
DISK_USAGE=$(du -sh "$PROJECT_DIR" | awk '{print $1}')

mkdir -p "$PROJECT_DIR/reports"

TEMP_REPORT=$(mktemp "$PROJECT_DIR/reports/.shift-report.XXXXXX")

{
    echo "SUNPULSE SOLAR FARM"
    echo "DAILY OPERATIONS SHIFT REPORT"
    echo "================================"
    echo
    echo "Generation Date: $GENERATED"
    echo
    echo "Total Readings: $TOTAL"
    echo "OK Records: $OK"
    echo "LOW Records: $LOW"
    echo "OFFLINE Records: $OFFLINE"
    echo
    echo "Total Power from OK Records: $POWER kW"
    echo
    echo "Project Disk Usage: $DISK_USAGE"
    echo
    echo "================================"
    echo "END OF REPORT"
} > "$TEMP_REPORT"

mv "$TEMP_REPORT" "$REPORT"

echo "SUCCESS: Shift report generated."
echo "Report Location: $REPORT"

exit 0
