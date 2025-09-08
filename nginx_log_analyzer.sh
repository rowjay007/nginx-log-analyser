#!/bin/bash
# nginx_log_analyzer.sh
# Usage: ./nginx_log_analyzer.sh access.log
# 
# Nginx Log Analyzer - A comprehensive tool for analyzing Nginx access logs
# Created as part of DevOps Engineer challenge

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${CYAN}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Function to show help
show_help() {
    echo "Nginx Log Analyzer - A tool for analyzing Nginx access logs"
    echo ""
    echo "Usage: $0 [OPTIONS] <nginx_access_log_file>"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -d, --date DATE     Filter logs by date (format: DD/MMM/YYYY)"
    echo "  -c, --csv           Export results to CSV format"
    echo "  -j, --json          Export results to JSON format"
    echo "  -n, --no-color      Disable colored output"
    echo "  --compressed        Handle compressed (.gz) log files"
    echo ""
    echo "Examples:"
    echo "  $0 access.log                    # Basic analysis"
    echo "  $0 -d '07/Sep/2025' access.log  # Filter by date"
    echo "  $0 -c access.log                # Export to CSV"
    echo "  $0 --compressed access.log.gz   # Analyze compressed file"
}

# Function to validate log file
validate_logfile() {
    local logfile="$1"
    local compressed="$2"
    
    if [[ -z "$logfile" ]]; then
        print_error "Error: No log file specified"
        show_help
        exit 1
    fi
    
    if [[ ! -f "$logfile" ]]; then
        print_error "Error: File '$logfile' not found"
        exit 1
    fi
    
    # Check if file is readable
    if [[ ! -r "$logfile" ]]; then
        print_error "Error: File '$logfile' is not readable"
        exit 1
    fi
    
    # For compressed files, check if we have the necessary tools
    if [[ "$compressed" == "true" && "${logfile##*.}" == "gz" ]]; then
        if ! command -v zcat &> /dev/null; then
            print_error "Error: zcat command not found. Cannot process compressed files."
            exit 1
        fi
    fi
}

# Function to get file reader command
get_file_reader() {
    local logfile="$1"
    local compressed="$2"
    
    if [[ "$compressed" == "true" && "${logfile##*.}" == "gz" ]]; then
        echo "zcat"
    else
        echo "cat"
    fi
}

# Main analysis function
analyze_logs() {
    local logfile="$1"
    local date_filter="$2"
    local output_format="$3"
    local no_color="$4"
    local compressed="$5"
    
    local file_reader
    file_reader=$(get_file_reader "$logfile" "$compressed")
    
    # Create temporary file for filtered logs if date filter is specified
    local temp_log=""
    if [[ -n "$date_filter" ]]; then
        temp_log=$(mktemp)
        if [[ "$compressed" == "true" && "${logfile##*.}" == "gz" ]]; then
            zcat "$logfile" | grep "$date_filter" > "$temp_log"
        else
            grep "$date_filter" "$logfile" > "$temp_log"
        fi
        
        if [[ ! -s "$temp_log" ]]; then
            print_warning "Warning: No entries found for date '$date_filter'"
            rm -f "$temp_log"
            exit 0
        fi
        
        logfile="$temp_log"
        file_reader="cat"
    fi
    
    # Disable colors if requested
    if [[ "$no_color" == "true" ]]; then
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        CYAN=''
        NC=''
    fi
    
    if [[ "$output_format" == "json" ]]; then
        generate_json_output "$logfile" "$file_reader"
    elif [[ "$output_format" == "csv" ]]; then
        generate_csv_output "$logfile" "$file_reader"
    else
        generate_standard_output "$logfile" "$file_reader"
    fi
    
    # Clean up temporary file
    [[ -n "$temp_log" && -f "$temp_log" ]] && rm -f "$temp_log"
}

# Standard output format
generate_standard_output() {
    local logfile="$1"
    local file_reader="$2"
    
    print_header "=== Nginx Log Analysis Report ==="
    echo ""
    
    # Top 5 IP addresses
    print_header "Top 5 IP addresses with the most requests:"
    $file_reader "$logfile" | awk '{print $1}' | sort | uniq -c | sort -nr | head -5 | \
        awk '{printf "%-15s - %s requests\n", $2, $1}'
    echo ""
    
    # Top 5 requested paths
    print_header "Top 5 most requested paths:"
    $file_reader "$logfile" | awk -F\" '{print $2}' | awk '{print $2}' | sort | uniq -c | sort -nr | head -5 | \
        awk '{printf "%-40s - %s requests\n", $2, $1}'
    echo ""
    
    # Top 5 status codes with color coding
    print_header "Top 5 response status codes:"
    $file_reader "$logfile" | awk '{print $9}' | sort | uniq -c | sort -nr | head -5 | \
        while read count status; do
            case "$status" in
                2*) echo -e "${GREEN}$status - $count requests${NC}" ;;
                4*) echo -e "${YELLOW}$status - $count requests${NC}" ;;
                5*) echo -e "${RED}$status - $count requests${NC}" ;;
                *) echo "$status - $count requests" ;;
            esac
        done
    echo ""
    
    # Top 5 user agents
    print_header "Top 5 user agents:"
    $file_reader "$logfile" | awk -F\" '{print $6}' | sort | uniq -c | sort -nr | head -5 | \
        awk '{count=$1; $1=""; gsub(/^[ \t]+/, ""); printf "%-80s - %s requests\n", $0, count}'
    echo ""
    
    # Additional statistics
    print_header "Additional Statistics:"
    local total_requests
    total_requests=$($file_reader "$logfile" | wc -l | tr -d ' ')
    echo "Total requests: $total_requests"
    
    local unique_ips
    unique_ips=$($file_reader "$logfile" | awk '{print $1}' | sort -u | wc -l | tr -d ' ')
    echo "Unique IP addresses: $unique_ips"
    
    local date_range
    date_range=$($file_reader "$logfile" | awk '{print $4}' | sed 's/\[//' | sort | awk 'NR==1{first=$1} END{print first " to " $1}')
    echo "Date range: $date_range"
}

