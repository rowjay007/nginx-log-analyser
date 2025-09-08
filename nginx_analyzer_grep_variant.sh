#!/bin/bash
# nginx_analyzer_grep_variant.sh
# Alternative implementation using grep, cut, and sort
# Usage: ./nginx_analyzer_grep_variant.sh access.log

LOGFILE=$1

if [[ -z "$LOGFILE" || ! -f "$LOGFILE" ]]; then
    echo "Usage: $0 <nginx_access_log_file>"
    exit 1
fi

echo "=== Nginx Log Analysis (grep/cut/sort variant) ==="
echo ""

# Top 5 IP addresses using cut
echo "Top 5 IP addresses with the most requests:"
cut -d' ' -f1 "$LOGFILE" | sort | uniq -c | sort -nr | head -5 | \
    awk '{printf "%-15s - %s requests\n", $2, $1}'
echo ""

# Top 5 paths using grep and cut
echo "Top 5 most requested paths:"
grep -oE '"[A-Z]+ [^ ]+ HTTP' "$LOGFILE" | cut -d' ' -f2 | sort | uniq -c | sort -nr | head -5 | \
    awk '{printf "%-40s - %s requests\n", $2, $1}'
echo ""

# Top 5 status codes using cut
echo "Top 5 response status codes:"
cut -d' ' -f9 "$LOGFILE" | sort | uniq -c | sort -nr | head -5 | \
    awk '{printf "%-3s - %s requests\n", $2, $1}'
echo ""

# Top 5 user agents using grep
echo "Top 5 user agents:"
grep -oE '"[^"]*"$' "$LOGFILE" | sort | uniq -c | sort -nr | head -5 | \
    sed 's/^ *[0-9]* //' | sed 's/"//g' | \
    awk 'BEGIN{i=1} {print $0 " - " i " requests"; i++}'
