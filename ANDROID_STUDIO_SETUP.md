# Android Studio Setup Guide for ScopeX Mobile Testing

## Quick Setup for Command Line Tools

### Option 1: Install via Android Studio (Recommended)

1. **Open Android Studio**
2. **Go to Tools > SDK Manager**
3. **Click on 'SDK Tools' tab**
4. **Check these items:**
   - ✅ Android SDK Command-line Tools (latest)
   - ✅ Android Emulator
   - ✅ Android SDK Platform-Tools
5. **Click 'Apply' and install**

### Option 2: Install via Homebrew

```bash
# Install command line tools
brew install --cask android-commandlinetools

# Restart your terminal after installation
```

### Option 3: Manual Installation

```bash
# Download command line tools
curl -O https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip

# Extract to Android SDK
unzip commandlinetools-mac-11076708_latest.zip -d $ANDROID_HOME/cmdline-tools/

# Rename to 'latest'
mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest
```

## Verify Installation

After installation, restart your terminal and run:

```bash
# Check if tools are available
sdkmanager --version
avdmanager --version

# Test the ScopeX test runner
./run-tests.sh -p android --no-auto-emulator
```

## Environment Variables

Make sure these are set in your shell profile (`~/.zshrc` or `~/.bash_profile`):

```bash
export ANDROID_HOME="/Users/saurabhverma/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
```

## Using Existing Emulators

If you don't want to install command line tools, you can use existing emulators:

```bash
# List existing emulators
emulator -list-avds

# Run tests with existing emulator
./run-tests.sh -p android --no-auto-emulator -d "YourEmulatorName"
```

## Troubleshooting

### Command Line Tools Not Found
- Restart terminal after installation
- Check PATH environment variable
- Verify installation in Android Studio SDK Manager

### Emulator Issues
- Make sure Android Emulator is installed in SDK Tools
- Check if emulator binary exists: `ls $ANDROID_HOME/emulator/emulator`

### Permission Issues
- Make sure Android SDK directory is readable
- Check if you have write permissions to create AVDs
