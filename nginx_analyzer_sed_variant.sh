#!/bin/bash
# nginx_analyzer_sed_variant.sh
# Alternative implementation using sed for field extraction
# Usage: ./nginx_analyzer_sed_variant.sh access.log

LOGFILE=$1

if [[ -z "$LOGFILE" || ! -f "$LOGFILE" ]]; then
    echo "Usage: $0 <nginx_access_log_file>"
    exit 1
fi

echo "=== Nginx Log Analysis (sed variant) ==="
echo ""

# Top 5 IP addresses using sed
echo "Top 5 IP addresses with the most requests:"
sed 's/ .*//' "$LOGFILE" | sort | uniq -c | sort -nr | head -5 | \
    awk '{printf "%-15s - %s requests\n", $2, $1}'
echo ""

# Top 5 paths using sed
echo "Top 5 most requested paths:"
sed -n 's/.*"\([A-Z]*\) \([^ ]*\) HTTP.*/\2/p' "$LOGFILE" | sort | uniq -c | sort -nr | head -5 | \
    awk '{printf "%-40s - %s requests\n", $2, $1}'
echo ""

# Top 5 status codes using sed
echo "Top 5 response status codes:"
sed -n 's/.* \([0-9][0-9][0-9]\) [0-9]* .*/\1/p' "$LOGFILE" | sort | uniq -c | sort -nr | head -5 | \
    awk '{printf "%-3s - %s requests\n", $2, $1}'
echo ""

# Top 5 user agents using sed
echo "Top 5 user agents:"
sed -n 's/.*"\([^"]*\)"$/\1/p' "$LOGFILE" | sort | uniq -c | sort -nr | head -5 | \
    awk '{count=$1; $1=""; gsub(/^[ \t]+/, ""); printf "%-80s - %s requests\n", $0, count}'
