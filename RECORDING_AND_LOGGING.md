# 📹 Recording & Logging Guide

## Overview

The ScopeX Mobile Automation Framework now includes comprehensive screen recording and detailed logging capabilities to enhance test debugging and evidence collection.

## 🎥 Screen Recording

### How It Works

Based on the [official Maestro documentation](https://docs.maestro.dev/api-reference/commands/startrecording.md), the framework automatically records screen activity during test execution using the `startRecording` and `stopRecording` commands.

### Recording Features

- **Automatic Recording**: All flows now include screen recording by default
- **Named Recordings**: Each recording has a descriptive name and label
- **Optional Mode**: Recordings are marked as optional to prevent test failures
- **Evidence Collection**: Perfect for debugging and documentation

### Recording Locations

Recordings are saved in the same directory as the test flow files:
```
flows/
├── guest-user-flow.yaml
├── guest-user-journey.mp4          # Main flow recording
├── permissions/
│   ├── android-permissions.yaml
│   ├── android-permissions.mp4     # Android permissions recording
│   ├── ios-permissions.yaml
│   └── ios-permissions.mp4         # iOS permissions recording
├── setup/
│   ├── clear-app-data.yaml
│   └── clear-app-data.mp4          # Setup recording
└── cleanup/
    ├── cleanup-data.yaml
    └── cleanup-data.mp4            # Cleanup recording
```

### Recording Commands

```yaml
# Start recording with custom name and label
- startRecording:
    path: 'guest-user-journey'
    label: 'Guest User Journey Test Recording'
    optional: true

# Your test steps here...

# Stop recording
- stopRecording
```

## 📝 Enhanced Logging

### Inline Logging

The framework now provides real-time inline logging during test execution:

```bash
./run-tests.sh -p android

# Output includes:
📱 Platform: android
📄 Flow: guest-user-flow.yaml
📊 Format: HTML
📝 Logs: reports/logs/maestro_android_20250820_155030.log
```

### Log Files

Detailed logs are automatically saved to:
```
reports/
├── logs/
│   ├── maestro_android_20250820_155030.log
│   ├── maestro_ios_20250820_155030.log
│   └── ...
├── android_20250820_155030.html
└── ios_20250820_155030.html
```

### Log Content

Each log file contains:
- **Maestro Command Output**: Full verbose output from test execution
- **Error Details**: Detailed error messages and stack traces
- **Performance Data**: Test execution timing and performance metrics
- **Device Information**: Platform-specific device details
- **Flow Execution**: Step-by-step flow execution details

## 🎯 Usage Examples

### Basic Test with Recording

```bash
# Run test with automatic recording and logging
./run-tests.sh -p android

# This will:
# 1. Start screen recording automatically
# 2. Show inline progress with emojis
# 3. Generate HTML report
# 4. Save detailed logs
# 5. Create video recordings
```

### Verbose Mode

```bash
# Enable verbose logging for debugging
./run-tests.sh -p android --verbose

# Additional output includes:
# - Detailed Maestro command execution
# - Step-by-step flow progress
# - Device interaction details
# - Performance metrics
```

### Custom Recording Names

You can customize recording names in your flow files:

```yaml
# In your flow file
- startRecording:
    path: 'my-custom-test'
    label: 'Custom Test Recording'
    optional: true

# This creates: my-custom-test.mp4
```

## 🔧 Configuration

### Recording Settings

Recordings are configured in each flow file:

```yaml
# Required parameters
path: 'recording-name'        # File name for the recording
label: 'Description'          # Human-readable description
optional: true               # Prevents test failure if recording fails
```

### Logging Settings

Logging is automatically enabled with these features:

- **Real-time Output**: Live progress updates during execution
- **File Capture**: All output saved to timestamped log files
- **Error Tracking**: Detailed error information and stack traces
- **Performance Metrics**: Execution time and resource usage

## 📊 Reports and Output

### HTML Reports

Beautiful HTML reports are generated automatically:

```bash
# Open HTML report in browser
open reports/android_20250820_155030.html
```

### Log Analysis

Analyze detailed logs for debugging:

```bash
# View latest log
tail -f reports/logs/maestro_android_$(date +%Y%m%d_%H%M%S).log

# Search for errors
grep -i error reports/logs/maestro_android_*.log

# Check performance
grep -i "execution time" reports/logs/maestro_android_*.log
```

## 🚀 Best Practices

### Recording Best Practices

1. **Keep Recordings Short**: Focus on key test scenarios
2. **Use Descriptive Names**: Make recordings easy to identify
3. **Mark as Optional**: Prevent recording failures from breaking tests
4. **Clean Up**: Remove old recordings periodically

### Logging Best Practices

1. **Monitor Logs**: Check logs after each test run
2. **Archive Important Logs**: Keep logs for failed test analysis
3. **Use Verbose Mode**: Enable for debugging complex issues
4. **Search Logs**: Use grep to find specific information

## 🔍 Troubleshooting

### Recording Issues

```bash
# Check if recordings are being created
ls -la flows/*.mp4

# Verify recording permissions
chmod 755 flows/

# Check available disk space
df -h
```

### Logging Issues

```bash
# Check log directory permissions
ls -la reports/logs/

# Verify log file creation
tail -f reports/logs/maestro_android_*.log

# Check for log rotation issues
du -sh reports/logs/
```

## 📈 Performance Impact

### Recording Performance

- **Minimal Impact**: Screen recording has minimal performance impact
- **Optional Mode**: Recordings won't affect test execution if they fail
- **Efficient Encoding**: Uses optimized video encoding

### Logging Performance

- **Real-time**: Logs are written in real-time without blocking
- **Efficient Storage**: Logs are compressed and rotated automatically
- **Selective Logging**: Only relevant information is captured

## 🎉 Benefits

### For Developers

- **Visual Debugging**: See exactly what happened during test execution
- **Error Analysis**: Detailed logs help identify root causes
- **Performance Monitoring**: Track test execution times and resource usage
- **Evidence Collection**: Recordings serve as test evidence

### For QA Teams

- **Bug Reports**: Include recordings and logs in bug reports
- **Test Documentation**: Visual documentation of test scenarios
- **Regression Analysis**: Compare recordings across test runs
- **Training Material**: Use recordings for team training

### For Stakeholders

- **Test Transparency**: Clear visibility into test execution
- **Quality Assurance**: Visual proof of test coverage
- **Compliance**: Maintain audit trails with recordings and logs
- **Documentation**: Automated test documentation

---

*This guide covers the enhanced recording and logging features in ScopeX Mobile Automation Framework v2.1.0*
