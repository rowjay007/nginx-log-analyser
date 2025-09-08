# Nginx Log Analyzer

A comprehensive command-line tool for analyzing Nginx access logs, designed for DevOps engineers to troubleshoot, monitor, and analyze web server traffic patterns.

## 🚀 Features

### Core Functionality
- **Top 5 IP addresses** with the most requests
- **Top 5 most requested paths** 
- **Top 5 response status codes** with color coding
- **Top 5 user agents**
- **Additional statistics** (total requests, unique IPs, date range)

### Advanced Features
- 📅 **Date filtering** - Analyze logs for specific dates
- 📊 **Multiple output formats** - Standard, CSV, and JSON
- 🗜️ **Compressed log support** - Handle .gz files automatically
- 🎨 **Color-coded output** - Visual status code categorization
- 🔧 **Multiple implementation variants** - Choose your preferred Unix tools

### Production Features
- ✅ Input validation and error handling
- 📚 Comprehensive help system
- 🛡️ Graceful handling of malformed entries
- 🎯 Modular and extensible design

## 📋 Requirements

- **Operating System**: Unix/Linux/macOS
- **Shell**: bash
- **Required utilities**: `awk`, `sort`, `uniq`, `head`, `grep`, `cut`, `sed`
- **Optional**: `zcat` (for compressed log support)

## 🛠️ Installation

1. Clone or download the repository:
```bash
git clone https://github.com/rowjay/nginx-log-analyser
cd nginx-log-analyser
```

2. Make the scripts executable:
```bash
chmod +x nginx_log_analyzer.sh
chmod +x nginx_analyzer_grep_variant.sh
chmod +x nginx_analyzer_sed_variant.sh
```

## 📖 Usage

### Basic Analysis
```bash
./nginx_log_analyzer.sh access.log
```

### Command Line Options
```bash
./nginx_log_analyzer.sh [OPTIONS] <nginx_access_log_file>

Options:
  -h, --help          Show help message
  -d, --date DATE     Filter logs by date (format: DD/MMM/YYYY)
  -c, --csv           Export results to CSV format
  -j, --json          Export results to JSON format
  -n, --no-color      Disable colored output
  --compressed        Handle compressed (.gz) log files
```

### Examples

#### Basic log analysis:
```bash
./nginx_log_analyzer.sh sample_access.log
```

#### Filter by specific date:
```bash
./nginx_log_analyzer.sh -d '07/Sep/2025' access.log
```

#### Export to CSV:
```bash
./nginx_log_analyzer.sh -c access.log
```

#### Export to JSON:
```bash
./nginx_log_analyzer.sh -j access.log
```

#### Analyze compressed logs:
```bash
./nginx_log_analyzer.sh --compressed access.log.gz
```

#### Disable colors (for scripting):
```bash
./nginx_log_analyzer.sh -n access.log
```

## 📊 Sample Output

```
=== Nginx Log Analysis Report ===

Top 5 IP addresses with the most requests:
45.76.135.253   - 6 requests
142.93.143.8    - 5 requests
178.128.94.113  - 4 requests
43.224.43.187   - 3 requests
192.168.1.101   - 1 requests

Top 5 most requested paths:
/api/v1/users                            - 6 requests
/api/v1/products                         - 5 requests
/api/v1/orders                           - 3 requests
/api/v1/payments                         - 2 requests
/static/images/logo.png                  - 1 requests

Top 5 response status codes:
200 - 13 requests (Green)
500 - 2 requests  (Red)
404 - 2 requests  (Yellow)
401 - 1 requests  (Yellow)
304 - 1 requests

Top 5 user agents:
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)... - 6 requests
curl/7.68.0                                       - 5 requests
PostmanRuntime/7.32.2                            - 4 requests
Googlebot/2.1 (+http://www.google.com/bot.html)  - 3 requests
kube-probe/1.18                                   - 1 requests

Additional Statistics:
Total requests: 21
Unique IP addresses: 7
Date range: 07/Sep/2025:10:00:01 to 08/Sep/2025:11:04:01
```

