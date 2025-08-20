# Android App Files

## Required File

Place your Android APK file here with the exact name:

**`app-release.apk`**

## How to Add Your APK

1. **Build your Android app** or download from CI/CD
2. **Copy the APK** to this directory:
   ```bash
   cp /path/to/your/app-release.apk apps/android/
   ```
3. **Verify placement**:
   ```bash
   ls -la apps/android/app-release.apk
   ```

## Expected Structure

```
apps/android/
├── README.md              # This file
└── app-release.apk       # Your Android APK (REQUIRED)
```

## App Configuration

This APK will be used by Maestro as configured in `maestro.yaml`:

```yaml
app:
  android:
    appId: "com.scopex.scopexmobilev2"
    apkPath: "apps/android/app-release.apk"
```

## Troubleshooting

- **File not found**: Ensure the APK is named exactly `app-release.apk`
- **Wrong location**: The APK must be directly in `apps/android/` directory
- **Permissions**: Make sure the file is readable by the setup script

Run `./setup.sh --check-only` to verify your APK is properly placed.