# CSV output format
generate_csv_output() {
    local logfile="$1"
    local file_reader="$2"
    local csv_file="nginx_analysis_$(date +%Y%m%d_%H%M%S).csv"
    
    print_success "Generating CSV report: $csv_file"
    
    {
        echo "Category,Item,Count"
        
        # IP addresses
        $file_reader "$logfile" | awk '{print $1}' | sort | uniq -c | sort -nr | head -5 | \
            awk '{print "IP Address," $2 "," $1}'
        
        # Requested paths
        $file_reader "$logfile" | awk -F\" '{print $2}' | awk '{print $2}' | sort | uniq -c | sort -nr | head -5 | \
            awk '{print "Path," $2 "," $1}'
        
        # Status codes
        $file_reader "$logfile" | awk '{print $9}' | sort | uniq -c | sort -nr | head -5 | \
            awk '{print "Status Code," $2 "," $1}'
        
        # User agents (truncated for CSV)
        $file_reader "$logfile" | awk -F\" '{print $6}' | sort | uniq -c | sort -nr | head -5 | \
            awk -F' ' '{count=$1; $1=""; gsub(/^[ \t]+/, ""); gsub(/,/, ";"); print "User Agent," $0 "," count}'
        
    } > "$csv_file"
    
    print_success "CSV report saved to: $csv_file"
}

# JSON output format
generate_json_output() {
    local logfile="$1"
    local file_reader="$2"
    local json_file="nginx_analysis_$(date +%Y%m%d_%H%M%S).json"
    
    print_success "Generating JSON report: $json_file"
    
    {
        echo "{"
        echo '  "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",'
        echo '  "analysis": {'
        
        # IP addresses
        echo '    "top_ips": ['
        $file_reader "$logfile" | awk '{print $1}' | sort | uniq -c | sort -nr | head -5 | \
            awk 'BEGIN{first=1} {if(!first) print ","; first=0; printf "      {\"ip\": \"%s\", \"requests\": %d}", $2, $1}' 
        echo ""
        echo '    ],'
        
        # Paths
        echo '    "top_paths": ['
        $file_reader "$logfile" | awk -F\" '{print $2}' | awk '{print $2}' | sort | uniq -c | sort -nr | head -5 | \
            awk 'BEGIN{first=1} {if(!first) print ","; first=0; printf "      {\"path\": \"%s\", \"requests\": %d}", $2, $1}'
        echo ""
        echo '    ],'
        
        # Status codes
        echo '    "top_status_codes": ['
        $file_reader "$logfile" | awk '{print $9}' | sort | uniq -c | sort -nr | head -5 | \
            awk 'BEGIN{first=1} {if(!first) print ","; first=0; printf "      {\"status\": \"%s\", \"requests\": %d}", $2, $1}'
        echo ""
        echo '    ],'
        
        # User agents
        echo '    "top_user_agents": ['
        $file_reader "$logfile" | awk -F\" '{print $6}' | sort | uniq -c | sort -nr | head -5 | \
            awk 'BEGIN{first=1} {if(!first) print ","; first=0; count=$1; $1=""; gsub(/^[ \t]+/, ""); gsub(/"/, "\\\""); printf "      {\"user_agent\": \"%s\", \"requests\": %d}", $0, count}'
        echo ""
        echo '    ]'
        
        echo '  }'
        echo "}"
    } > "$json_file"
    
    print_success "JSON report saved to: $json_file"
}

# Parse command line arguments
LOGFILE=""
DATE_FILTER=""
OUTPUT_FORMAT="standard"
NO_COLOR="false"
COMPRESSED="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--date)
            DATE_FILTER="$2"
            shift 2
            ;;
        -c|--csv)
            OUTPUT_FORMAT="csv"
            shift
            ;;
        -j|--json)
            OUTPUT_FORMAT="json"
            shift
            ;;
        -n|--no-color)
            NO_COLOR="true"
            shift
            ;;
        --compressed)
            COMPRESSED="true"
            shift
            ;;
        -*)
            print_error "Error: Unknown option $1"
            show_help
            exit 1
            ;;
        *)
            LOGFILE="$1"
            shift
            ;;
    esac
done

# Validate inputs and run analysis
validate_logfile "$LOGFILE" "$COMPRESSED"
analyze_logs "$LOGFILE" "$DATE_FILTER" "$OUTPUT_FORMAT" "$NO_COLOR" "$COMPRESSED"