## 🔧 Implementation Variants

### 1. Main Implementation (`nginx_log_analyzer.sh`)
- Uses `awk` for field extraction and processing
- Full-featured with all advanced options
- Production-ready with comprehensive error handling

### 2. Grep Variant (`nginx_analyzer_grep_variant.sh`)
- Uses `grep`, `cut`, and `sort` for processing
- Demonstrates alternative Unix utility approach
- Simpler implementation for learning purposes

### 3. Sed Variant (`nginx_analyzer_sed_variant.sh`)
- Uses `sed` for field extraction
- Shows regex-based text processing
- Educational implementation variant

## 📁 Project Structure

```
nginx-log-analyser/
├── README.md                           # This documentation
├── nginx_log_analyzer.sh              # Main analyzer (full-featured)
├── nginx_analyzer_grep_variant.sh     # Alternative using grep/cut
├── nginx_analyzer_sed_variant.sh      # Alternative using sed
├── sample_access.log                  # Sample log file for testing
├── nginx_analysis_*.csv               # Generated CSV reports
└── nginx_analysis_*.json              # Generated JSON reports
```

## 📝 Log Format Support

This tool supports the standard Nginx combined log format:
```
$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"
```

Example:
```
192.168.1.1 - - [07/Sep/2025:10:00:01 +0000] "GET /api/users HTTP/1.1" 200 1024 "-" "Mozilla/5.0..."
```

## 🎯 Use Cases

### DevOps Monitoring
- Daily traffic analysis
- Performance monitoring
- Error rate tracking
- User behavior analysis

### Security Analysis
- Suspicious IP detection
- Attack pattern identification
- Bot traffic analysis
- Failed authentication tracking

### Capacity Planning
- Traffic trend analysis
- Popular endpoint identification
- Resource usage patterns
- Load distribution analysis

## 🚀 Production Deployment

### Cron Job Integration
Add to crontab for automated daily reports:
```bash
# Daily log analysis at 6 AM
0 6 * * * /path/to/nginx_log_analyzer.sh -j /var/log/nginx/access.log
```

### Log Rotation Integration
Works seamlessly with logrotate:
```bash
# Analyze yesterday's rotated logs
./nginx_log_analyzer.sh /var/log/nginx/access.log.1
```

### Dashboard Integration
Export JSON/CSV formats for dashboard integration:
```bash
./nginx_log_analyzer.sh -j access.log | curl -X POST -d @nginx_analysis_*.json dashboard-api/logs
```

## 🐛 Troubleshooting

### Common Issues

1. **Permission denied**
   ```bash
   chmod +x nginx_log_analyzer.sh
   ```

2. **File not found**
   ```bash
   # Verify file path
   ls -la /path/to/access.log
   ```

3. **Empty output**
   ```bash
   # Check log format
   head -5 access.log
   ```

4. **Compressed file issues**
   ```bash
   # Ensure zcat is available
   which zcat
   ```

## 📈 Performance

- **Small logs** (< 1MB): < 1 second
- **Medium logs** (1-100MB): 1-10 seconds  
- **Large logs** (100MB-1GB): 10-60 seconds
- **Memory usage**: Minimal (< 50MB for most operations)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

## 🌟 About This Project

This project is part of the [roadmap.sh Backend Projects](https://roadmap.sh/projects/nginx-log-analyser) series, designed to help developers and DevOps engineers strengthen their shell scripting and log analysis skills.

**Project URL**: https://roadmap.sh/projects/nginx-log-analyser

## 👨‍💻 Author

**Rowjay** - Created as an open source implementation of the Distinguished Fellow DevOps Engineer challenge, demonstrating shell scripting mastery and real-world log analysis capabilities.

- 🌐 **Project Repository**: https://github.com/rowjay/nginx-log-analyser
- 📚 **Challenge Details**: https://roadmap.sh/projects/nginx-log-analyser
